
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
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %   PULSED SPOTLIGHT SAR SIGNAL GENERATION    %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

% Custom color map
n_c = 300;               %// number of colors
%c=mycolormap(n_c);
colormap(gray(256))
%%
%Set input Image size
input_size = 'small'
%input_size = 'medium'
%input_size = 'large'
if isequal(input_size,'small')
    %target_file_name = 'targinp1'; %Target image file name
    %target_file_name = 'target_name_11'; %Target image file name
    target_file_name = 'data/Airplane32'; %Target image file name
    %
    Xc=1000;                 % Range distance to center of target area
    X0=32;                   % target area in range is within [Xc-X0,Xc+X0]
    Y_c=300;                 % Cross-range distance to center of target area
    Y0=64;                   % target area in cross-range is within
                             % [Yc-Y0,Yc+Y0]
    mc = 64;                 % Number of samples on aperture (compressed signal)
    m = 512;                 % Number of samples on aperture
    n = 512;                 % Number of samples in fast time
    N_P = 512;               % Number of pulses
elseif isequal(input_size,'medium')
    Xc=1200;                 % Range distance to center of target area
    X0=40;                   % target area in range is within [Xc-X0,Xc+X0]
    Y_c=400;                 % Cross-range distance to center of target area
    Y0=80;                   % target area in cross-range is within
                             % [Yc-Y0,Yc+Y0]
    mc = 64;                 % Number of samples on aperture (compressed signal)
    m = 1024;                % Number of samples on aperture
    n = 1024;                % Number of samples in fast time
    N_P = 1024;              % Number of pulses
    %target_file_name = 'input/Airplane32'; %Target image file name
    target_file_name = 'data/Airplane64'; %Target image file name    
elseif isequal(input_size,'large')
    Xc=1600;                 % Range distance to center of target area
    X0=80;                   % target area in range is within [Xc-X0,Xc+X0]
    Y_c=600;                 % Cross-range distance to center of target area
    Y0=160;                  % target area in cross-range is within
                             % [Yc-Y0,Yc+Y0]
    mc = 96;                 % Number of samples on aperture (compressed signal)
    m = 2048;                % Number of samples on aperture
    n = 2048;                % Number of samples in fast time   
    N_P = 2048;              % Number of pulses
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
% Case 1: L < Y0; requires zero-padding of SAR signal in synthetic
% aperture domain
%
%  L=100;                 % synthetic aperture is 2*L

% Case 2: L > Y0; slow-time Doppler subsampling of SAR signal spectrum
% reduces computation
%
 L=400;                 % synthetic aperture is 2*L

% Target moves along the cross-range a a constant velocity
% each snapshots captured corresponds to the data from each 
% pulse in slow time

n_p = 0;
for Yc = (Y_c-N_P/8):(Y_c+N_P/8), N_P;
    n_p =n_p+1;
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
    % mc=2*ceil(L_min/duc)             % number of samples on aperture
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
    %m=2*ceil(pi/(du*dku));            % number of samples on aperture
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
    % n=2*ceil((.5*Tmin)/dt);      % number of time samples
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
    s_ds(:,:,n_p) = s;            % Save s(omega,u) array for TDC and
    % backprojection algorithms
end
%%Write datacube to file
outfile_name = strcat('../inout/SAR_datacube_',input_size);
out_file = fopen(outfile_name,'w');
fwrite(out_file,[real(s_ds);imag(s_ds)],'float64','n');
fclose(out_file);

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
