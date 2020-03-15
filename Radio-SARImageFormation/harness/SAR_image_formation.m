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

% This harness implementation of spotlight SAR is based 
% on the matlab code provided at mathworks.com
% Suitable modifications have been to create SAR signal using
%   the input images of target or target point locations
%% Source of original matlab code
% http://www.mathworks.com/matlabcentral/fileexchange/
% 2188-synthetic-aperture-radar-signal-processing-with-
% matlab-algorithms/content/soumekh/spotlight.m
% Copyright (c) 2016, Mehrdad Soumekh
% All rights reserved.
%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %   PULSED SPOTLIGHT SAR SIMULATION AND RECONSTRUCTION   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function SAR_image_formation01
clear all

% Custom color map
n_c = 300;               %// number of colors
%c=mycolormap(n_c);
colormap(gray(256))
%%
%Set input Image size
input_size = 'small'
input_size = 'medium'
%input_size = 'large'
if isequal(input_size,'small')
    %target_file_name = 'targinp1'; %Target image file name
    %target_file_name = 'target_name_11'; %Target image file name
    target_file_name = 'data/Airplane32'; %Target image file name
    %
    Xc=1000;                 % Range distance to center of target area
    X0=32;                   % target area in range is within [Xc-X0,Xc+X0]
    Yc=300;                  % Cross-range distance to center of target area
    Y0=64;                   % target area in cross-range is within
                             % [Yc-Y0,Yc+Y0]
elseif isequal(input_size,'medium')
    Xc=1200;                 % Range distance to center of target area
    X0=40;                   % target area in range is within [Xc-X0,Xc+X0]
    Yc=400;                  % Cross-range distance to center of target area
    Y0=80;                   % target area in cross-range is within
                             % [Yc-Y0,Yc+Y0]
    %target_file_name = 'input/Airplane32'; %Target image file name
    target_file_name = 'data/Airplane64'; %Target image file name    
elseif isequal(input_size,'large')
    Xc=1600;                 % Range distance to center of target area
    X0=80;                   % target area in range is within [Xc-X0,Xc+X0]
    Yc=600;                  % Cross-range distance to center of target area
    Y0=160;                   % target area in cross-range is within
                             % [Yc-Y0,Yc+Y0]
    target_file_name = 'data/Airplane128'; %Target image file name    
end
%%
% System Model Parameters
cj=sqrt(-1);
pi2=2*pi;
%
c=3e8;                   % propagation speed
f0=25e6;                 % baseband bandwidth is 2*f0
w0=pi2*f0;
fc=800e6;                % carrier frequency
wc=pi2*fc;
lambda_min=c/(fc+f0);    % Wavelength at highest frequency
lambda_max=c/(fc-f0);    % Wavelength at lowest frequency
kc=(pi2*fc)/c;           % wavenumber at carrier frequency
kmin=(pi2*(fc-f0))/c;    % wavenumber at lowest frequency
kmax=(pi2*(fc+f0))/c;    % wavenumber at highest frequency
%
% Xc=1000;                 % Range distance to center of target area
% X0=20;                   % target area in range is within [Xc-X0,Xc+X0]
% Yc=300;                  % Cross-range distance to center of target area
% Y0=60;                  % target area in cross-range is within
%                          % [Yc-Y0,Yc+Y0]

% Case 1: L < Y0; requires zero-padding of SAR signal in synthetic
% aperture domain
%
  L=100;                 % synthetic aperture is 2*L

% Case 2: L > Y0; slow-time Doppler subsampling of SAR signal spectrum
% reduces computation
%
% L=400;                 % synthetic aperture is 2*L

theta_c=atan(Yc/Xc);     % Squint angle
Rc=sqrt(Xc^2+Yc^2);      % Squint radial range
L_min=max(Y0,L);         % Zero-padded aperture is 2*L_min

%
Xcc=Xc/(cos(theta_c)^2); % redefine Xc by Xcc for squint processing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% u domain parameters and arrays for compressed SAR signal %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
duc=(Xcc*lambda_min)/(4*Y0);      % sample spacing in aperture domain
                                  % for compressed SAR signal
duc=duc/1.2;                      % 10 percent guard band; this guard band
                                  % would not be sufficient for targets
                                  % outside digital spotlight filter (use
                                  % a larger guard band, i.e., PRF)
