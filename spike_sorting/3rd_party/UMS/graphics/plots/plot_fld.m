function [x1,x2,w] = plot_fld(spikes, show1, show2, display)
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% plot_fld - Fisher Linear Discriminant projection of 2 clusters
%
% Usage:
%     [x1,x2,w] = plot_fld( spikes, show1, show2, display )
%
% Description:
%    Plots a projection of 2 spike clusters onto their Fisher Linear
% Discriminant (FLD).  The FLD is the optimal linear projection for
% separating 2 Gaussian distributions.  It is calculated by projecting
% the separation of the 2 means onto the inverse of the sum of both
% scatter matrices (which is related to the covariance matrix).
%
% The projection takes the form of 2 transparent histograms of different
% colors.  If show1 and show2 indicate single clusters (i.e., they are scalars),
% then their colors are taken from their cluster colors.  The user can
% toggle whether the legend is hidden/shown and toggle between the cluster
% and default color schemes by right-clicking the axes and selecting from
% the context-menu.  Left (right) clicking a histogram will send it to the
% front (back).
%
% Inputs:
%   spikes        - a spikes structure
%   show1         - spikes selected for group 1 (see get_spike_indices.m)
%   show2         - spikes selected for group 2
%
% Optional inputs:
%   display       - flag for whether to actually make plot (default = 1)
%
% Output:
%   x1            - FLD projection of waveforms selected by show1
%   x2            - FLD projection of waveforms selected by show2
%   w             - the FLD projection vector
%

% check arguments
if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end
if ~isfield(spikes.info,'pca'),  error('No PCA found in spikes object.'); end
if (nargin < 4); display = true; end
warning off backtrace

% get selected indices
select1 = get_spike_indices(spikes, show1 );
select2 = get_spike_indices(spikes, show2 );

% get collection of waveforms using PCA
d = diag(spikes.info.pca.s);
r = find(cumsum(d)/sum(d) > 0.95, 1);
r = min(r, min(length(select1), length(select2) ) );
w1 = spikes.waveforms(select1, :) * spikes.info.pca.v(:,1:r);
w2 = spikes.waveforms(select2, :) * spikes.info.pca.v(:,1:r);

% calcualte scatter matrices
S1 = cov(w1) * (size(w1,1)-1);
S2 = cov(w2) * (size(w2,1)-1);
Sw = S1 + S2;

% calculate FLD
w = inv(Sw)*( mean(w1)-mean(w2) )';

% project data
x1 = w' * w1';
x2 = w' * w2';
my_range = [min([x1 x2]) max([x1,x2])];
bins = linspace(my_range(1), my_range(2), 100);
[n1,y1] = hist(x1,bins);
[n2,y2] = hist(x2,bins);

% display everything
if display
    hax = gca;
    cla(hax)
    
    % use cluster colors if events represent real clusters
    color1 = [.1 .1 .9];
    color2 = [.9 .1 .1];
    
    % create histograms as semi-transparent patches
    n1 = n1 / length(x1);    
    n2 = n2 / length(x2); 
    
    h1 = patch([y1 fliplr(y1)],[n1 zeros(size(y1))], zeros(size([y1 y1])), color1);
    h2 = patch([y2 fliplr(y2)],[n2 zeros(size(y2))], zeros(size([y1 y1])), color2);
    set([h1 h2],'LineWidth',.25,'FaceAlpha', 0.7);
    set([h1 h2],'LineWidth',.25);
        
    % place legend
    legend([h1 h2],{'1st','2nd'},'Location','Best')
    
    % label axes
    xlabel('Linear Discriminant')
    ylabel('No. of spikes')
    set(hax,'Tag','plot_fld');
        
end

end

% lowers saturation of color
function color = adjust_saturation( color, new_sat )

color = rgb2hsv( color );
color(2) = new_sat;
color = hsv2rgb(color);
end
