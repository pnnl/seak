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

%%compute mean and variance of images
function SAR_check()
I=imread('../inout/SAR_input_target.png');
WF=imread('../inout/SAR_WF_image_cropped.png');
RS=imread('../inout/SAR_RS_image_cropped.png');
TD=imread('../inout/SAR_TD_image_cropped.png');
BP=imread('../inout/SAR_BP_image_cropped.png');

[I_mean, I_var] = mean_var(I);
[WF_mean, WF_var] = mean_var(WF);
[RS_mean, RS_var] = mean_var(RS);
[TD_mean, TD_var] = mean_var(TD);
[BP_mean, BP_var] = mean_var(BP);

WF_PSNR = SNR(I, WF);
RS_PSNR = SNR(I, RS);
TD_PSNR = SNR(I, TD);
BP_PSNR = SNR(I, BP); 


fprintf('Mean of input image = %f\n', I_mean);
fprintf('Variance of input image = %f\n', I_var);
fprintf('\n');
fprintf('Mean of Wavefront spotlight SAR image = %f\n', WF_mean);
fprintf('Variance of Wavefront spotlight SAR image = %f\n', WF_var);
fprintf('Peak Signal to Noise Ratio (PSNR) of Wavefront spotlight SAR image = %f\n', WF_PSNR);
fprintf('\n');
fprintf('Mean of Range Stack Wavefront spotlight SAR image = %f\n', RS_mean);
fprintf('Variance of Range Stack Wavefront spotlight SAR image = %f\n', RS_var);
fprintf('Peak Signal to Noise Ratio (PSNR) of Range Stack Wavefront spotlight SAR image = %f\n', RS_PSNR);
fprintf('\n');
fprintf('Mean of Time Domain Correlation spotlight SAR image = %f\n', TD_mean);
fprintf('Variance of Time Domain Correlation spotlight SAR image = %f\n', TD_var);
fprintf('Peak Signal to Noise Ratio (PSNR) of Time Domain Correlation spotlight SAR image = %f\n', TD_PSNR);
fprintf('\n');
fprintf('Mean of Backprojection spotlight SAR image = %f\n', BP_mean);
fprintf('Variance of Backprojection spotlight SAR image = %f\n', BP_var);
fprintf('Peak Signal to Noise Ratio (PSNR) of Backprojection spotlight SAR image = %f\n', BP_PSNR);
fprintf('\n');
end % end of function

function [mean, var] = mean_var(img)

mean = sum(img(:)) / length(img(:));
var = sum((img(:) - mean).^2)/(length(img(:))-1);
end

function PSNR = SNR(I, R)
[M N] = size(I); 
img_I = rgb2gray(I);
img_R = rgb2gray(R);

imgd_I = double(img_I);
imgd_R = double(img_R);
error = imgd_I - imgd_R;
MSE = sum(sum(error .* error)) / (M * N);
%error = imgd_I(M/4:M*3/4,N/4:M*3/4) - imgd_R(M/4:M*3/4,N/4:M*3/4);
%MSE = sum(sum(error .* error)) / (M*N / 4);
if(MSE > 0)
    PSNR = 10*log(255*255/MSE) / log(10);
else
    PSNR = 120;
end 

end