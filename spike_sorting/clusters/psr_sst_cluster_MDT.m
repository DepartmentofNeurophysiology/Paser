function metrics = psr_sst_cluster_MDT(spikes,parameters,weights)

% Mixture of drifting t-distribution model for sorting spikes and measuring unit isolation
% 
% This function is based on 'demo_isolation_metrics' by Kevin Shan [Copyright (c) 2016] 
% See LICENSE in MDT folder (or: https://github.com/kqshan/MoDT)
%
% Major edits by Terence Brouns (2017)

if (nargin < 3); weights = ones(size(spikes.spiketimes)); end
dims   = parameters.cluster.mdt.dims;
scales = parameters.cluster.mdt.scales;

% Remove clusters that are too small
% Need to have consecutive cluster indices 

clustIDs = 1:max(spikes.assigns);
nclusts  = length(clustIDs);
nspikes  = zeros(1,nclusts);
for iClust = 1:nclusts
    nspikes(iClust) = sum(spikes.assigns == clustIDs(iClust));
end

I        = nspikes <= 2 * dims;
del      = clustIDs(I);
ndel     = length(del); % clusters to remove
clustIDs = clustIDs(~I); % Keep remaining clusters

for iClust = 1:ndel
    
    I  = del(iClust);
    
    id = find(spikes.assigns == I);
    spikes = psr_sst_spike_removal(spikes,id,'delete');
    weights(id) = [];
    
    id = spikes.assigns > I;
    spikes.assigns(id) = spikes.assigns(id) - 1;
    del = del - 1;
    
end

% Do PCA

if (isa(spikes.waveforms,'int16'))
    spikes.waveforms = psr_single(spikes.waveforms,parameters);
end

inspk = psr_wavelet_features(spikes.waveforms(:,:),dims,scales);
inspk = inspk';

% Data conversion

%  New data structure with fields:
%     spk_Y           [D x N] spikes (N spikes in a D-dimensional feature space)
%     spk_t           [N x 1] spike times (ms)
%     spk_clustId     [N x 1] cluster ID this spike is assigned to
%     weighting       [N x 1] suggested weighting for training on a subset

data             = [];
data.spk_Y       = double(inspk);
data.spk_t       = double(spikes.spiketimes' * 1000); % convert to ms
data.spk_clustId = double(spikes.assigns');
data.weighting   = double(weights');

% Run algorithm

% These are the parameters that we recommend in the paper
nu = parameters.cluster.mdt.nu;                               % t-distribution nu parameter (smaller = heavier tails)
q_perhour = parameters.cluster.mdt.q_perhour;                 % Drift regularization (smaller = more smoothing)
timeframe_minutes = parameters.cluster.mdt.timeframe_minutes; % Time frame duration (mostly a computational thing)

% Construct an MoDT object using these parameters
q_perframe = q_perhour * (timeframe_minutes / 60);
model = MoDT('nu',nu,'Q',q_perframe);

% Attach the data to the model
timeframe_ms = 60e3 * timeframe_minutes;
model.attachData(data.spk_Y, data.spk_t,'frameDur',timeframe_ms);

% Fit the model parameters based on our spike assignments
clustAssigned = data.spk_clustId;
MSGID = 'MATLAB:nearlySingularMatrix';
warning('off', MSGID); % Disable warning
model.initFromAssign(clustAssigned);
warning('on',  MSGID);

% Obtain the posterior probability that spike n came from cluster k
posterior = model.getValue('posterior');

% Let's also fit a drifting Gaussian model
gaussModel = model.copy();
gaussModel.setParams('nu',Inf);
gaussModel.initFromAssign(clustAssigned);
[gaussPosterior, gaussMahalSq] = gaussModel.getValue('posterior','mahalDist');

% Report some unit isolation metrics
nClust = model.K;
nDims  = model.D;

% Display the results in sorted order
metrics(nClust).id = [];

for k = 1:nClust
    
    % False positive/negative ratios
    is_assigned_to_k = (clustAssigned == k);
    N_k = sum(is_assigned_to_k);
    otherClusts = [1:k-1, k+1:nClust];
    
    % T-distribution
    prob_came_from_k = posterior(:,k);
    prob_came_from_other = sum(posterior(:,otherClusts), 2);
    falsePosMODT = sum(prob_came_from_other( is_assigned_to_k)) / N_k;
    falseNegMODT = sum(prob_came_from_k    (~is_assigned_to_k)) / N_k;
    
    % Repeat this for the Gaussian
    prob_came_from_k = gaussPosterior(:,k);
    prob_came_from_other = sum(gaussPosterior(:,otherClusts), 2);
    falsePosGauss = sum(prob_came_from_other( is_assigned_to_k)) / N_k;
    falseNegGauss = sum(prob_came_from_k    (~is_assigned_to_k)) / N_k;
    
    % Compute the isolation distance and L-ratio as well
    mahalDistSq_otherSpikes = gaussMahalSq(~is_assigned_to_k, k);
    
    % Isolation distance
    mahalDistSq_sorted = sort(mahalDistSq_otherSpikes);
    
    if (N_k < length(mahalDistSq_sorted))
        isolationDist = mahalDistSq_sorted(N_k);
    else
        isolationDist = [];
    end
    
    % L-ratio
    Lratio = sum(chi2cdf(mahalDistSq_otherSpikes, nDims, 'upper')) / N_k;
    
    % Save these values

    metrics(k).id     = clustIDs(k);     % Cluster ID
    metrics(k).Lratio = Lratio;          % L-ratio
    metrics(k).IsoDis = isolationDist;   % isolation distance
    metrics(k).FP_t   = falsePosMODT;    % False positives (T-distribution)
    metrics(k).FN_t   = falseNegMODT;    % False negatives (T-distribution)
    metrics(k).FP_g   = falsePosGauss;   % False positives (Gaussian)
    metrics(k).FN_g   = falseNegGauss;   % False negatives (Gaussian)
    
end

end