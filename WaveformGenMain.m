%BRYCE Wafeworm generator
%a simple and easy to use waveform programer for the 33600A 
    %written using god fearing PROCEDURAL PROGRAMING
    %able to produce long constant sections without using up valuable waveform space
    %resonable documentation
    %ability to repeat sub wavefroms
    %built uing sections of code from  Roman Khakimovs 2015 OOP program

%to improve
    %padd the wavefrom with a zero 
    %determine if it is possible to have sub waveforms with differing sample rates
%fixed
    
%% START user settings
doNormalization     =   false;
useVoltageScaling   =   true;
if_plot             =   true;
Trigg_Delay         =   0.0e-3;

%% END user settings
mat_fname='mat_wf/Raman_Bragg.mat';
global max_points srate_max points_min repeats_max
max_points=double(4e6);
srate_max=1e9;              % [S/s] max is 1e9
points_min=double(32);
repeats_max=1e6;

%% General configs
f0_AOM=80e6;            % [Hz]     Central AOMs frequency 
Ek=84.9e3;              % beam geometry (90 deg)

%% Bell test sequence

% %%% SOURCE pulse
% B_trap_bottom=2.285e6;
% dF_Raman= -(B_trap_bottom-abs(Ek));         %[Hz]    Raman detuning
% f1_Raman_sour=f0_AOM-dF_Raman/2;            %[Hz]    45(P) RAMAN   "top"                          45(S) RAMAN   "top"
% f2_Raman_sour=f0_AOM+dF_Raman/2;            %[Hz]   -45(S) RAMAN   "horizontal"                 -45(P) RAMAN   "horizonatal"
% 
% T_Raman_sour=6e-6;   % Duration of PI pulse [s]
% K_R_sour=0.205;       %amplitude in volts(single sided, vpp is 2x) max 0.55 %0.6270;
% Gs_mod_R_sour=3;

% %%% DELAY (SOURCE-MIXING)
% T_delay_mix=3000e-6;      % Delay between the SRC and MIX pulse

%%% MIXING pulse
B_trap_bottom=2.01e6;
dF_Raman=-(B_trap_bottom);     %[Hz]    Raman detuning
f1_Raman_mix=f0_AOM-dF_Raman/2;     %[Hz]    45(P) RAMAN   "top"                          45(S) RAMAN   "top"
f2_Raman_mix=f0_AOM+dF_Raman/2;     %[Hz]   -45(S) RAMAN   "horizontal"                 -45(P) RAMAN   "horizonatal"

T_Raman_mix=4e-6;
Gs_mod_R_mix=2;
phi1_mix=pi;

%-------------------------------------------------------------------------
% Note: Choose one from below MIX settings or add one
% K_R_mix=0.4;

% % MIX 0
% K_R_mix=0.0;

% % MIX 1
% K_R_mix=0.4;

% % MIX 2
% K_R_mix=0.33;
 
% % MIX 3
% K_R_mix=0.27;

% MIX 4
% K_R_mix=0.365;

% % auto_switch override
% if exist('thisRamanK','var')
%     K_R_mix=thisRamanK;
% end
%-------------------------------------------------------------------------

%% phases
% NOTE: separated out since we find zero gives fine results
phi1=0;
phi2=0;

%% Mixing characterisation
if source_mf==1
    %%% mf=1
    %%%% Bragg: |1_0> |--> |1_0> + |1_2K>
    dF_Bragg_src=abs(Ek);
    
    f1_Bragg_src=f0_AOM-dF_Bragg_src/2;
    f2_Bragg_src=f0_AOM+dF_Bragg_src/2;
    
    % ~50/50: 24-10-2017
    T_Bragg_src=15e-6;
    K_Bragg_src=0.086;
    Gs_mod_Bragg_src=2;
    
    %----------------------------------------------------------------------------
