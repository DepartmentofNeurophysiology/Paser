% PSR_PARAMETERS_GENERAL - Script to set default general parameters in PASER.
% See comments before and after each parameter for its purpose.
%
% Syntax:  psr_parameters_general
%
% Outputs:
%    parameters - Structure that contains general parameters for data processing
%

% PASER: Processing and Analysis Schemes for Extracellular Recordings 
% https://github.com/tbrouns/paser

% Author: Terence Brouns
% Radboud University, Neurophysiology Dept. 
% E-mail address: t.s.n.brouns@gmail.com
% Date: 2017

%------------- BEGIN CODE --------------

%% Pipeline conditional parameters
% Used to skip certain sections of data processing pipeline

parameters.process.spikes = true; % Perform spike detection
parameters.process.lfp    = true; % Perform LFP detection

%% General
parameters.general.precision = 1; % Number of digits after decimal point to keep for int16 data conversion

%% Development
parameters.develop.comparison = false;
parameters.develop.timing     = false;
parameters.develop.gamma      = 0.3;
parameters.develop.epsilon    = 0.5; % [ms]

%% PSR_ARTIFACT_FFT
% Parameters used in raw signal filtering in power spectrum

parameters.filter.fft.process = true;
parameters.filter.fft.freq    = 10;   % Size of frequency window [Hz]
parameters.filter.fft.pad     = 0.1; % Size of half-window to extract artifact [Hz]
parameters.filter.fft.thresh  = 5;    % Threshold to detect artifact peaks, given by number of STDs above mean (using MAD)

%% PSR_ARTIFACT_DIFF

parameters.filter.diff.process      = false;
parameters.filter.diff.win_slope    = 0.10; % [ms]
parameters.filter.diff.win_stimulus = 100;  % [ms]
parameters.filter.diff.win_pulse    = 30;   % Search window for second peak [ms]
parameters.filter.diff.win_artifact = 2.0;  % [ms]
parameters.filter.diff.win_padding  = 0.5;  % [ms]
parameters.filter.diff.thresh       = 10;  

%% %%%% Spike Detection %%%%

parameters.spikes.thresh      = 3.0; % Threshold given as number of standard deviations above mean for spike detection
parameters.spikes.ref_period  = 1.5; % Refractory period of spikes [ms]
parameters.spikes.window_size = 1.5; % Width of a spike [ms]. Take samples symmetrically around peak.
parameters.spikes.max_desync  = 0.25; % Maximum temporal desynchronization between channels of probe [ms]

% Zero-phase digital band-pass filter parameters for spike detection
parameters.spikes.bp.upper = 6000; % Upper cutoff frequency [Hz]
parameters.spikes.bp.lower = 600;  % Lower cutoff frequency [Hz]
parameters.spikes.bp.order = 10;   % Order of filter 

parameters.spikes.twin = 10; % Time of each individual section for spike detection (minutes)

%% %%%% Spike Sorting %%%%

% parameters.sorting.method
% 'CBP' : Continuous Basis Pursuit      - https://github.com/chinasaur/CBPSpikesortDemo
% 'FMM' : Focused Mixture Model         - https://github.com/decarlson/FMMSpikeSorter
% 'ISO' : ISO-SPLIT                     - https://github.com/magland/isosplit_old
% 'KFM' : Kalman filter mixture model   - https://github.com/AnaCalabrese/KFMM
% 'KST' : KiloSort                      - https://github.com/cortex-lab/KiloSort
% 'OPS' : OPASS                         - https://github.com/decarlson/opass
% 'OST' : OSort                         - http://www.urut.ch/new/serendipity/index.php?/pages/osort.html
% 'SPC' : Super-paramagnetic clustering - http://redishlab.neuroscience.umn.edu/MClust/MClust.html
% 'UMS' : UltraMegaSort2000             - https://github.com/danamics/UMS2K

parameters.sorting.method  = 'KST'; % Spike sorting method (see above)