mc=2*ceil(L_min/duc);             % number of samples on aperture
uc=duc*(-mc/2:mc/2-1);            % synthetic aperture array
dkuc=pi2/(mc*duc);                % sample spacing in ku domain
kuc=dkuc*(-mc/2:mc/2-1);          % kuc array
%
dku=dkuc;                         % sample spacing in ku domain

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    u domain parameters and arrays for SAR signal     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if Yc-Y0-L < 0,                            % minimum aspect angle
 theta_min=atan((Yc-Y0-L)/(Xc-X0));
else,
 theta_min=atan((Yc-Y0-L)/(Xc+X0));
end;
theta_max=atan((Yc+Y0+L)/(Xc-X0));         % maximum aspect angle
%
du=pi/(kmax*(sin(theta_max)- ...
                     sin(theta_min))); % sample spacing in aperture
                                       % domain for SAR signal
du=du/1.4;                        % 20 percent guard band
m=2*ceil(pi/(du*dku));            % number of samples on aperture
du=pi2/(m*dku);                   % readjust du
u=du*(-m/2:m/2-1);                % synthetic aperture array
ku=dku*(-m/2:m/2-1);              % ku array

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Fast-time domain parmeters and arrays          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
Tp=2.5e-7;                     % Chirp pulse duration
alpha=w0/Tp;                   % Chirp rate
wcm=wc-alpha*Tp;               % Modified chirp carrier
%
if Yc-Y0-L < 0,
 Rmin=Xc-X0;
else,
 Rmin=sqrt((Xc-X0)^2+(Yc-Y0-L)^2);
end;
Ts=(2/c)*Rmin;                 % start time of sampling
Rmax=sqrt((Xc+X0)^2+(Yc+Y0+L)^2);
Tf=(2/c)*Rmax+Tp;              % end time of sampling
T=Tf-Ts;                       % fast-time interval of measurement
Ts=Ts-.1*T;                    % start slightly earlier (10% guard band)
Tf=Tf+.1*T;                    % end slightly later (10% guard band)
T=Tf-Ts;
Tmin=max(T,(4*X0)/(c*cos(theta_max)));  % Minimum required T
%
dt=1/(4*f0);                 % Time domain sampling (guard band factor 2)
n=2*ceil((.5*Tmin)/dt);      % number of time samples
t=Ts+(0:n-1)*dt;             % time array for data acquisition
dw=pi2/(n*dt);               % Frequency domain sampling
w=wc+dw*(-n/2:n/2-1);        % Frequency array (centered at carrier)
k=w/c;                       % Wavenumber array
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resolution for Broadside: (x,y) domain rotated by theta_c %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DX=c/(4*f0);                      % range resolution (broadside)
DY=(Xcc*lambda_max)/(4*L);         % cross-range resolution (broadside)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           Parameters of Targets                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Generate target input image
input_im = zeros(2*X0,2*Y0);
%  
[X,map] = imread(target_file_name,'gif');
target = ind2gray(X,map);
[N M] = size(target);
% uncomment below for alternative way of generating input image
ntarget = N*M; %Number of targets is equal to size of image
% xn: range;            yn= cross-range;    fn: reflectivity
xn=zeros(1,ntarget);  yn=xn;              fn=xn;

% Embed target image into input image
r1 = floor((2*X0-N)/2);
c1 = floor((2*Y0-M)/2);
%r2 = r1 + N - 1;
%c2 = c1 + M - 1;
%input_im(r1:r2, c1:c2) = target;
intensity_red_fac = 0.1;
t_number = 1;
for row = [1:2:N]
    for col = [1:1:M]
        xn(t_number) = row + r1 - 1;
        yn(t_number) = col + c1 - 1;
        x_t_n = xn(t_number);
        y_t_m = yn(t_number);
        xn(t_number) = xn(t_number) - X0;
        yn(t_number) = yn(t_number) - Y0;
        fn(t_number) = double(target(row,col))/255 * intensity_red_fac;
        if (x_t_n>0 && x_t_n<=n && y_t_m>0 && y_t_m<=m)
            input_im(x_t_n,y_t_m) = fn(t_number);
        end
        t_number = t_number+1;
    end
