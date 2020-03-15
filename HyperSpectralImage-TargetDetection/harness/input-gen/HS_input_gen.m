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
%% Created by Nitin A. Gawande, PNNL, dated 2015-09-14 
%% modified Nitin A. GAwande 2016-04-27
%% this file contains the main function to generate 
%% the hyperspectral datacube
%%
%% Script to creat Hyperspectral datacube
function mainHyperspectralDatacube
clear

%%Set input Image size
input_size = 'small'
%input_size = 'medium'
%input_size = 'large'
if isequal(input_size,'small')
    img_dim = 256;
elseif isequal(input_size,'medium')
    img_dim = 1024;
elseif isequal(input_size,'large')
    img_dim = 2048;
end

%%
%get library spectra
num_lib_spectra = 15; %Number of spectra included from library
lib_spectra = cell(num_lib_spectra,1);
num_spectra = 5; % Total number of input spectra used
files = cell(num_spectra,1); % Spectra names for num_spectra spectra

lib_spectra = getlibspectra(lib_spectra);

lib_spectra_type = 'spec_one';
%lib_spectra_type = 'spec_two';

if isequal(lib_spectra_type, 'spec_one')
    files{1} = lib_spectra{01};
    files{2} = lib_spectra{02};
    files{3} = lib_spectra{03};
    files{4} = lib_spectra{04};
    files{5} = lib_spectra{05};
elseif isequal(lib_spectra_type, 'spec_one')
    files{1} = lib_spectra{06};
    files{2} = lib_spectra{07};
    files{3} = lib_spectra{08};
    files{4} = lib_spectra{09};
    files{5} = lib_spectra{10};
end

%%
input_SNR = 25;
%%
size_set = 1; % set size for N1 equal to 1
%Determine maximum size of N1
for K = 1:num_spectra
   dat = load(char(files{K}));
   [N1,N2] = size(dat);
   if (size_set < N1)
       size_set = N1;
   end
end
size_set

%one_cube holds info on library spectra
%one_cube = [size_set 2 num_spectra]
%one_cube = zeros(size_set, 2, num_spectra);
one_cube = NaN(size_set, 2, num_spectra);

for K = 1:num_spectra
   dat = load(char(files{K}));
   [N1,N2] = size(dat);
   one_cube(1:N1,:,K) = dat(:,:);
end

%plot original input 
plotinputspecs(num_spectra,one_cube,files);
%%
% Now specify number of portions 'num_spectra_portions'
% that are to be extracted from given spectra wavelengths
% Also specify the rnage for these portions by
% specifying values for labmda_portions
%
%number of spectra portions to be extrated
num_spectra_portions = 2;
labmda_portions = zeros(num_spectra_portions, 2);
num_data_portions = zeros(num_spectra_portions,1);

% range of spectra to be extracted
labmda_portions(1,1) = 0.5;
labmda_portions(1,2) = 2.5;

labmda_portions(2,1) = 3.5;
labmda_portions(2,2) = 6.0;

% number of data points for the specified range
num_data_portions(1) = 100;
num_data_portions(2) = 250;

total_size_portion = 0;
%calculate size of interpolated spectra data array
for portion = 1:num_spectra_portions
    total_size_portion = total_size_portion + num_data_portions(portion);
end
total_size_portion;

% data array for interpolated portions of spectra
data_portions_inter = zeros((total_size_portion + num_spectra_portions), 2,num_spectra);
% get interpolated data for specified range/s
data_portions_inter = getdatinter(data_portions_inter, ...
    one_cube,num_spectra, num_spectra_portions,labmda_portions, ...
    size_set, num_data_portions);
%%
% now fill in spectra as per input distribution model
% In case walength is required then use additional array dimension '2'
% data_portions_dstbuted = zeros(img_dim, img_dim, ...
%     (total_size_portion + num_spectra_portions), 2, 'int16');
data_portions_dstbuted = zeros(img_dim, img_dim, ...
    (total_size_portion + num_spectra_portions), 'uint16');

spectra_key = {'tl','tr','bl','br','cen'};
spectra_set = {1,2,3,4,5};

% spectrum_all = containers.Map(spectra_key,spectra_set);
% spectrum_tl = spectrum_all('tl');
% spectrum_tr = spectrum_all('tr');   
% spectrum_bl = spectrum_all('bl');    
% spectrum_br = spectrum_all('br');
% spectrum_cen = spectrum_all('cen');

%fill_type = 1; % fill two bands horizontally
%fill_type = 2; % fill at corners 
fill_type = 3; % fill at corners and in the center


% Fill radius for corners
%fill_cor_dim = img_dim/2;
%fill_cor_dim = int64(img_dim*2/3)
fill_cor_dim = int64(img_dim /2 *sqrt(2))

if isequal(input_size,'small')
    intensity_factor = 500;
elseif isequal(input_size,'medium')
    intensity_factor = 2000;
elseif isequal(input_size,'large')
    intensity_factor = 5000;
end

%fill hypercube
    data_portions_dstbuted = fillhypercube(data_portions_dstbuted, img_dim, ...
        num_spectra, fill_cor_dim, spectra_key, spectra_set, fill_type, ...
        intensity_factor, total_size_portion, data_portions_inter, input_SNR);

%%
    
img_sample_01(1:img_dim, 1:img_dim) = data_portions_dstbuted(1:img_dim,1:img_dim,1);
img_sample_100(1:img_dim, 1:img_dim) = data_portions_dstbuted(1:img_dim,1:img_dim,100);
figure
subplot(1, 2, 1), imshow(img_sample_01), title('Slice 001 from databube')
subplot(1, 2, 2), imshow(img_sample_01), title('Slice 100 from databube')
    
%% Now write hypercube data to a file 
% 
file_ext = '.bsq';
string_fill_type = num2str(fill_type);
hypercube_output_file = strcat('..\inout\', lib_spectra_type,'_', ...    
    'fill_type_',string_fill_type,'_',input_size,'.bsq')
if exist(hypercube_output_file,'file')
    delete(hypercube_output_file);
end

data_dims = [img_dim img_dim total_size_portion]
data_write = [1, 1, 1];

hypercube_output_file

multibandwrite(data_portions_dstbuted, ...
   hypercube_output_file,'bsq', data_dims, data_dims); 

% for frame=1:100%total_size_portion
%     img_a(1:img_dim, 1:img_dim) = data_portions_dstbuted(1:img_dim,1:img_dim,frame);
%     
% %     [m n]=size(img_a);
% %     rgb=zeros(m,n,3);
% %     rgb(:,:,1)=img_a;
% %     rgb(:,:,2)=rgb(:,:,1);
% %     rgb(:,:,3)=rgb(:,:,1);
% %     img_b=rgb/255;    
% 
%     img_b = img_a;
%     
%     if frame==1
%         imwrite(img_b,hypercube_output_file,'tif');
%         %imwrite(img_b,'first_image.tif','tif');
%     elseif frame==100
%         imwrite(img_b,hypercube_output_file,'tif','WriteMode','append')
%         %imwrite(img_b,'Hundredth_image.tif','tif');        
%     else
%         imwrite(img_b,hypercube_output_file,'tif','WriteMode','append')
%     end
% end    

%lambdaIn = data_portions_dstbuted(1,1,:);
%sRGB = spectrumRGB(lambdaIn);
%sRGB = spectrumRGB(380:780);  
%figure; imshow(repmat(sRGB, [20 1 1])) 

end %function mainHyperspectralDatacube
%%


