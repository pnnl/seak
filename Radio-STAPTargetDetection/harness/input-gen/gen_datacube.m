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

%% Matlab script for Space Time Adaptive Processing 
%% Created by Nitin A. Gawande, PNNL, dated 2016-02-16 
%% modified Nitin A. GAwande 2016-06-17
%% this file contains the main function to generate 
%% the STAP RADAR datacube
%% This script uses Matlab Phased Array System Toolbox
close all
%
%%Set input Problem size
% input_size = 'small'
input_size = 'medium'
% input_size = 'large'
%
if isequal(input_size,'small')
    fs = 1e7; % Sampling frequency
    my_num_channels=8; % Number of Channels 
    NumPulses = 10; % Number of Pulses
    NumTrainingCells = 512; % Number of Training Cells for ADPCA processing
    NumGuardCells = 4;
    PRF = 5.0e3;
elseif isequal(input_size,'medium')
    fs = 1e7;
    my_num_channels=10;
    NumPulses = 16;
    NumTrainingCells = 800;
    NumGuardCells = 6;
    PRF = 5.0e3;
elseif isequal(input_size,'large')
    fs = 2e7;
    my_num_channels=12;
    NumPulses = 24;
    NumTrainingCells = 2400;
    NumGuardCells = 8;
    PRF = 5.0e3;
end
%
fc = 4e9; 
c = physconst('LightSpeed');
hant = phased.IsotropicAntennaElement...
    ('FrequencyRange',[8e8 5e9],'BackBaffled',true); % number in [] is operating range
lambda = c/fc;

hula = phased.ULA(my_num_channels,'Element',hant,'ElementSpacing',lambda/2);
hwav = phased.RectangularWaveform('PulseWidth',5e-7,...
    'PRF',PRF,'SampleRate',fs,'NumPulses',1);
hrad = phased.Radiator('Sensor',hula,...
    'PropagationSpeed',c,...
    'OperatingFrequency',fc);
hcol = phased.Collector('Sensor',hula,...
    'PropagationSpeed',c,...
    'OperatingFrequency',fc);
vy = (hula.ElementSpacing * PRF)/2;
htxplat = phased.Platform('InitialPosition',[0;0;3e3],...
    'Velocity',[0;vy;0]);
hclutter = phased.ConstantGammaClutter('Sensor',hula,...
    'PropagationSpeed',hrad.PropagationSpeed,...
    'OperatingFrequency',hrad.OperatingFrequency,...
    'SampleRate',fs,...
    'TransmitSignalInputPort',true,...
    'PRF',PRF,...
    'Gamma',surfacegamma('woods',hrad.OperatingFrequency),...
    'EarthModel','Flat',...
    'BroadsideDepressionAngle',0,...
    'MaximumRange',hrad.PropagationSpeed/(2*PRF),...
    'PlatformHeight',htxplat.InitialPosition(3),...
    'PlatformSpeed',norm(htxplat.Velocity),...
    'PlatformDirection',[90;0]);
htgt = phased.RadarTarget('MeanRCS',1,...
    'Model','Nonfluctuating','OperatingFrequency',fc);
htgtplat = phased.Platform('InitialPosition',[10e3; 10e3; 0],...
    'Velocity',[15;15;0]);
hspace = phased.FreeSpace('OperatingFrequency',fc,...
    'TwoWayPropagation',false,'SampleRate',fs);
hrx = phased.ReceiverPreamp('NoiseFigure',0,...
    'EnableInputPort',true,'SampleRate',fs,'Gain',40);
htx = phased.Transmitter('PeakPower',1e4,...
    'InUseOutputPort',true,'Gain',40);
%
hjammerpath = phased.FreeSpace('TwoWayPropagation',false,...
    'SampleRate',fs,'OperatingFrequency', fc);

wav = step(hwav);
M = fs/PRF;
N = hula.NumElements;
rxsig = zeros(M,N,NumPulses);
rtsig = zeros(M,N,NumPulses);
csig = zeros(M,N,NumPulses);
jsig = zeros(M,N,NumPulses); % Jammer param
rxtjsig = zeros(M,N,NumPulses);
fasttime = unigrid(0,1/fs,1/PRF,'[)');
rangebins = (c * fasttime)/2;
hclutter.SeedSource = 'Property';
hclutter.Seed = 5;

hjammer = phased.BarrageJammer('ERP',100); % Jammer param
hjammer.SamplesPerFrame = numel(rangebins); % Jammer param
hjammerPlatform = phased.Platform('InitialPosition',[4e3; 3e3; 1000]); %Jammer param

for n = 1:NumPulses
    [txloc,txvel] = step(htxplat,1/PRF); % move transmitter
    [tgtloc,tgtvel] = step(htgtplat,1/PRF); % move target
    [~,tgtang] = rangeangle(tgtloc,txloc); % get angle to target

    [jampos,jamvel] = step(hjammerPlatform,1/PRF); % Jammer param
    [~,jammerang] = rangeangle(jampos,txloc); % Jammer param
    
    [txsig1,txstatus] = step(htx,wav);  % transmit pulse
    csig(:,:,n) = step(hclutter,txsig1(abs(txsig1)>0)); % collect clutter
    txsig = step(hrad,txsig1,tgtang); % radiate pulse
    txsig = step(hspace,txsig,txloc,tgtloc,...
       txvel,tgtvel); % propagate to target
    txsig = step(htgt,txsig);  % reflect off target
    txsig = step(hspace,txsig,tgtloc,txloc,...
       tgtvel,txvel); % propagate to array
    rxsig(:,:,n) = step(hcol,txsig,tgtang); % collect pulse
   
    jamsig = step(hjammer);                             % Generate jammer
    jamsig = step(hjammerpath,jamsig,jampos,txloc,...
        jamvel,txvel);                               % Propagate jammer
    jsig(:,:,n) = step(hcol,jamsig,jammerang);    % Collect jammer

    rxsig(:,:,n) = step(hcol,txsig,tgtang); % collect pulse
    rtsig(:,:,n) = rxsig(:,:,n); % only target return
    rxsig(:,:,n) = step(hrx,rxsig(:,:,n) + csig(:,:,n),...
		~txstatus); % receive pulse plus clutter return
    rxtjsig(:,:,n) = step(hrx,rxsig(:,:,n) + csig(:,:,n) + jsig(:,:,n),...
		~txstatus); % receive pulse plus clutter plus jammer return
end
%%Write datacube to file
outfile_name = strcat('../inout/radar_datacube_',input_size);
out_file = fopen(outfile_name,'w');
fwrite(out_file,[real(rxtjsig);imag(rxtjsig)],'float64','n');
fclose(out_file);
%