end
%
G=abs(input_im)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
%image(n,m,256-cg*(G-ng));
input_img = image(2*X0,2*Y0,256-cg*(G-ng));
%input_img = image(xn,yn,256-cg*(G-ng));
axis off
% oldscreenunits = get(gcf,'Units')
% oldpaperunits = get(gcf,'PaperUnits')
% oldpaperpos = get(gcf,'PaperPosition')
ratio_x = ceil(X0);
ratio_y = ceil(Y0/X0*ratio_x);
set(gcf,'PaperPosition',[0.25 0.25 ratio_x ratio_y])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_input_target','-dpng','-r2');
%saveas(gcf,'inout/SAR_input_target.png')
%size(input_im)
fprintf('size of input image input_im = %d x %d\n', size(input_im));
fprintf('size of input image input_img = %d x %d\n', (n), (m));
%return
axis on
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
%return   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                   SIMULATION                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
s=zeros(n,mc);     % SAR signal array
%
for i=1:ntarget;   % Loop for each target
 td=t(:)*ones(1,mc)-2*ones(n,1)*sqrt((Xc+xn(i)).^2+(Yc+yn(i)-uc).^2)/c;
 s=s+fn(i)*exp(cj*wcm*td+cj*alpha*(td.^2)).*(td >= 0 & td <= Tp & ...
   ones(n,1)*abs(uc) <= L & t(:)*ones(1,mc) < Tf);
end;
%
s=s.*exp(-cj*wc*t(:)*ones(1,mc));      % Fast-time baseband conversion

% User may apply a slow-time domain window, e.g., power window, on
% simulated SAR signal array "s" here.

G=abs(s)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(t,uc,256-cg*(G-ng));
axis('square');axis('xy')
xlabel('Fast-time t, sec')
ylabel('Synthetic Aperture (Slow-time) U, meters')
title('Measured Spotlight SAR Signal')
%print P5.1.ps
print('inout/P5-1','-dpng')
pause(1)
%

td0=t(:)-2*sqrt(Xc^2+Yc^2)/c;
s0=exp(cj*wcm*td0+cj*alpha*(td0.^2)).*(td0 >= 0 & td0 <= Tp);
s0=s0.*exp(-cj*wc*t(:));            % Baseband reference fast-time signal

