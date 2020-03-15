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
%	 Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan
%	 R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK
%	 Specification." Pacific Northwest National Laboratory. May,
%	 2016, http://hpc.pnnl.gov/SEAK/
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
%% Created by Nitin A. Gawande, PNNL, dated 2016-04-26
%% modified Nitin A. GAwande 2016-04-27
%% this file computes correctness metrics SAM
%% mu1.txt is the reference spectrum file
%% X1.txt is the extracted spectrum file
%%
clear

ref_spectra_file = '..\inout\mu1.txt';
extracted_spectra_file = '..\inout\X1.txt';

ref_data = load(ref_spectra_file);
ext_data = load(extracted_spectra_file);

[Nr1 Nr2] = size(ref_data);
[Nx1 Nx2] = size(ext_data);


numerator = dot(ref_data, ext_data)

[sum_r, n_x] = sumsqr(ref_data);
[sum_x, n_x] = sumsqr(ext_data);

% denominator = sqrt(sum_r * sum_x)
denominator = sqrt(sum_r) * sqrt(sum_x)

SAM = acos(numerator / denominator)
