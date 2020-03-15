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

% Script to plot library spectra 
function plotinputspecs(num_spectra,one_cube,files)

figure
% plot(   lambda_reflectance_01(:,1), lambda_reflectance_01(:,2), ...
%         lambda_reflectance_02(:,1), lambda_reflectance_02(:,2) ...
% );

color_vec = hsv(5);
box on;
hold on;
for K = 1:num_spectra
p1(K) = plot( one_cube(:,1,K), one_cube(:,2,K), 'color', color_vec(K,:)); 
end
xlabel({'Wavelength','(micrometer)'});
ylabel({'Reflectance','(Percent)'});
legend_text = files;
%legend(p1,strrep(legend_text, '_', '\_'),'Location', 'East'); 
legend(p1,legend_text, 'Location', 'East'); 
%legend(p1,legend_text); 
hold off;

end %end of function plotinputspecs