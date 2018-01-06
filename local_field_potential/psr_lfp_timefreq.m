function freq = psr_lfp_timefreq(data,parameters)

onset  = parameters.lfp.trial.onset  - parameters.lfp.trial.padding;
offset = parameters.lfp.trial.offset + parameters.lfp.trial.padding;

cfg            = [];
cfg.method     = parameters.lfp.method;
cfg.taper      = parameters.lfp.taper;
cfg.output     = 'pow';
cfg.pad        = parameters.lfp.pad;
if (strcmp(cfg.method,'mtmfft'))
    cfg.foilim     = [parameters.lfp.freq.lower parameters.lfp.freq.upper];
else
    cfg.foi        = parameters.lfp.freq.lower:parameters.lfp.freq.step:parameters.lfp.freq.upper;
    cfg.toi        = onset:parameters.lfp.time_step:offset;
    cfg.t_ftimwin  = parameters.lfp.ncycles ./ cfg.foi;  % 5 cycles per (sliding) time window
    cfg.t_ftimwin(cfg.t_ftimwin > parameters.lfp.trial.padding) = parameters.lfp.trial.padding;
end
cfg.channel    = 'all';
cfg.trials     = 'all';
cfg.keeptrials = 'yes';
cfg.keeptapers = 'no';
freq = ft_freqanalysis(cfg, data);

% % Remove trials with excessive data gaps
% 
% nTrials = size(freq.powspctrm,1);
% del = false(nTrials,1);
% for iTrial = 1:nTrials
%     pow = squeeze(freq.powspctrm(iTrial,:,:,:));
%     Ntot = sum(sum(sum(~isnan(pow))));
%     N    = sum(sum(sum(pow < 0.001)));
%     if (Ntot > 0 && (N / Ntot) > parameters.lfp.miss_thresh)
%         del(iTrial) = true;
%     end
% end
% 
% freq.powspctrm(del,:,:,:) = []; % Delete
% freq.trialIDs  = del;

freq.powspctrm =  single(freq.powspctrm);

end