%% Focused Mixture Model [FMM] (Dictionary learning) 
parameters.sorting.fmm.p     = 1e-4;  % Changes how aggresively to cluster, range 0-1 (0: less clustering, 1: more clustering)
parameters.sorting.fmm.k     = 5; 
parameters.sorting.fmm.kmax  = 16;    % Maximum number of clusters
parameters.sorting.fmm.align = false; % Whether to align the waveforms 

%% Continuous Basis Pursuit [CBP]
% [Need to set path to repository with "parameters.path.cbp"]
parameters.sorting.cbp.nC = 16; % number of clusters

%% UltraMegaSort2000 [UMS]
parameters.sorting.ums.kmeans_size = 0.01; % target size for miniclusters as fraction of total number of spikes
parameters.sorting.ums.agg_cutoff  = 0.05; % higher = less aggregation, lower = more aggregation

%% Opass [OPS]
parameters.sorting.ops.dims    = 3;
parameters.sorting.ops.alph    = 1e-1;
parameters.sorting.ops.kappa_0 = 0.01;
parameters.sorting.ops.nu_0    = 0.1;
parameters.sorting.ops.Phi_0f  = 0.1; % Factor for 'Phi_0'
parameters.sorting.ops.a_pii   = 1;
parameters.sorting.ops.b_pii   = 1e7;
parameters.sorting.ops.betf    = 30; % Factor for 'bet'

%% Super paramagnetic clustering [SPC]
parameters.sorting.spc.mcs = 0.01; % Minimum cluster size as fraction of total number of spikes

%% ISO-SPLIT [ISO]
parameters.sorting.iso.mcs = 0.01; % Minimum cluster size as fraction of total number of spikes

%% Kalman filter mixture model [KFM]
parameters.sorting.kfm.nC   = 16; % number of clusters
parameters.sorting.kfm.dims = 10; % Number of inputs to the clustering 

%% KiloSort [KST]
% [Need to set path to repository with "parameters.path.kst"]

parameters.sorting.kst.GPU     = 1; % use CUDA (GPU computing)
parameters.sorting.kst.verbose = 1; % whether to print command line progress (true or false)

parameters.sorting.kst.Nfilt   = 32; % number of clusters to use (2-4 times more than Nchan, should be a multiple of 32)

% other options for controlling the model and optimization
parameters.sorting.kst.Nrank       = 3;        % matrix rank of spike template model (3)
parameters.sorting.kst.nfullpasses = 6;        % number of complete passes through data during optimization (6)
parameters.sorting.kst.maxFR       = 20000;    % maximum number of spikes to extract per batch (20000)
parameters.sorting.kst.ntbuff      = 64;       % samples of symmetrical buffer for whitening and spike detection
parameters.sorting.kst.NT          = 128*1024+ parameters.sorting.kst.ntbuff; % this is the batch size (try decreasing if out of memory)
% for GPU should be multiple of 32 + ntbuff

% the following options can improve/deteriorate results.
% when multiple values are provided for an option, the first two are beginning and ending anneal values,
% the third is the value used in the final pass.
parameters.sorting.kst.Th               = [6 12 12];    % threshold for detecting spikes on template-filtered data ([6 12 12])
parameters.sorting.kst.lam              = [10 30 30];   % large means amplitudes are forced around the mean ([10 30 30])
parameters.sorting.kst.nannealpasses    = 4;            % should be less than nfullpasses (4)
parameters.sorting.kst.momentum         = 1./[20 1000]; % start with high momentum and anneal (1./[20 1000])
parameters.sorting.kst.shuffle_clusters = 1;            % allow merges and splits during optimization (1)
parameters.sorting.kst.mergeT           = .1;           % upper threshold for merging (.1)
parameters.sorting.kst.splitT           = .1;           % lower threshold for splitting (.1)

