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

%% Matlab script for image fusion problem
%% Created by Nitin A. Gawande, PNNL, dated 2015-08-11 
%%
%% This file harness image fusion application
%% img_input_01 is the input image A
%% img_input_02 is the input image B
%% modified_img_02 is modified imgage B
%% img_fused is fused grayscale image 
%% gray_input_img_F is the fused image 
%%    which used to compute evaluation metrics
%%
%%
clear
% 
my_root_dir = pwd;
%% Read Image
input_img_A = 'ImgA-01';
input_img_B = 'ImgB-01';
file_ext = '.png';
set_img_A = strcat(my_root_dir,'\data\', input_img_A, file_ext);
set_img_B = strcat(my_root_dir,'\data\', input_img_B, file_ext);
fprintf('Input image used are: \n');
fprintf('%s\n',set_img_A);
fprintf('%s\n',set_img_B);

img_input_01 =imread(set_img_A);
img_input_02 =imread(set_img_B);
%% Get red channel
%get_red_channel = true;
get_red_channel = false;
%% Modify image with noise
modify_with_noise = true;
%modify_with_noise = false;
%%
if get_red_channel == true;
%   modify image channels 
%   component 1 is red; 2 is green; and 3 is blue
    modified_img_r = img_input_02;
    modified_img_r(:,:,1) = 0;   
    modified_img_r(:,:,3) = 0;
    if modify_with_noise == true;
        modified_img_02 = imnoise(modified_img_r,'gaussian',0.06,0.002);
    else
        modified_img_02 = modified_img_r;    
    end
else
    if modify_with_noise == true;
        modified_img_02 = imnoise(img_input_02,'gaussian',0.06,0.004); 
        %modified_img_02 = imnoise(img_input_02,'gaussian',0.06,0.025);
    else
        modified_img_02 = img_input_02;
    end  
end
%% convert from RGB to GRAY and get double values
%img_I1 = double(rgb2gray (img_input_01));
img_I1 = double(rgb2gray (img_input_01))/double(max(img_input_01(:)));

%img_I2 = double(rgb2gray (modified_img_02));
img_I2 = double(rgb2gray (modified_img_02))/double(max(modified_img_02(:)));

%% Using logical image fusion
imm = img_I1 < img_I2;
img_fused = (imm.*img_I1) + ((~imm).*img_I2);
%% Using matlab defined image fusion functions

% img_f = imfuse(img_I1, img_I2);
% img_fused = rgb2gray(img_f);

img_fused = wfusimg(img_I1,img_I2,'db2',1,'mean','mean');
%img_fused = imfuse(img_I1, img_I2, 'blend', 'Scaling', 'joint');

%% Plot last registered image 
    subplot(1,3,1)
    imshow(img_I1,[]);
    title('Background Image')
    subplot(1,3,2)
    imshow(img_I2,[]);
    title('Sensor Image 02')
    subplot(1,3,3)
    imshow(img_fused,[]);
    title('Fused Sensor Image with Background')

%% Write image files
gray_input_img_A = strcat(my_root_dir,'\inout\', input_img_A, '_gray', file_ext);
gray_input_img_B = strcat(my_root_dir,'\inout\', input_img_B, '_gray', file_ext);
gray_input_img_F = strcat(my_root_dir,'\inout\', 'Img_fused_gray', file_ext);

imwrite(img_I1,   gray_input_img_A);
imwrite(img_I2,   gray_input_img_B);
imwrite(img_fused,gray_input_img_F);
%% End of file
