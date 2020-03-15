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
%% this file contains additional function to generate 
%% the hyperspectral datacube
%% Script to creat Hyperspectral datacube

% get interpolated data for specified range/s
function data_portions_inter = getdatinter(data_portions_inter, ...
    one_cube,num_spectra, num_spectra_portions,labmda_portions, ...
    size_set, num_data_portions);

for K = 1:num_spectra
   num_counter = 0; 
   for portion = 1:num_spectra_portions
       delta_wavelength = ...
               ( labmda_portions(portion,2) - labmda_portions(portion,1) ) ...
               / num_data_portions(portion);
       for num_d_por = 0:num_data_portions(portion)
           num_counter = num_counter + 1;
           req_wl = labmda_portions(portion,1) + ...
               num_d_por * delta_wavelength;
           % find two data points on input spectra for interpolation
           % at req_wavelength location
           for dat = 1:size_set
               if (one_cube(dat,1,K) <= req_wl)
                   low_wl = one_cube(dat,1,K);
                   low_wl_num = dat;
               end            
           end
           for dat = 1:(size_set -1)
               if (one_cube(dat,1,K) == low_wl & ...
                       req_wl <= one_cube((dat+1),1,K) )
                   high_wl = one_cube((dat+1),1,K);
                   high_wl_num = dat+1;
               end            
           end
           % interpolate values
           value = one_cube((low_wl_num),2,K) + ...
               (high_wl - low_wl) * (req_wl - low_wl) * ...
               (one_cube((high_wl_num),2,K) - one_cube((low_wl_num),2,K) );
           % fill values into data_portions_inter
           data_portions_inter(num_counter,1,K) = req_wl;
           data_portions_inter(num_counter,2,K) = value;
       end
   end
end

end 

