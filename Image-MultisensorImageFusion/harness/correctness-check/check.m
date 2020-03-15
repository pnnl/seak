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

% Matlab script for image fusion problem
%% Created by Nitin A. Gawande, PNNL, dated 2015-08-11 
%%
%% img_input_01 is the input image A
%% img_input_02 is the input image B
%% img_fused is fused grayscale image 
%% modified_img_02 is modified imgage B
%%
function main ()
clear
% 
cd ..
my_root_dir = pwd;
cd correctness-check;
%% Read input images, fused image and reference image
input_img_A = 'ImgA-01';
input_img_B = 'ImgB-01';
img_fused = 'Img_fused';
img_ref = 'ImgF_ref-01';
file_ext = '.png';
set_img_A = strcat(my_root_dir,'\inout\', input_img_A, '_gray', file_ext);
set_img_B = strcat(my_root_dir,'\inout\', input_img_B, '_gray', file_ext);
set_img_fused = strcat(my_root_dir,'\inout\', img_fused, '_gray', file_ext);
set_img_ref = strcat(my_root_dir,'\inout\', img_ref, file_ext);
fprintf('Input image used are: \n');
fprintf('%s\n',set_img_A);
fprintf('%s\n',set_img_B);
fprintf('%s\n',set_img_fused);
fprintf('%s\n',set_img_ref);

img_I1 =imread(set_img_A);
img_I2 =imread(set_img_B);
img_F        =imread(set_img_fused);
img_ref      =imread(set_img_ref);
img_R = rgb2gray(img_ref);

% %% convert from RGB to GRAY and get double values
% 
% img_I1 = double(rgb2gray (img_input_01))/double(max(img_input_01(:)));
% img_I2 = double(rgb2gray (modified_img_02))/double(max(modified_img_02(:)));
% 
% %% Using logical image fusion
% imm = img_I1 < img_I2;
% img_fused = (imm.*img_I1) + ((~imm).*img_I2);
% %% Using matlab defined image fusion functions
% img_fused = wfusimg(img_I1,img_I2,'db2',1,'mean','mean');

%% Plot last registered image 
    subplot(2,2,1)
    imshow(img_I1,[]);
    title('Input image 01')
    subplot(2,2,2)
    imshow(img_I2,[]);
    title('Input Image 02')
    subplot(2,2,3)
    imshow(img_F,[]);
    title('Fused Image')
    subplot(2,2,4)
    imshow(img_R,[]);
    title('Reference Image')    
%%
img_F_d = double(img_F);
img_R_d = double(img_R);
[M N] = size(img_F_d); % size of fused image

img_I1_d = double(img_I1);
img_I2_d = double(img_I2);

%% Compute Fusion Metrics
%%
% 01. RMSE
    fprintf('Correctness Metric 1: Root Mean Square Error (RMSE) \n');
    error = img_R_d - img_F_d;
    RMSE = sqrt(sum(sum(error .* error)) / (M * N));
%
    fprintf('RMSE is computed between the Reference Image and the Fused Image \n');    
    fprintf('Root Mean Square Error (RMSE) is - %f\n',RMSE);
%%
% 02. Entropy
    fprintf('Correctness Metric 2: Entropy (H) \n');
    fprintf('Entropy of Reference Image - %f\n',entropy(img_R));
    fprintf('Entropy of Fused     Image - %f\n',entropy(img_F));   
    
%%
% 03. Spatial Frequency (SF)

%img_s = img_F;

% Compute Spatial Frequency of 
SF_F = spatial_frequency(img_F)

% Use matlab function gradient 
Grad1 = gradient(img_I1_d);
Grad2 = gradient(img_I2_d);
% Alternatively compute gradient image from first principle
% [M N] = size(img_I1_d);
% mat_A = [img_I1_d(:,2:end)  zeros(M,1)];
% mat_B = [zeros(M,1)  img_I1_d(:,1:end-1)];
% Gx1 = [img_I1_d(:,2)-img_I1_d(:,1)  (mat_A(:,2:end-1)-mat_B(:,2:end-1))./2  ...
%     img_I1_d(:,end)-img_I1_d(:,end-1)];
% mat_A = [img_I1_d(2:end,:) ;  zeros(1,N)];
% mat_B = [zeros(1,N) ; img_I1_d(1:end-1,:)];
% Gy1 = [img_I1_d(2,:)-img_I1_d(1,:) ; (mat_A(2:end-1,:)-mat_B(2:end-1,:))./2 ; ... 
%     img_I1_d(end,:)-img_I1_d(end-1,:)];
%
Grad_D = max(Grad1,Grad2);
% Compute SF_R - Reference Spatial Frequency from img_1 & img_2
SF_R = spatial_frequency(Grad_D) 

% Compute rSF_e - ration of Spatial Frequency error
rSF_e = (SF_F - SF_R)/SF_R

%% Write image files
% gray_input_img_A = strcat(my_root_dir,'\inout\', input_img_A, '_gray', file_ext);
% gray_input_img_B = strcat(my_root_dir,'\inout\', input_img_B, '_gray', file_ext);
% gray_input_img_F = strcat(my_root_dir,'\inout\', 'img_fused_gray', file_ext);
% 
% imwrite(img_I1,   gray_input_img_A);
% imwrite(img_I2,   gray_input_img_B);
% imwrite(img_fused,gray_input_img_F);
%% End of main
end



function SF = spatial_frequency(img_s)


[M N] = size(img_s);

% Compute Row Frequency (RF)
accum_sum = double(0.0);
for m = 1:M
    for n = 2:N
       accum_sum = accum_sum +  double((img_s(m,n) - img_s(m,n-1) )^2);
    end
end
RF = sqrt(accum_sum / (M*N));
% Alternatively compute using matlab functions
% RF_diff = diff(img_s,1,2);
% RF = sqrt(mean(mean(RF_diff.^2)));
% Compute Col Frequency (CF)
accum_sum = double(0.0);
for n = 1:N
    for m = 2:M
       accum_sum = accum_sum +  double((img_s(m,n) - img_s(m-1,n) )^2);
    end
end
CF = sqrt(accum_sum / (M*N));
% Alternatively compute using matlab functions
% CF_diff = diff(img_s,1,1);
% CF = sqrt(mean(mean(CF_diff.^2)));
% Compute Main Diagonal Frequency (MDF)
accum_sum = double(0.0);
for m = 2:M
    for n = 2:N
       accum_sum = accum_sum +  double((img_s(m,n) - img_s(m-1,n-1) )^2);
    end
end
MDF = sqrt(1/sqrt(2) * accum_sum / (M*N));
% Compute Secondary Diagonal Frequency (MDF)
accum_sum = double(0.0);
for n = 1:N-1
    for m = 2:M
       accum_sum = accum_sum +  double((img_s(m,n) - img_s(m-1,n) )^2);
    end
end
SDF = sqrt(1/sqrt(2) * accum_sum / (M*N));

SF = sqrt(RF^2 + CF^2 + MDF^2 + SDF^2 );

end % End of function spatial_frequency