s=ftx(s).*(conj(ftx(s0))*ones(1,mc));  % Fast-time matched filtering
%
G=abs(iftx(s))';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
tm=(2*Rc/c)+dt*(-n/2:n/2-1);    % fast-time array after matched filtering
image(tm,uc,256-cg*(G-ng));
axis('square');axis('xy')
xlabel('Fast-time t, sec')
ylabel('Synthetic Aperture (Slow-time) U, meters')
title('SAR Signal after Fast-time Matched Filtering')
%print P5.2.ps
print('inout/P5-2','-dpng')
pause(1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Slow-time baseband conversion for squint %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
kus=2*kc*sin(theta_c)*ones(1,n);     % Doppler frequency shift in ku
                                     % domain due to squint
%
s=s.*exp(-cj*kus(:)*uc);             % slow-time baseband conversion
fs=fty(s);

% Display aliased SAR spectrum
%
G=abs(fs)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(k*c/pi2,kuc,256-cg*(G-ng));
axis('square');axis('xy')
xlabel('Fast-time Frequency, Hertz')
ylabel('Synthetic Aperture (Slow-time) Frequency Ku, rad/m')
title('Aliased Spotlight SAR Signal Spectrum')
%print P5.3.ps
print('inout/P5-3','-dpng')
pause(1)

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Digital Spotlighting and Bandwidth Expansion in ku Domain  %%
%%          via Slow-time Compression and Decompression        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
s=s.*exp(cj*kus(:)*uc);      % Original signal before baseband
                             % conversion for squint

cs=s.*exp(cj*2*(k(:)*ones(1,mc)).* ...      
 (ones(n,1)*sqrt(Xc^2+(Yc-uc).^2))-cj*2*k(:)*Rc*ones(1,mc));% compression
fcs=fty(cs);            % F.T. of compressed signal w.r.t. u
%
G=abs(fcs)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(k*c/pi2,kuc,256-cg*(G-ng));
axis('square');axis('xy')
xlabel('Fast-time Frequency, Hertz')
ylabel('Synthetic Aperture (Slow-time) Frequency Ku, rad/m')
title('Compressed Spotlight SAR Signal Spectrum')
%print P5.4.ps
print('inout/P5-4','-dpng')
pause(1)
%
fp=iftx(fty(cs));      % Narrow-bandwidth Polar Format Processed
                       % reconstruction
%
PH=asin(kuc/(2*kc));   % angular Doppler domain
R=(c*tm)/2;            % range domain mapped from reference
                       % fast-time domain
%
% Full Aperture Digital-Spotlight Filter
%
W_d=((abs(R(:)*cos(PH+theta_c)-Xc) < X0).* ...
    (abs(R(:)*sin(PH+theta_c)-Yc) < Y0));
%
G=(abs(fp)/max(max(abs(fp)))+.1*W_d)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image((Rc/Xc)*(.5*c*tm-Rc),(kuc*Rc)/(2*kc),256-cg*(G-ng));
xlabel('Range x, m')
ylabel('Cross-range y, m')
title('Polar Format SAR Reconstruction with Digital Spotlight Filter')
axis image; axis xy;
%print P5.5.ps
print('inout/P5-5','-dpng')
pause(1)

fd=fp.*W_d;                % Digital Spotlight Filtering
fcs=ftx(fd);               % Transform to (omega,ku) domain

% Zero-padding in ku domain for slow-time upsampling
%
mz=m-mc;        % number is zeros
fcs=(m/mc)*[zeros(n,mz/2),fcs,zeros(n,mz/2)];
%
cs=ifty(fcs);              % Transform to (omega,u) domain

s=cs.*exp(-cj*2*(k(:)*ones(1,m)).* ...      
 (ones(n,1)*sqrt(Xc^2+(Yc-u).^2))+cj*2*k(:)*Rc*ones(1,m));% decompression


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           CAUTION                             %
% For TDC or backprojection, do not subsample in Doppler domain %
% and do not perform slow-time baseband conversion               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
s_ds=s;                    % Save s(omega,u) array for TDC and
                           % backprojection algorithms

%
s=s.*exp(-cj*kus(:)*u);    % Slow-time baseband conversion for squint
fs=fty(s);                 % Digitally-spotlighted SAR signal spectrum
%
G=abs(fs)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(k*c/pi2,ku,256-cg*(G-ng));
axis('square');axis('xy')
xlabel('Fast-time Frequency, Hertz')
ylabel('Synthetic Aperture (Slow-time) Frequency Ku, rad/m')
title('Spotlight SAR Signal Spectrum after DS & Upsampling')
%print P5.6.ps
print('inout/P5-6','-dpng')
pause(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    SLOW-TIME DOPPLER SUBSAMPLING     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if Y0 < L,
 ny=2*ceil(1.2*Y0/du);      % Number of samples in y domain
                            % 20 percent guard band
 ms=floor(m/ny);            % subsampling ratio
 tt=floor(m/(2*ms));
 I=m/2+1-tt*ms:ms:m/2+1+(tt-1)*ms; % subsampled index in ku domain
 [tt,ny]=size(I);           % number of subsamples
 fs=fs(:,I);                % subsampled SAR signal spectrum
 ky=ku(I);                  % subsampled ky array
 dky=dku*ms;                % ky domain sample spacing
else,
 dky=dku;
 ny=m;
 ky=ku;
end;

dy=pi2/(ny*dky);            % y domain sample spacing
y=dy*(-ny/2:ny/2-1);        % cross-range array

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%             RECONSTRUCTION           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
ky=ones(n,1)*ky+kus(:)*ones(1,ny);       % ky array
kx=(4*k(:).^2)*ones(1,ny)-ky.^2;
kx=sqrt(kx.*(kx > 0));                  % kx array
%
plot(kx(1:20:n*ny),ky(1:20:n*ny),'.')
xlabel('Spatial Frequency k_x, rad/m')
ylabel('Spatial Frequency k_y, rad/m')
title('Spotlight SAR Spatial Frequency Data Coverage')
axis image; axis xy
%print P5.7.ps
print('inout/P5-7','-dpng')
pause(1)
%
kxmin=min(min(kx));
kxmax=max(max(kx));
dkx=pi/X0;        % Nyquist sample spacing in kx domain
nx=2*ceil((.5*(kxmax-kxmin))/dkx); % Required number of
                      % samples in kx domain;
                      % This value will be increased slightly
                      % to avoid negative array index
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                         %%%
%%%   FIRST TWO OPTIONS FOR RECONSTRUCTION:                 %%%
%%%                                                         %%%
%%%     1. 2D Fourier Matched Filtering and Interpolation   %%%
%%%     2. Range Stacking                                   %%%
%%%                                                         %%%
%%%     Note: For "Range Stacking," make sure that the      %%%
%%%           arrays nx, x, and kx are defined.             %%%
%%%                                                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    2D FOURIER MATCHED FILTERING AND INTERPOLATION    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Matched Filtering
%
fs0=(kx > 0).*exp(cj*kx*Xc+cj*ky*Yc+cj*.25*pi ...
           -cj*2*k(:)*ones(1,ny)*Rc); % reference signal complex conjugate
fsm=fs.*fs0;     % 2D Matched filtering

% Interpolation
%
is=8;       % number of neighbors (sidelobes) used for sinc interpolator
I=2*is+1;
kxs=is*dkx; % plus/minus size of interpolation neighborhood in KX domain
%
nx=nx+2*is+4;  % increase number of samples to avoid negative
               %  array index during interpolation in kx domain
KX=kxmin+(-is-2:nx-is-3)*dkx;     % uniformly-spaced kx points where
                                  % interpolation is done
kxc=KX(nx/2+1);                   % carrier frequency in kx domain
KX=KX(:)*ones(1,ny);
%
F=zeros(nx,ny);         % initialize F(kx,ky) array for interpolation

for i=1:n;                       % for each k loop
  i                              % print i to show that it is running
 icKX=round((kx(i,:)-KX(1,1))/dkx)+1; % closest grid point in KX domain
 cKX=KX(1,1)+(icKX-1)*dkx;            % and its KX value
 ikx=ones(I,1)*icKX+[-is:is]'*ones(1,ny);
 ikx=ikx+nx*ones(I,1)*[0:ny-1];
 nKX=KX(ikx);
 SINC=sinc((nKX-ones(I,1)*kx(i,:))/dkx);             % interpolating sinc
 HAM=.54+.46*cos((pi/kxs)*(nKX-ones(I,1)*kx(i,:)));  % Hamming window
         %%%%%   Sinc Convolution (interpolation) follows  %%%%%%%%
 F(ikx)=F(ikx)+(ones(I,1)*fsm(i,:)).*(SINC.*HAM);
end
%
%  DISPLAY interpolated spatial frequency domain image F(kx,ky)

KX=KX(:,1).';
KY=ky(1,:);

G=abs(F)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(KX,KY+kus(1),256-cg*(G-ng));
axis image; axis xy
xlabel('Spatial Frequency k_x, rad/m')
ylabel('Spatial Frequency k_y, rad/m')
title('Wavefront Spotlight SAR Reconstruction Spectrum')
%print P5.8.ps
print('inout/P5-8','-dpng')
pause(1)

%
f=iftx(ifty(F));     % Inverse 2D FFT for spatial domain image f(x,y)
%
dx=pi2/(nx*dkx);     % range sample spacing in reconstructed image
x=dx*(-nx/2:nx/2-1); % range array
%
% Display SAR reconstructed image

G=abs(f)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(Xc+x,Yc+y,256-cg*(G-ng));axis([Xc-X0 Xc+X0 Yc-Y0 Yc+Y0]);
axis image; axis xy
xlabel('Range X, meters')
ylabel('Cross-range Y, meters')
title('Wavefront Spotlight SAR Reconstruction')
%print P5.9.ps
print('inout/P5-9','-dpng')
pause(1)
image(x,y,256-cg*(G-ng));%axis([Xc-X0 Xc+X0 -Y0 Y0]);
axis off
par_a = ceil(size(x,2));
par_b = ceil(size(y,2));
par_a = ceil(abs(max(x)-min(x))/4);
par_b = ceil(abs(max(y)-min(y))/4);
set(gcf,'PaperPosition',[0.25 0.25 par_a par_b])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_WF_image','-dpng','-r2');
pause(1)
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on
fprintf('size of SAR_WF_IMAGE = %d x %d\n', size(x,2), size(y,2));

%SAR image cropped image
G=abs(f)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
ICin = image(x,y,256-cg*(G-ng));
size(ICin)
par_a = size(ICin,2) * 2*X0 / abs(max(x)-min(x));
par_b = size(ICin,1) * 2*Y0 / abs(max(y)-min(y));
xc1 = max( 1, ceil((size(ICin,2)-par_a)/2) );
xc2 = ceil(par_a);
yc1 = max( 1, ceil((size(ICin,1)-par_b)/2) );
yc2 = ceil(par_b);
ICout = imcrop(ICin,[xc1 yc1 xc2 yc2]);axis([-X0 X0 -Y0 Y0]);

axis off
set(gcf,'PaperPosition',[0.25 0.25 ceil(X0) ceil(Y0)])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_WF_image_cropped','-dpng','-r2');
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on

%return
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   SAR Image Compression (for Spotlight System)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
Fc=ftx(fty(f.* ...
  exp(cj*kxc*x(:)*ones(1,ny)+cj*ones(nx,1)*2*kc*sin(theta_c)*y ...
 -cj*2*kc*sqrt(((Xc+x(:)).^2)*ones(1,ny)+ones(nx,1)*((Yc+y).^2)))));
G=abs(Fc)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(KX,KY+kus(1),256-cg*(G-ng));
axis image; axis xy
xlabel('Spatial Frequency k_x, rad/m')
ylabel('Spatial Frequency k_y, rad/m')
title('Compressed Spotlight SAR Reconstruction Spectrum')
%print P5.10.ps
print('inout/P5-10','-dpng')
pause(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%      RANGE STACK WAVEFRONT RECONSTRUCTION       %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
f_stack=zeros(nx,ny); % Initialize reconstruction array in (x,y) domain
for i=1:nx; i        % Stack's loop for reconstruction at each range
 f_stack(i,:)=ifty(sum(fs.*exp(cj*kx*(Xc+x(i))+cj*ky*Yc ...
  +cj*.25*pi-cj*2*k(:)*ones(1,ny)*Rc)));
end;

% Remove carrier in range domain
f_stack=f_stack.*exp(-cj*x(:)*kxc*ones(1,ny));
%
f_stack=f_stack/nx; % Scale it for comparison with Fourier interpolation
                    % Use "f_stack-f" to display difference of two
                    % reconstructions
           
G=abs(f_stack)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(Xc+x,Yc+y,256-cg*(G-ng));axis([Xc-X0 Xc+X0 Yc-Y0 Yc+Y0]);
axis image; axis xy
xlabel('Range X, meters')
ylabel('Cross-range Y, meters')
title('Range Stack Spotlight SAR Reconstruction')
%print P5.11.ps
print('inout/P5-11','-dpng')
pause(1)
image(x,y,256-cg*(G-ng));%axis([Xc-X0 Xc+X0 -Y0 Y0]);
axis off
par_a = ceil(size(x,2));
par_b = ceil(size(y,2));
par_a = ceil(abs(max(x)-min(x))/4);
par_b = ceil(abs(max(y)-min(y))/4);
set(gcf,'PaperPosition',[0.25 0.25 par_a par_b])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_RS_image','-dpng','-r2');
pause(1)
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on
fprintf('size of SAR_RS_IMAGE = %d x %d\n', size(x,2), size(y,2));

%SAR image cropped image
G=abs(f_stack)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
ICin = image(x,y,256-cg*(G-ng));
size(ICin)
par_a = size(ICin,2) * 2*X0 / abs(max(x)-min(x));
par_b = size(ICin,1) * 2*Y0 / abs(max(y)-min(y));
xc1 = max( 1, ceil((size(ICin,2)-par_a)/2) );
xc2 = ceil(par_a);
yc1 = max( 1, ceil((size(ICin,1)-par_b)/2) );
yc2 = ceil(par_b);
ICout = imcrop(ICin,[xc1 yc1 xc2 yc2]);axis([-X0 X0 -Y0 Y0]);

axis off
set(gcf,'PaperPosition',[0.25 0.25 ceil(X0) ceil(Y0)])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_RS_image_cropped','-dpng','-r2');
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on

%return

F_stack=ftx(fty(f_stack)); % Reconstruction array in spatial frequency
                           % domain; Use "F_stack-F" to display
                           %  difference of two reconstructions
%
G=abs(F_stack)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(KX,KY+kus(1),256-cg*(G-ng));
axis image; axis xy
xlabel('Spatial Frequency k_x, rad/m')
ylabel('Spatial Frequency k_y, rad/m')
title('Range Stack Spotlight SAR Reconstruction Spectrum')
%print P5.12.ps
print('inout/P5-12','-dpng')
pause(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     TIME DOMAIN CORRELATION RECONSTRUCTION      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
f_tdc=zeros(nx,ny); % Initialize reconstruction array in (x,y) domain

for i=1:nx; i
   for j=1:ny;
      t_ij=(2*sqrt((x(i)+Xc)^2+(y(j)+Yc-u).^2))/c;
      f_tdc(i,j)=sum(sum(s_ds.*exp(cj*w(:)*(t_ij-tm(n/2+1))).* ...
         (ones(n,1)*(t_ij >= Ts & t_ij <= Tf))));
   end;
end;

% Remove carrier in range domain
f_tdc=f_tdc.*exp(-cj*x(:)*kxc*ones(1,ny));
%

% Remove carrier in cross-range domain (squint mode)
f_tdc=f_tdc.*exp(-cj*ones(nx,1)*2*kc*sin(theta_c)*y);
           
G=abs(f_tdc)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(Xc+x,Yc+y,256-cg*(G-ng));axis([Xc-X0 Xc+X0 Yc-Y0 Yc+Y0]);
axis image; axis xy
xlabel('Range X, meters')
ylabel('Cross-range Y, meters')
title('TDC Spotlight SAR Reconstruction')
%print P5.13.ps
print('inout/P5-13','-dpng')
pause(1)
image(x,y,256-cg*(G-ng));%axis([Xc-X0 Xc+X0 -Y0 Y0]);
axis off
par_a = ceil(size(x,2));
par_b = ceil(size(y,2));
par_a = ceil(abs(max(x)-min(x))/4);
par_b = ceil(abs(max(y)-min(y))/4);
set(gcf,'PaperPosition',[0.25 0.25 par_a par_b])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_TD_image','-dpng','-r2');
pause(1)
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on
fprintf('size of SAR_TD_IMAGE = %d x %d\n', size(x,2), size(y,2));

%SAR image cropped image
G=abs(f_tdc)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
ICin = image(x,y,256-cg*(G-ng));
size(ICin)
par_a = size(ICin,2) * 2*X0 / abs(max(x)-min(x));
par_b = size(ICin,1) * 2*Y0 / abs(max(y)-min(y));
xc1 = max( 1, ceil((size(ICin,2)-par_a)/2) );
xc2 = ceil(par_a);
yc1 = max( 1, ceil((size(ICin,1)-par_b)/2) );
yc2 = ceil(par_b);
ICout = imcrop(ICin,[xc1 yc1 xc2 yc2]);axis([-X0 X0 -Y0 Y0]);

axis off
set(gcf,'PaperPosition',[0.25 0.25 ceil(X0) ceil(Y0)])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_TD_image_cropped','-dpng','-r2');
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on

%return

F_tdc=ftx(fty(f_tdc));     % Reconstruction array in spatial frequency
%
G=abs(F_tdc)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(KX,KY+kus(1),256-cg*(G-ng));
axis image; axis xy
xlabel('Spatial Frequency k_x, rad/m')
ylabel('Spatial Frequency k_y, rad/m')
title('TDC Spotlight SAR Reconstruction Spectrum')
%print P5.14.ps
print('inout/P5-14','-dpng')
pause(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%           BACKPROJECTION RECONSTRUCTION         %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
f_back=zeros(nx,ny); % Initialize reconstruction array in (x,y) domain
n_ratio=100;              % Upsampling ratio in fast-time domain
nu=n_ratio*n;             % Size of upsampled s(t,u) array in t domain
nz=nu-n;                  % Number of zeros
dtu=(n/nu)*dt;            % Fast-time sample spacing of upsampled array
tu=dtu*(-nu/2:nu/2-1);    % Upsampled reference fast-time array
X=x(:)*ones(1,ny);
Y=ones(nx,1)*y;

for j=1:m; j
   t_ij=(2*sqrt((X+Xc).^2+(Y+Yc-u(j)).^2))/c;
   t_ij=round((t_ij-tm(n/2+1))/dtu)+nu/2+1;
   it_ij=(t_ij > 0 & t_ij <= nu);
   t_ij=t_ij.*it_ij+nu*(1-it_ij);
   S=ifty([zeros(1,nz/2),s_ds(:,j).',zeros(1,nz/2)])...
      .*exp(cj*wc*tu);
   S(nu)=0;
   f_back=f_back+S(t_ij);
end;

clear X Y

% Remove carrier in range domain
f_back=f_back.*exp(-cj*x(:)*kxc*ones(1,ny));
%

% Remove carrier in cross-range domain (squint mode)
f_back=f_back.*exp(-cj*ones(nx,1)*2*kc*sin(theta_c)*y);
  
G=abs(f_back)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(Xc+x,Yc+y,256-cg*(G-ng));axis([Xc-X0 Xc+X0 Yc-Y0 Yc+Y0]);
axis image; axis xy
xlabel('Range X, meters')
ylabel('Cross-range Y, meters')
title('Backprojection Spotlight SAR Reconstruction')
%print P5.15.ps
print('inout/P5-15','-dpng')
pause(1)
image(x,y,256-cg*(G-ng));%axis([Xc-X0 Xc+X0 -Y0 Y0]);
axis off
par_a = ceil(size(x,2));
par_b = ceil(size(y,2));
par_a = ceil(abs(max(x)-min(x))/4);
par_b = ceil(abs(max(y)-min(y))/4);
set(gcf,'PaperPosition',[0.25 0.25 par_a par_b])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_BP_image','-dpng','-r2');
pause(1)
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on
fprintf('size of SAR_BP_IMAGE = %d x %d\n', size(x,2), size(y,2));

%SAR image cropped image
G=abs(f_back)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
ICin = image(x,y,256-cg*(G-ng));
size(ICin)
par_a = size(ICin,2) * 2*X0 / abs(max(x)-min(x));
par_b = size(ICin,1) * 2*Y0 / abs(max(y)-min(y));
xc1 = max( 1, ceil((size(ICin,2)-par_a)/2) );
xc2 = ceil(par_a);
yc1 = max( 1, ceil((size(ICin,1)-par_b)/2) );
yc2 = ceil(par_b);
ICout = imcrop(ICin,[xc1 yc1 xc2 yc2]);axis([-X0 X0 -Y0 Y0]);

axis off
set(gcf,'PaperPosition',[0.25 0.25 ceil(X0) ceil(Y0)])
set(gca,'position',[0 0 1 1],'units','normalized')
print('inout/SAR_BP_image_cropped','-dpng','-r2');
set(gcf,'PaperPosition',[0.25 0.25 8 6])
set(gca,'position',[0.05 0.1 0.9 0.85],'units','normalized')
axis on

F_back=ftx(fty(f_back));     % Reconstruction array in spatial frequency
%
G=abs(F_back)';
xg=max(max(G)); ng=min(min(G)); cg=255/(xg-ng);
image(KX,KY+kus(1),256-cg*(G-ng));
axis image; axis xy
xlabel('Spatial Frequency k_x, rad/m')
ylabel('Spatial Frequency k_y, rad/m')
title('Backprojection Spotlight SAR Reconstruction Spectrum')
%print P5.16.ps
print('inout/P5-16','-dpng')
pause(1)

  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forward FFT w.r.t. the first variable %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=ftx(s)
 fs=fftshift(fft(fftshift(s)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse FFT w.r.t. the first variable %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=iftx(fs)
 s=fftshift(ifft(fftshift(fs)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forward FFT w.r.t. the second variable %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fs=fty(s)
 fs=fftshift(fft(fftshift(s.'))).';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse FFT w.r.t. the second variable %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=ifty(fs)
 s=fftshift(ifft(fftshift(fs.'))).';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Custom color map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=mycolormap(n)
%n = 200;               %// number of colors
r = [1 0 0];       %# start
w = [1 1 1];    %# middle
b = [0 0 1];       %# end
%# colormap of size n-by-3, ranging from red -> white -> blue
c_set = zeros(n,3);
for i=1:3
    c_set(:,i) = linspace(w(i), b(i), n);
    %c_set(:,i) = linspace(b(i), w(i), n);
end
c = [c_set];
colormap(c)
end