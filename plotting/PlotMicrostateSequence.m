%% Plot microstate sequence
%  Plot colorized microstate timeseries labels under a gfp curve

%  Input:
%  cfg.trialindex - index of trial to plot
%  cfg.starttime - intra-trial plot start time (sec)
%  cfg.endtime - intra-trial plot end time (sec)

function fh = PlotMicrostateSequence(data, cfg)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'trialindex'});
  cfg = ft_checkconfig(cfg, 'required', {'starttime'});
  cfg = ft_checkconfig(cfg, 'required', {'endtime'});
  
  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'trialindex', 'double');
  cfg = ft_checkopt(cfg, 'starttime', 'double');
  cfg = ft_checkopt(cfg, 'endtime', 'double');

  % get the options
  trialIndex = ft_getopt(cfg, 'trialindex', 1);
  startTime = ft_getopt(cfg, 'starttime', 0);
  endTime = ft_getopt(cfg, 'endtime', 5);

  % check for valid trial and time settings
  if trialIndex > length(data.trial)
    error('Invalid trialindex specified');
  end
  if endTime >= length(data.trial{trialIndex})/data.fsample
    error('Invalid endtime');
  end
  if startTime > length(data.trial{trialIndex})/data.fsample || startTime >= endTime;
    error('Invalid starttime');
  end
  

  % Compute samples to be plotted (start at index no less than one)
  pltSmpls = floor(max(1,startTime*data.fsample)):ceil(min(endTime*data.fsample,length(data.trial{trialIndex})));

  fh = figure;
  lineColors = lines;
  hold on;
  [~, tmplSwitchIdx] = find(diff(data.microstateIndices{trialIndex}(pltSmpls)));
  % include extra index to catch the final value
  tmplSwitchIdx(end+1) = length(data.microstateIndices{trialIndex}(pltSmpls));
  tmplSwitchVal = data.microstateIndices{trialIndex}(tmplSwitchIdx);
  % compute and plot GFP for this trial
  [gfp, ~] = LocateGfpPeaks(data.trial{trialIndex});
  plot(data.time{trialIndex}(pltSmpls), gfp(pltSmpls),'k');
  xlim([startTime endTime]);
  ylabel('GFP');
  xlabel('Time (s)');
  title(sprintf('%i Microstate Labeled GFP', length(unique(data.microstateIndices{trialIndex}))));

  startIdx = pltSmpls(1);
  tmplSwitchIdx = tmplSwitchIdx + (startIdx-1);
  for j=2:length(tmplSwitchIdx)
    endIdx = tmplSwitchIdx(j);
    area(data.time{trialIndex}(startIdx:endIdx), gfp(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal(j),:),'EdgeColor', 'k', 'LineStyle', 'none', 'LineWidth', 0.1);
    startIdx = tmplSwitchIdx(j)+1;
  end
  hold off;


end