% options for initializing spikes from data
parameters.sorting.kst.initialize      = 'fromData';    %'fromData' or 'no'
parameters.sorting.kst.spkTh           = -4;      % spike threshold in standard deviations (4)
parameters.sorting.kst.loc_range       = [3  1];  % ranges to detect peaks; plus/minus in time and channel ([3 1])
parameters.sorting.kst.long_range      = [30 6];  % ranges to detect isolated peaks ([30 6])
parameters.sorting.kst.maskMaxChannels = 5;       % how many channels to mask up/down ([5])
parameters.sorting.kst.crit            = .65;     % upper criterion for discarding spike repeates (0.65)
parameters.sorting.kst.nFiltMax        = 10000;   % maximum "unique" spikes to consider (10000)

%% %%%% Cluster Quality Control %%%%

%% PSR_SST_FILTER_SPIKES

parameters.filter.spikes.rpvs = false; % Remove refractory period violations

parameters.filter.spikes.corr_global        = false; % Remove high global correlation spikes
parameters.filter.spikes.corr_global_thresh = 0.5;   % Correlation across probes threshold for spike removal

parameters.filter.spikes.mse_cluster        = false; % Remove spikes with low within-cluster correlations
parameters.filter.spikes.mse_cluster_thresh = 5.0; 

parameters.filter.spikes.amp        = false; % Remove spikes with amplitude at wrong channel or position
parameters.filter.spikes.amp_offset = 0.2; % Normalized amplitude difference from maximum, for channel selection

parameters.filter.spikes.mse_chan        = true; % Remove non-spike channel noise
parameters.filter.spikes.mse_chan_thresh = 0.05; % Correlation threshold 

%% PSR_SST_WAVELET_FEATURES
% Feature extraction
parameters.cluster.wavelet.dims   = 10; % Number of dimensions for wavelet decomposition                   
parameters.cluster.wavelet.scales = 4;  % Number of scales for the wavelet decomposition 

%% PSR_SST_AMP_HIST
parameters.cluster.amplitude_nbin = 20; % Average number of spikes per bin 

%% PSR_SST_AMP_SPLIT 
parameters.cluster.split.bin      = 20;   % Average number of spikes per bin
parameters.cluster.split.smooth   = 7;    % Number of bins for Gaussian smoothing
parameters.cluster.split.thresh   = 100;  % Number of spikes
parameters.cluster.split.prom     = 0.1;  % Minimum fraction of maximum peak
parameters.cluster.split.width    = 3;    % Minimum width of neighbouring peaks 
parameters.cluster.split.terminal = 0.05; % Threshold for termination (fraction of maximum peak)

%% PSR_SST_CLUSTER_FEATURES
parameters.cluster.thresh         = 4;   % Number of standard deviations above mean for average amplitude of highest amplitude channel
parameters.cluster.thresh_xcorr   = 1;   % Threshold for channel amplitude in order to be considered for cross-correlation, given by number of STDs.
parameters.cluster.stability.win  = 10;  % Window to use for spike count [sec]
parameters.cluster.stability.fvar = 2/3; % Variance factor for model Gaussian distribution

%% PSR_SST_CLUSTER_MERGE
parameters.cluster.merge.thresh.corr   = 0.80; % Cross-correlation threshold of concatenated channels
parameters.cluster.merge.thresh.bhatta =  2.0; % Mahalanobis distance threshold

%% PSR_SST_CLUSTER_MDT

parameters.cluster.mdt.nu                = 7;  % t-distribution nu parameter (smaller = heavier tails) 
parameters.cluster.mdt.q_perhour         = 2;  % Drift regularization (smaller = more smoothing)         
parameters.cluster.mdt.timeframe_minutes = 1;  % Time frame duration (mostly a computational thing)   

%% PSR_SST_CLUSTER_CLASSIFIER

% Thresholds to determine whether cluster is valid single unit. Set
% specific field to empty if the threshold should not be used.

% Cluster quality