elseif source_mf==0
    %% mf=0
    % %%%%%%%% METHOD A %%%%%%%%
    % %%%% Raman: |1_0> |--> |0_0>
    % B_trap_bottom=2.285e6;
    % K_Raman_pi_0=0.2;
    % T_Raman_pi_0=4e-6;
    % G_Raman_pi_0=2;
    % % T_Raman_sour=6e-6;   % Duration of PI pulse [s]
    % % K_R_sour=0.205;       %amplitude in volts(single sided, vpp is 2x) max 0.55 %0.6270;
    % % Gs_mod_R_sour=3;
    %
    % dF_Raman_pi_0=-B_trap_bottom;        %[Hz]    Raman detuning
    % f1_Raman_pi_0=f0_AOM-dF_Raman_pi_0/2;         	%[Hz]
    % f2_Raman_pi_0=f0_AOM+dF_Raman_pi_0/2;         	%[Hz]
    % phi1_mf0=pi;
    %
    %
    % %%%% delay
    % T_delay_1=0e-6;      % Delay between the Raman and Bragg
    %
    % %%%% Bragg: |0_0> |--> |0_0> + |0_2K>
    % K_Bragg_src=0;%0.2;
    % T_Bragg_src=15e-6;
    % Gs_mod_Bragg_src=2;
    %
    % dF_Bragg_src=abs(Ek);
    % f1_Bragg_src=f0_AOM-dF_Bragg_src/2;
    % f2_Bragg_src=f0_AOM+dF_Bragg_src/2;
    
    %%%%%%%% METHOD B %%%%%%%%
    %%%% Raman: |1_0> |--> |0_K>
    B_trap_bottom=2.285e6;
    K_Raman_pi_K=0.30;
    T_Raman_pi_K=6e-6;
    G_Raman_pi_K=3;
    
    dF_Raman_pi_K=-(B_trap_bottom-abs(Ek));       %[Hz]    Raman detuning
    f1_Raman_pi_K=f0_AOM-dF_Raman_pi_K/2;         	%[Hz]
    f2_Raman_pi_K=f0_AOM+dF_Raman_pi_K/2;         	%[Hz]
    
    % %%%% delay
    % T_delay_1=0e-6;      % Delay between the Raman and Bragg
    
    %%%% Bragg: |0_K> |--> |0_K> + |0_0>
    K_Bragg_src=0.2;%0.21;
    T_Bragg_src=15e-6;
    Gs_mod_Bragg_src=2;
    
    dF_Bragg_src=abs(Ek);
    f1_Bragg_src=f0_AOM-dF_Bragg_src/2;
    f2_Bragg_src=f0_AOM+dF_Bragg_src/2;
    
    %----------------------------------------------------------------------------
else
    error('source_mf should be 0 or 1');
end

%%%% delay MIX
T_delay_mix=3000e-6;      % Delay between the SRC and MIX pulse

%% WAVEFORM BUILDER
%--------------------------------------------------------------------------
% Waveform Format:
%{'sine',freq(hz),phase(rad),amplitude,Gauss mod,sample rate,duration}
%{'const',amplitude,sample rate,duration}
%{'double_sine',freq1(hz),freq2(hz),phase1(rad),phase2(rad),amplitude1,amplitude2,Gauss mod1,Gauss mod2,sample rate,duration}
%--------------------------------------------------------------------------
srate_all=srate_max;


% NOTE: choose one sequence from below

% %%% SOURCE ONLY: Raman
% ch1_raw={{'sine', f1_Raman_sour, phi1, K_R_sour, Gs_mod_R_sour, srate_all, T_Raman_sour}};
% ch2_raw={{'sine', f2_Raman_sour, phi2, K_R_sour, Gs_mod_R_sour, srate_all, T_Raman_sour}};

% %%% Full Bell scheme: Source Raman + delay + Mixing Raman
% ch1_raw={{'sine',f1_Raman_sour,phi1,K_R_sour,Gs_mod_R_sour,srate_all,T_Raman_sour},...
%         {'const',0, srate_all,T_delay_mix},...
%         {'double_sine',f1_Raman_mix,f2_Raman_mix,phi1,phi2,K_R_mix,K_R_mix,Gs_mod_R_mix,Gs_mod_R_mix,srate_all,T_Raman_mix},...
%     };
% 
% ch2_raw={{'sine',f2_Raman_sour,phi2,K_R_sour,Gs_mod_R_sour,srate_all,T_Raman_sour},...
%         {'const',0, srate_all,T_delay_mix},...
%         {'const',0, srate_all,T_Raman_mix},...
%     };

if source_mf==1
    %%% Mixing angle characterise (mF=1): Source Bragg + delay + Mixing Raman
    ch1_raw={{'sine',    f1_Bragg_src       ,phi1,          K_Bragg_src,       Gs_mod_Bragg_src, srate_all,   T_Bragg_src},...
            {'const',0, srate_all,T_delay_mix},...
            {'double_sine',f1_Raman_mix,f2_Raman_mix,phi1_mix,phi2,K_R_mix,K_R_mix,Gs_mod_R_mix,Gs_mod_R_mix,srate_all,T_Raman_mix},...
        };
    
    ch2_raw={{'sine',    f2_Bragg_src       ,phi2,          K_Bragg_src,       Gs_mod_Bragg_src, srate_all,   T_Bragg_src},...
            {'const',0, srate_all,T_delay_mix},...
            {'const',0, srate_all,T_Raman_mix},...
        };
