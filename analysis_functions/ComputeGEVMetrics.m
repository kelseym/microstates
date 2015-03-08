%% compute global explained variance of a microstate template set
% Data should be pre-filtered to frequency band of interest.
% Metrics are computed per trial

%  
%  Input:
%  cfg.maxNumMicroStates = maximum number (2-max) of microstates to measure GEV

function [gevArea, maxExVar, gev] = ComputeGEVMetrics(cfg, data)


  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'maxnummicrostates'});
  
  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'maxnummicrostates', 'double');

  % get the options
  maxNumMicrostates = ft_getopt(cfg, 'maxnummicrostates');

  gev = zeros(maxNumMicrostates);

  % compute microstate templates
  for numMicrostates=1:maxNumMicrostates
    cfg = [];
    cfg.numtemplates = numMicrostates;
    cfg.datastructs = data;
    cfg.clustertrainingstyle = 'trial';
    trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);

    for trli=1:length(data.trial)
      microstateTemplates = trialMicrostateTemplates{1}{trli};
      gevk = ComputeGlobalExplainedVariance(microstateTemplates, data.trial{trli});
      gev(numMicrostates,trli) = sum(gevk);
    end
  end
  
  for trli=1:length(data.trial)
    gevArea(trli) = mean(gev(:,trli));
    maxExVar(trli) = max(gev(:,trli));
  end

end  
    
    