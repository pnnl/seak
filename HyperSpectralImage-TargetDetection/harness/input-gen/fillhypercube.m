% -*-Mode: matlab;-*-

%*BeginCopyright*************************************************************
%
% $HeadURL$
% $Id$
%
%----------------------------------------------------------------------------
% SEAK: Suite for Embedded Applications and Kernels (hpc.pnnl.gov/SEAK/)
%----------------------------------------------------------------------------
%
% Copyright ((c)) 2016, Battelle Memorial Institute
%
% 1. Battelle Memorial Institute (hereinafter Battelle) hereby grants
%    permission to any person or entity lawfully obtaining a copy of
%    this software and associated documentation files (hereinafter "the
%    Software") to redistribute and use the Software in source and
%    binary forms, with or without modification.  Such person or entity
%    may use, copy, modify, merge, publish, distribute, sublicense,
%    and/or sell copies of the Software, and may permit others to do so,
%    subject to the following conditions:
%    
%    * Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimers.
%
%    * Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in
%      the documentation and/or other materials provided with the
%      distribution.
%
%    * Other than as used herein, neither the name Battelle Memorial
%      Institute or Battelle may be used in any form whatsoever without
%      the express written consent of Battelle.
%
%    * Redistributions of the software in any form, and publications
%      based on work performed using the software should include the
%      following citation as a reference:
%            
%        Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan
%        R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK
%        Specification." Pacific Northwest National Laboratory. May,
%        2016, http://hpc.pnnl.gov/SEAK/
%
% 2. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
%    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE
%    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
%    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
%    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
%    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
%    SUCH DAMAGE.
%
%*EndCopyright***************************************************************

%% Matlab script for Hyperspectral signature extraction 
%% Created by Nitin A. Gawande, PNNL, dated 2015-09-16
%% modified Nitin A. GAwande 2016-04-27
%% this file contains additional function to generate 
%% the hyperspectral datacube
%% Script to creat Hyperspectral datacube
%% Script to creat Hyperspectral datacube
function data_portions_dstbuted = fillhypercube(data_portions_dstbuted, img_dim, ...
        num_spectra, fill_cor_dim, spectra_key, spectra_set, fill_type, ...
        intensity_factor, total_size_portion, data_portions_inter, input_SNR);

    spectrum_all = containers.Map(spectra_key,spectra_set);
    spectrum_tl = spectrum_all('tl');
    spectrum_tr = spectrum_all('tr');   
    spectrum_bl = spectrum_all('bl');    
    spectrum_br = spectrum_all('br');
    spectrum_cen = spectrum_all('cen');
    
if (fill_type == 1)
     
    %band filled image
    img_band_left = zeros(img_dim, img_dim, 'single');
    img_band_right = zeros(img_dim, img_dim, 'single');
    
    %fill image band left to right
    img_band_left = fillbandLR(img_band_left, img_dim, intensity_factor);

    %fill image band right to left 
    img_band_right = fillbandRL(img_band_right, img_dim, intensity_factor);

    frac_abundance = zeros(num_spectra, 'double');
    
    for num_data = 1:total_size_portion;
        spectra_intensity_total = 0.0;
        spectra_intensity_total = sum(data_portions_inter(num_data,2,1:num_spectra));
        frac_abundance(1:num_spectra) = ...
            data_portions_inter(num_data,2,1:num_spectra) / spectra_intensity_total;
        sum_contribution = zeros(img_dim,img_dim,'double');
        for K = 1:num_spectra
            %get info from top-left corner fill
            if(K == spectrum_tl)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_band_left(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            %get info from top-right corner fill
            if(K == spectrum_tr)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_band_right(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
        end
        max_abundance = max(max(sum_contribution));        
        %data_portions_dstbuted(1:img_dim,1:img_dim,num_data) = ...
        %    int16((2^15)*sum_contribution(1:img_dim,1:img_dim) / max_abundance);
        img_slice(1:img_dim,1:img_dim) = ...
            sum_contribution(1:img_dim,1:img_dim) / max_abundance;
        data_portions_dstbuted(1:img_dim,1:img_dim,num_data);
        % now add noise
        v = var(img_slice(:)) / input_SNR;
        img_slice = imnoise(img_slice, 'gaussian', 0, v);
        data_portions_dstbuted(1:img_dim,1:img_dim,num_data) = int16((2^15)*img_slice(1:img_dim,1:img_dim));
    end
end

if (fill_type == 2)
  
    %corner filled images
    img_tl = zeros(img_dim, img_dim, 'single');
    img_tr = zeros(img_dim, img_dim, 'single');
    img_bl = zeros(img_dim, img_dim, 'single');
    img_br = zeros(img_dim, img_dim, 'single');   

    %fill_c_tem = [fill_cor_dim fill_cor_dim];     
    fill_c_tem = zeros(fill_cor_dim, fill_cor_dim,'single'); 
    
    %fill into image fill_c_tem 
    fill_c_tem = fill_corner(fill_c_tem, fill_cor_dim, intensity_factor);

    %fill template image top-left
    img_tl = filltl(img_tl,fill_c_tem,fill_cor_dim);
    
    %fill template image top-right
    img_tr = filltr(img_tr,fill_c_tem,fill_cor_dim,img_dim);    

    %fill template image Bottom-left
    img_bl = fillbl(img_bl,fill_c_tem,fill_cor_dim,img_dim);

    %fill template image Bottom-right
    img_br = fillbr(img_br,fill_c_tem,fill_cor_dim,img_dim);   
    
    frac_abundance = zeros(num_spectra, 'double');
    
    for num_data = 1:total_size_portion;
        spectra_intensity_total = 0.0;
        spectra_intensity_total = sum(data_portions_inter(num_data,2,1:num_spectra));
        frac_abundance(1:num_spectra) = ...
            data_portions_inter(num_data,2,1:num_spectra) / spectra_intensity_total;
        sum_contribution = zeros(img_dim,img_dim,'double');
        for K = 1:num_spectra
            %get info from top-left corner fill
            if(K == spectrum_tl)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_tl(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            %get info from top-right corner fill
            if(K == spectrum_tr)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_tr(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            if(K == spectrum_bl)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_bl(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            if(K == spectrum_br)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_br(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end 
        end
        max_abundance = max(max(sum_contribution));        
        %data_portions_dstbuted(1:img_dim,1:img_dim,num_data) = ...
        %    int16((2^15)*sum_contribution(1:img_dim,1:img_dim) / max_abundance);
        img_slice(1:img_dim,1:img_dim) = ...
            sum_contribution(1:img_dim,1:img_dim) / max_abundance;
        data_portions_dstbuted(1:img_dim,1:img_dim,num_data);
        % now add noise
        v = var(img_slice(:)) / input_SNR;
        img_slice = imnoise(img_slice, 'gaussian', 0, v);
        data_portions_dstbuted(1:img_dim,1:img_dim,num_data) = int16((2^15)*img_slice(1:img_dim,1:img_dim));
    end
end

if (fill_type == 3)
  
    %corner filled images
    img_tl = zeros(img_dim, img_dim, 'single');
    img_tr = zeros(img_dim, img_dim, 'single');
    img_bl = zeros(img_dim, img_dim, 'single');
    img_br = zeros(img_dim, img_dim, 'single');   
    %center filled image
    img_cen = zeros(img_dim, img_dim, 'single');

    %fill_c_tem = [fill_cor_dim fill_cor_dim];     
    fill_c_tem = zeros(fill_cor_dim, fill_cor_dim,'single'); 
    
    %fill into image fill_c_tem 
    fill_c_tem = fill_corner(fill_c_tem, fill_cor_dim, intensity_factor);

    %fill template image top-left
    img_tl = filltl(img_tl,fill_c_tem,fill_cor_dim);
    
    %fill template image top-right
    img_tr = filltr(img_tr,fill_c_tem,fill_cor_dim,img_dim);    

    %fill template image Bottom-left
    img_bl = fillbl(img_bl,fill_c_tem,fill_cor_dim,img_dim);

    %fill template image Bottom-right
    img_br = fillbr(img_br,fill_c_tem,fill_cor_dim,img_dim);

    %fill template image in the center
    img_cen = fillcenter(img_cen,img_dim);    
    
    frac_abundance = zeros(num_spectra, 'double');
    
    for num_data = 1:total_size_portion;
        spectra_intensity_total = 0.0;
        spectra_intensity_total = sum(data_portions_inter(num_data,2,1:num_spectra));
        frac_abundance(1:num_spectra) = ...
            data_portions_inter(num_data,2,1:num_spectra) / spectra_intensity_total;
        sum_contribution = zeros(img_dim,img_dim,'double');
        for K = 1:num_spectra
            %get info from top-left corner fill
            if(K == spectrum_tl)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_tl(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            %get info from top-right corner fill
            if(K == spectrum_tr)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_tr(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            if(K == spectrum_bl)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_bl(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            if(K == spectrum_br)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_br(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end
            if(K == spectrum_cen)
                sum_contribution(1:img_dim,1:img_dim) = sum_contribution(1:img_dim,1:img_dim) + ...
                    frac_abundance(K) * img_cen(1:img_dim,1:img_dim);
                %max_abundance = max(max(sum_contribution));                
            end            
        end
        max_abundance = max(max(sum_contribution));        
        %data_portions_dstbuted(1:img_dim,1:img_dim,num_data) = ...
        %    int16((2^15)*sum_contribution(1:img_dim,1:img_dim) / max_abundance);
        img_slice(1:img_dim,1:img_dim) = ...
            sum_contribution(1:img_dim,1:img_dim) / max_abundance;
        data_portions_dstbuted(1:img_dim,1:img_dim,num_data);
        % now add noise
        v = var(img_slice(:)) / input_SNR;
        img_slice = imnoise(img_slice, 'gaussian', 0, v);
        data_portions_dstbuted(1:img_dim,1:img_dim,num_data) = int16((2^15)*img_slice(1:img_dim,1:img_dim));
    end
end


end % end of function data_portions_dstbuted = filltype3

%%
function img_band =fillbandLR(img_band,img_dim, intensity_factor); 
%fill image band left to right
for row = 1:img_dim
    for col = 1:img_dim
        fill_row = row;
        fill_col = img_dim - col + 1;        
        intensity = intensity_factor * (col/img_dim);
        img_band(fill_row, fill_col) = intensity; 
    end 
end
end

%%
function img_band =fillbandRL(img_band,img_dim, intensity_factor); 

%fill image band right to left
for row = 1:img_dim
    for col = 1:img_dim     
        intensity = intensity_factor * (col/img_dim);
        img_band(row, col) = intensity; 
    end 
end
end %end of function fillband

%%
 %fill into image fill_c_tem 
 function fill_c_tem = fill_corner(fill_c_tem, fill_cor_dim, intensity_factor);
    for row = 1:fill_cor_dim
        for col = 1:fill_cor_dim
            intensity = intensity_factor * (row - 1)*(col - 1) / (fill_cor_dim - 1)/(fill_cor_dim - 1);
            fill_c_tem(row, col) = intensity; %uint8(intensity);
        end 
    end
 end %end of function fill_corner

%% 
%fill template image top-left
function img_tl = filltl(img_tl,fill_one,fill_dim)

for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = fill_dim - row + 1;
        fill_col = fill_dim - col + 1;        
        img_tl(fill_row, fill_col) = fill_one(row,col); 
    end 
end
end 

%%
%fill template image top-right
function img_tr = filltr(img_tr,fill_one,fill_dim,img_dim)
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = fill_dim - row + 1;
        fill_col = img_dim - fill_dim + col;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_tr(fill_row, fill_col) = fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end
end

%%
%fill template image Bottom-left
function img_bl = fillbl(img_bl,fill_one,fill_dim,img_dim);
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = img_dim - fill_dim + row;
        fill_col = fill_dim - col + 1;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_bl(fill_row, fill_col) = fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end
end

%%
%fill template image Bottom-right
function img_br = fillbr(img_br,fill_one,fill_dim,img_dim);
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = img_dim - fill_dim + row;
        fill_col = img_dim - fill_dim + col;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_br(fill_row, fill_col) = fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end
end

%%
function img_cen = fillcenter(img_cen,img_dim);
% extent of fill from center is half the image size
fill_dim = img_dim/2;
fill_one = [fill_dim fill_dim];

%fill into image fill_one 
for row = 1:fill_dim
    for col = 1:fill_dim
        intensity = 255 * (row - 1)*(col - 1) / (fill_dim - 1)/(fill_dim - 1);
        fill_one(row, col) = uint8(intensity);        
    end 
end

%fill center bottom-right
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = img_dim - row + 1;
        fill_col = img_dim - col + 1;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_cen(fill_row, fill_col) = 0.80*fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end

%fill center bottom-left
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = img_dim - row + 1;
        fill_col = col;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_cen(fill_row, fill_col) = 0.80*fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end

%fill center top-left
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = row;
        fill_col = col;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_cen(fill_row, fill_col) = 0.80*fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end

%fill center top-right
for row = 1:fill_dim
    for col = 1:fill_dim
        fill_row = row;
        fill_col = img_dim - col + 1;        
        %intensity = 255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1);
        img_cen(fill_row, fill_col) = 0.80*fill_one(row,col); 
        %img_one(row, col) = uint8(255 * (row - 1)*(col - 1) / (img_dim - 1)/(img_dim - 1));
    end 
end

end %end of function fillcenter

%%