parameters.cluster.max_rpv    = 0.10; % Maximum fraction of refractory period violations (RPVs) in cluster
parameters.cluster.max_sub    = 0.10; % Maximum fraction of sub-threshold spikes in cluster
parameters.cluster.max_amp    = 200;  % Maximum absolute mean spike amplitude of cluster [microvolt]
parameters.cluster.min_amp    = 1.0;  % Minimum amplitude relative to "parameters.cluster.thresh"
parameters.cluster.max_p2p    = 300;  % Maximum absolute mean peak-to-peak amplitude of cluster [microvolt]
parameters.cluster.min_spikes = 50;   % Minimum number of spikes in cluster
parameters.cluster.min_frate  = 0.05; % Minimum average firing rate (Hz)
parameters.cluster.min_auc    = 0.30; % Minimum area under curve for spike count distribution
parameters.cluster.max_xclag  = 0.20; % Maximum lag of peak cross-correlation between probe channels [ms]

% Isolation quality

parameters.cluster.max_lratio    = 0.25; % Maximum L-ratio for single unit
parameters.cluster.min_isodist   = 20;   % Minimum isolation distance for single unit

%% %%%% FieldTrip parameters %%%%%
% [Need to set path to repository with "parameters.path.ft"]

%% LOCAL FIELD POTENTIAL

parameters.lfp.Fr = 1200; % Down-sampling frequency of LFP signal [Hz]. Leave empty if no down-sampling should occur.

parameters.lfp.filter.type = 'lp'; % Low-pass filter: 'lp', Band-pass filter: 'bp' 

parameters.lfp.filter.bp.upper = 300; % Band-pass filter upper cut-off frequency [Hz]
parameters.lfp.filter.bp.lower = 0.1; % Band-pass filter lower cut-off frequency [Hz]
parameters.lfp.filter.bp.order =   5; % Band-pass filter order

parameters.lfp.filter.lp.upper = 300; % Low-pass filter frequency [Hz]
parameters.lfp.filter.lp.order =   5; % Low-pass filter order

parameters.lfp.filter.padding = 60; % Mirror padding [s] 

parameters.lfp.trial.onset  = -0.2; % Trial start time relative to stimulus onset [sec]
parameters.lfp.trial.offset =  0.5; % Trial end   time relative to stimulus onset [sec]
parameters.lfp.trial.padding = 1.0; % Time window before and after trial on- and offset [sec]

%% PSR_LFP_ARTIFACT_DETECTION_PSD
parameters.lfp.artifact.freqRange  = linspace(10,100,64); % Frequencies for which to calculate PSD
parameters.lfp.artifact.threshPSD  = 3;                   % PSD threshold
parameters.lfp.artifact.window     = 0.5;                 % Window to calculate PSD [sec]

%% PSR_LFP_ARTIFACT_DETECTION_AMP
parameters.lfp.artifact.cat            = true; % Concatenate trials
parameters.lfp.artifact.tsection       = 10;   % Window length in which we detect background noise [sec]
parameters.lfp.artifact.threshAmpUpper =  6;   % Upper threshold given as number of standard deviations above background noise
parameters.lfp.artifact.threshAmpLower =  2;   % Lower threshold given as number of standard deviations above background noise
parameters.lfp.artifact.tSlope         =  6;   % [ms]

%% PSR_LFP_ARTIFACT_REMOVAL
parameters.lfp.artifact.interval = 0.50; % Minimum clean interval between artifacts [sec]
parameters.lfp.artifact.padding  = 0.00; % Padding added on either side of detected artifact [sec]

%% %%%% Stimulus Onset Detection %%%%%

%% PSR_MFA_DETECTION
% Magnetic field artifact (MFA) parameters

parameters.mfa.threshold = 0.99; % Absolute signal threshold
parameters.mfa.min_dur   = 0.1; % Minimum duration of pulse [sec]

%% %%%% Experiment Specific Parameters %%%%

%% Active vs. passive touch
parameters.experimental.avp.run     = false;
parameters.experimental.avp.diff    = true;
parameters.experimental.avp.offset  = true;