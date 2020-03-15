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

%% Matlab script for image registration problem
%% Created by Nitin A. Gawande, PNNL, dated 2015-08-11 
%% modified Nitin A. GAwande 2016-02-23
%% This file harness complete image registration application
%% img_input is the input image
%% img_I is the grayscale image of img_input
%% img_I is read as a base image 
%% img_I then rotated using imtransform function
%% img_trans is the new transformed image
%% img_R is the img_trans image registered on img_I
%%
clear
input_size = 'small'
%input_size = 'medium'
%%input_size = 'large'
if isequal(input_size,'small')
    img_dim = '256';
elseif isequal(input_size,'medium')
    img_dim = '512';
elseif isequal(input_size,'large')
    img_dim = '1024';
end
%% Input images are obtained from "PictureThis", 
% Courtesy of Pacific Northwest National Laboratory.
%
% PictureThis contains hundreds of photos of research performed by 
% Pacific Northwest National Laboratory. Photos can be downloaded 
% as TIFF files. High-resolution photos are available where possible. 
%
% Use of images from PictureThis shall not claim any expressed 
% or implied affiliation with, or endorsement by, 
% Battelle Memorial Institute, Pacific Northwest National Laboratory 
% or the U.S. Department of Energy. 
%
%%image_type = 'Geometry-01-';
%%image_type = 'Geometry-02-';
%%image_type = 'Geometry-03-';
%%image_type = 'Geometry-04-';
%%image_type = 'Chem-img-PNNL-01-';
%%image_type = 'Lena-';
%%image_type = ['Airplane-PNNL-'];
%%image_type = ['Richland-aerial-01-'];
image_type = ['Columbia-valley-landscape-'];
%%
%% Number of images in a sequence for registration
num_seq_img = 10;
fprintf('Number of images in a sequence - %d\n',num_seq_img);
%%
%% Write images to file
write_img_to_files = true;
%%write_img_to_files = false;
%%
%%registration_model_type = 'rigid'
registration_model_type = 'affine'
%% Metrics for image registration
[optimizer, metric]  = imregconfig('monomodal');
%% For transformation fill in inputs
max_Tx = 20; % Specifies Translation along X
max_Ty = 20; % Specifies Translation along Y

max_Sx = 1.00; % Specifies Scale along X
max_Sy = 1.00; % Specifies Scale along Y

max_Shx = 0.00; % Specifies Shear along X, as fraction of image
max_Shy = 0.00; % Specifies Shear along Y, as fraction of image

max_theta = pi/30; % Specifies Rotation Angle
%%theta = 0; % Specifies Rotation Angle
%%
my_root_dir = pwd;
%cd inputgen;
file_ext = '.png';
set_img = strcat(my_root_dir,'\data\',image_type, img_dim, file_ext);
fprintf('Input image used is - %s\n',set_img);
%%
%% Read Image
img_input =imread(set_img);

img_I = rgb2gray (img_input);
%% Write grayscale input image to file
img_gray = 'gray-inp-';
gray_input_img = strcat(my_root_dir,'\inout\',img_gray, image_type, img_dim, file_ext)
if write_img_to_files == true;
    imwrite(img_I,gray_input_img);
end
%%
unit_mat = [
   1  0  0
   0  1  0
   0  0  1];

mx = size(img_I,2);
my = size(img_I,1);
corners = [
   0  0  1
   mx 0  1
   0  my 1
   mx my 1];

new_cord = corners*unit_mat;
%%
rotation_ = 1; % put non-zero value if rotation required
%%
%% Create sequence of images
for img_num = 1:num_seq_img
    Tx = (img_num/num_seq_img)*max_Tx; % Specifies Translation along X
    Ty = (img_num/num_seq_img)*max_Ty; % Specifies Translation along Y
    
    Sx = (img_num/num_seq_img)*(1-max_Sx)+1; % Specifies Scale along X
    Sy = (img_num/num_seq_img)*(1-max_Sy)+1; % Specifies Scale along Y

    Shx = (img_num/num_seq_img)*max_Shx; % Specifies Shear along X, as fraction of image
    Shy = (img_num/num_seq_img)*max_Shy; % Specifies Shear along Y, as fraction of image
    
    theta = (img_num/num_seq_img)*max_theta; % Specifies Rotation Angle
%%    
    if rotation_ == 0
%% For Translation, Scaling, and Shear use following 
%% transformation matrix
    affine_mat = [
        Sx  Shy  0
        Shx Sy   0
        Tx  Ty   1];
    else
%% For Rotation use following transformation matrix
    affine_mat = [
        cos(theta)  sin(theta) 0
        -sin(theta) cos(theta) 0
        0           0          1];
    end
 %% 
    T = maketform('affine', affine_mat); 
%% Transformed image img_2, copied to img_trans
    img_2 = imtransform(img_I, T, ...
        'XData',[min(new_cord(:,1)) max(new_cord(:,1))],...
        'YData',[min(new_cord(:,2)) max(new_cord(:,2))]);
    img_trans(:,:,img_num) = img_2;
    img_gray = strcat('gray-seq-', num2str(img_num), '-');
    gray_output_img = strcat(my_root_dir,'\inout\',img_gray, image_type, img_dim, file_ext);
    if write_img_to_files == true;
        imwrite(img_2,gray_output_img);
    end
end
%% 
orig_img = double(img_I); %required to compute error of registration
[M N] = size(orig_img); % size of input image
%%
%% Start image registration for the sequence
for img_num = 1:num_seq_img
    fprintf('IMAGE NUMBER - %d\n',img_num);
    if isequal(registration_model_type,'rigid')
        tic
        img_R = imregister(img_trans(:,:,img_num), img_I,'rigid',optimizer, metric);
        toc
    elseif isequal(registration_model_type,'affine')
        tic
        img_R = imregister(img_trans(:,:,img_num), img_I,'affine',optimizer, metric);
        toc
    end
%% Write registered image
    if write_img_to_files == true;
        img_gray = strcat('gray-reg-', num2str(img_num), '-');
        gray_output_img = strcat(my_root_dir,'\inout\',img_gray, image_type, img_dim, file_ext);
        imwrite(img_R,gray_output_img);
    end
%% Compute error between registered image img_R 
%% w.r.t. to original image img_I
%%
    reg_img = double(img_R);
%%
    error = orig_img - reg_img;
    MSE = sum(sum(error .* error)) / (M * N);
%%
    if(MSE > 0)
        PSNR = 10*log(255*255/MSE) / log(10);
    else
        PSNR = 120;
    end 
    fprintf('Mean Square Error (MSE) is - %f\n',MSE);
    fprintf('Peak Signal to Noise Ratio (PSNR) is - %f\n',PSNR);
%% End of error measurement
%%
%% Plot last registered image 
    subplot(1,3,1)
    imshow(img_I);
    title('Original Image')
    subplot(1,3,2)
    imshowpair(img_I, img_trans(:,:,img_num),'Scaling','joint');
    title('Overlapped Translated Image')
    subplot(1,3,3)
    imshowpair(img_I, img_R,'Scaling','joint');
    title('Overlapped Registered Image')
%%
    pause(1) 
end 
%% End of file
