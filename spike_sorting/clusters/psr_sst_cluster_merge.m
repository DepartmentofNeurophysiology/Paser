function spikes = psr_sst_cluster_merge(spikes,parameters)

% PSR_SST_CLUSTER_MERGE - Merge spike clusters based on waveform similarity.
% This function merges spike clusters obtained by spike sorting if their
% calculated similarity score is above a specified threshold. The metric
% used for the similarity score depends on the chosen method. 
%
% Syntax:  spikes = psr_sst_cluster_merge(spikes,freq,metadata,parameters)
%
% Inputs:
%    spikes     - See README
%    freq       - See README
%    metadata   - See README
%    parameters - See README
%
% Outputs:
%    spikes - The field "spikes.assigns" contains the new cluster ID for
%             each spike after merging, while "spikes.assigns_prior" retains 
%             the old cluster IDs before merging.
%
% See also: PSR_SST_CLUSTER_FEATURES

% PASER: Processing and Analysis Schemes for Extracellular Recordings 
% https://github.com/tbrouns/paser

% Author: Terence Brouns
% Radboud University, Neurophysiology Dept. 
% E-mail address: t.s.n.brouns@gmail.com
% Date: 2017

%------------- BEGIN CODE --------------

% Store prior-merge cluster assigns

if (~isfield(spikes,'assigns_prior')); spikes.assigns_prior = spikes.assigns; end

% Find which clusters to merge
spikes.assigns = spikes.assigns_prior;
spikes.clusters.corr = psr_sst_cluster_corr(spikes,parameters,true);
correlations = spikes.clusters.corr;
correlations(~triu(true(size(correlations)),1)) = -realmax; % Ignore lower triangular part
IDs = find(correlations(:) >= parameters.cluster.merge_thresh); % Do thresholding

[I_row, I_col] = ind2sub(size(correlations),IDs);

%% Do the merging

clusterIDs = 1:size(correlations,1);

clustersX = clusterIDs(I_row);
clustersY = clusterIDs(I_col);

nMerges = length(clustersX);
clustersXOld = clustersX;
clustersYOld = clustersY;

for iMerge = 1:nMerges
    
    % Cluster pair to merge
    
    clusterX = clustersX(iMerge);
    clusterY = clustersY(iMerge);
    
    % Find number of spikes for each cluster
    
    nSpikesX = sum((spikes.assigns == clusterX));
    nSpikesY = sum((spikes.assigns == clusterY));
        
    % Change cluster ID of smaller cluster to ID of larger cluster
    
    if (nSpikesX >= nSpikesY) 
        clustersX(clustersX == clusterY) = clusterX;
        clustersY(clustersY == clusterY) = clusterX;
    else
        clustersX(clustersX == clusterX) = clusterY;
        clustersY(clustersY == clusterX) = clusterY;
    end
    
end

[clustersXOld,IX] = unique(clustersXOld);
[clustersYOld,IY] = unique(clustersYOld);

clustersX = clustersX(IX);
clustersY = clustersY(IY);

for iMerge = 1:length(clustersX)
    spikes.assigns(spikes.assigns == clustersXOld(iMerge)) = clustersX(iMerge);
end

for iMerge = 1:length(clustersY)
    spikes.assigns(spikes.assigns == clustersYOld(iMerge)) = clustersY(iMerge);
end

%% Filter again after merging
spikes = psr_sst_filter_spikes(spikes,parameters);

end

%------------- END OF CODE --------------