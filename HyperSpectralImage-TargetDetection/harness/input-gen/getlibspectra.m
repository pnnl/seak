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

function lib_spectra = getlibspectra(lib_spectra);

lib_spectra{01} = '..\data\cement_solid_0432_spectrum.txt';
lib_spectra{02} = '..\data\concrete_paving_0424_spectrum.txt';
lib_spectra{03} = '..\data\roofing_metal_solid_0682_spectrum.txt';
lib_spectra{04} = '..\data\roofing_paper_solid_0523_spectrum.txt';
lib_spectra{05} = '..\data\wood_solid_0404_spectrum.txt';

lib_spectra{06} = '..\data\rock_sed_dolomite_350_spectrum.txt';
lib_spectra{07} = '..\data\rock_sed_shale_002_spectrum.txt';
%lib_spectra{08} = '..\data\rock_sed_shale_005_spectrum.txt';
lib_spectra{08} = '..\data\rock_sed_siliceous_w57_spectrum.txt';
%lib_spectra{09} = '..\data\rock_sed_shale_009_spectrum.txt';
lib_spectra{10} = '..\data\rock_sed_shale_011_spectrum.txt';
%lib_spectra{09} = '..\data\rock_sed_siliceous_77_spectrum.txt';
lib_spectra{09} = '..\data\rock_sed_siliceous_w77_spectrum.txt';

lib_spectra{11} = '..\data\rock_sed_dolomite_350_spectrum.txt';
lib_spectra{12} = '..\data\rock_sed_limstone_350_spectrum.txt';
lib_spectra{13} = '..\data\rock_sed_limstone_397_spectrum.txt';
lib_spectra{14} = '..\data\rock_sed_limstone_397_spectrum.txt';
lib_spectra{15} = '..\data\rock_sed_limstone_397_spectrum.txt';

end