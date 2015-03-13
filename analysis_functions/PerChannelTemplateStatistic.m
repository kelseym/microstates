%% Microstate template cluster measure

%   Measure cluster statistics such as per channel dispersion

%   Input:
%   data - with .trial, .microstateTemplates, .microstateIndices fields
%   cfg.channelstatistic = 'dispersion'

%   Returns:
%   data - with .dispersion{} field containing an MxC matrix for each trial.
%          where M is the number of microstate templates and C is the number of channels

function data = PerChannelTemplateStatistic(cfg, data)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'channelstatistic'});
  if ~isfield(data, 'microstateTemplates') 
    error('data.microstateTemplates field required');
  elseif ~isfield(data, 'microstateIndices')
    error('data.microstateIndices field required');
  end
  
  
  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'channelstatistic', 'char', {'dispersion'});

  % get the options
  channelStatistic = ft_getopt(cfg, 'channelstatistic','dispersion');
  

  %% Gather statistics for each trial,cluster and channel independently
  data.dispersion = cell(length(data.trial),1);
  if strcmp(channelStatistic, 'dispersion')
    for trli=1:length(data.trial)
      for msi=1:size(data.microstateTemplates{trli},1)
        data.dispersion{trli}(msi,:) = mad(data.trial{trli}(:, data.microstateIndices{trli} == msi),0,2);
      end
    end
    
  else
    error('Unknown channelstatistic option.');
  end
      
  
end