elseif source_mf==0
    %%% Mixing angle characterise (mF=0): Source Raman(0K)+Bragg + delay + Mixing Raman
    % % METHOD A
    % ch1_raw={
    %     {'double_sine',f1_Raman_pi_0,f2_Raman_pi_0,phi1_mf0,phi2,K_Raman_pi_0,K_Raman_pi_0,G_Raman_pi_0,G_Raman_pi_0,srate_all,T_Raman_pi_0},...%     {'const',0, srate_all,T_delay_1},...
    %     {'sine',f1_Bragg_src,phi1,K_Bragg_src,Gs_mod_Bragg_src,srate_all,T_Bragg_src},...
    %     {'const',0,srate_all,T_delay_mix},...
    %     {'double_sine',f1_Raman_mix,f2_Raman_mix,phi1_mix,phi2,K_R_mix,K_R_mix,Gs_mod_R_mix,Gs_mod_R_mix,srate_all,T_Raman_mix},...
    %     };
    %
    % ch2_raw={
    %     {'const',0,srate_all,T_Raman_pi_0},...%     {'const',0, srate_all,T_delay_1},...
    %     {'sine',f2_Bragg_src,phi2,K_Bragg_src,Gs_mod_Bragg_src,srate_all,T_Bragg_src},...
    %     {'const',0,srate_all,T_delay_mix+T_Raman_mix},...   % combined delay
    %     };
    
    % METHOD B
    ch1_raw={
        {'sine',f1_Raman_pi_K,phi1,K_Raman_pi_K,G_Raman_pi_K,srate_all,T_Raman_pi_K},...
        {'sine',f1_Bragg_src,phi1,K_Bragg_src,Gs_mod_Bragg_src,srate_all,T_Bragg_src},...
        {'const',0,srate_all,T_delay_mix},...
        {'double_sine',f1_Raman_mix,f2_Raman_mix,phi1_mix,phi2,K_R_mix,K_R_mix,Gs_mod_R_mix,Gs_mod_R_mix,srate_all,T_Raman_mix},...
        };
    
    ch2_raw={
        {'sine',f2_Raman_pi_K,phi1,K_Raman_pi_K,G_Raman_pi_K,srate_all,T_Raman_pi_K},...
        {'sine',f2_Bragg_src,phi1,K_Bragg_src,Gs_mod_Bragg_src,srate_all,T_Bragg_src},...
        {'const',0,srate_all,T_delay_mix+T_Raman_mix},...   % combined delay
        };
else
    error('source_mf should be 0 or 1');
end

%%% Package and sent to instrument
chanels_dev1={ch_to_waveforms(ch1_raw),ch_to_waveforms(ch2_raw)};
% chanels_dev2={ch_to_waveforms(ch3_raw),ch_to_waveforms(ch4_raw)};

%then this will be processed into multiple wavefroms
%to start with make all seprate, in future could merge adjacent wavefroms that have the same sample
%rate

plot_segments(chanels_dev1,0)

send_segments(chanels_dev1,1)
%send_segments(chanels_dev2,2) %cant get other function gen running


% %Bryce EDIT added amplitude as argument to WF()
% CH1=[
%     WF(@sin, f1_Raman,      phi1,    T_Raman,        K_R,        SRATE, Gs_mod_R,    0), ...
%     WF(@sin, f1_Bragg_pulse1,0,         T_Bragg_pulse1, K_B_pulse1, SRATE,  Gs_mod_B_pulse1,   1), ...
%     WF(Zero, 0,             0,			T_delay_mix,       0,SRATE, 0,               0), ...        
%     WF(@sin, f1_Bragg_pulse2,0,         T_Bragg_pulse2, K_B_pulse2, SRATE,  Gs_mod_B_pulse2,   1), ... 
%     %WF(Zero, 1e-3,          0,			T_flight2,       0,SRATE, 0,               0), ...   
%     %WF(@sin, f1_Bragg_pulse3,      0,   T_Bragg_pulse3, K_B_pulse3,SRATE,  Gs_mod_B_pulse3,   1), ...
%     ];
% CH2=[   
%     WF(@sin, f2_Raman,       phi2,  	T_Raman,        K_R,        SRATE, Gs_mod_R,	0) ...
%     WF(@sin, f2_Bragg_pulse1, 0,        T_Bragg_pulse1, K_B_pulse1, SRATE,  Gs_mod_B_pulse1,   1), ...
%     WF(Zero,  0,             0,         T_delay_mix,       0,SRATE, 0,               0), ...    
%     WF(@sin, f2_Bragg_pulse2,0,         T_Bragg_pulse2, K_B_pulse2, SRATE,  Gs_mod_B_pulse2,    1),...
% 	%WF(Zero, 1e-3,          0,			T_flight2,       0,SRATE, 0,               0), ...   
%     %WF(@sin, f2_Bragg_pulse3,      0,   T_Bragg_pulse3, K_B_pulse3,SRATE,  Gs_mod_B_pulse3,   1), ...
%     
%     ];


% % FEEDBACK: auto_switch override
% if exist('thisRamanK','var')
%     fprintf('success! this Raman MIX amp: %0.3g\n',K_R_mix);
% end