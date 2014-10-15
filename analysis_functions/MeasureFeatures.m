%% Extract microstate features
%  cfg.features={'meanduration','stdduration','gfppeakrate','stdgfppeaks'}

function data = MeasureFeatures(cfg, data)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'features'});
  ft_checkconfig(data, 'required', 'templateCorrelations');
  ft_checkconfig(data, 'required', 'microstateIndices');

  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'features', 'cell');

  % get the options
  featureLabels = ft_getopt(cfg, 'features');
  featureValues = cell(length(featureLabels),1);
  % compute features on each trial in datain
  for ftri=1:length(featureLabels)
    switch featureLabels{ftri}
      case 'meanduration'
        featureValues{ftri} = MeanDuration(data);
      case 'stdduration'
        featureValues{ftri} = StdDevDuration(data);
      case 'gfppeakrate'
        featureValues{ftri} = GfpPeakRate(data);
      case 'stdgfppeaks'
        featureValues{ftri} = StdDevGfpPeaks(data);
    end
  end
  data.featurelabels = featureLabels;
  data.featurevalues = featureValues;
end




%% Calculate the mean continuous duration of microstates (in seconds)
function meanMsDuration = MeanDuration(data)
  for trli=1:length(data.microstateIndices)
    tmpltIndcs = data.microstateIndices{trli};
    [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
    meanMsDuration{trli} = NaN;
    if numel(tmplSwtchIdx) >  1 
      % discard the leading and trailing template map runs, since it is unlikely that we are capturing the full run
      tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
      [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
      % include indices to represent the first and final full templates in the window
      tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
      % find average length of template match
      msDuration = diff(tmplSwtchIdx);
      meanMsDuration{trli} = mean(msDuration)/data.fsample;
    end
  end
end

%% Calculate the standard deviation of the continuous duration of microstates over the trial window
function stdDevDuration = StdDevDuration(data)
  for trli=1:length(data.microstateIndices)
    tmpltIndcs = data.microstateIndices{trli};
    [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
    stdDevDuration{trli} = NaN;
    if numel(tmplSwtchIdx) >  1 
      % discard the leading and trailing template map runs, since it is unlikely that we are capturing the full run
      tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
      [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
      % include indices to represent the first and final full templates in the window
      tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
      % find average length of template match
      msDuration = diff(tmplSwtchIdx);
      stdDevDuration{trli} = std(msDuration/data.fsample);
    end
  end
end

%% Calculate the GFP peak rate (peaks per second)
function gfpPeakRate = GfpPeakRate(data)
  for trli=1:length(data.microstateIndices)
    % GFP calculation
    gfp = sqrt(sum(data.trial{trli}.^2,1)/size(data.trial{trli},1));
    % Find local maxima
    [~, peakLocs] = findpeaks(gfp,'MINPEAKDISTANCE',3);
    numPeaks = length(peakLocs);
    secondsInTrial = length(gfp)/data.fsample;
    gfpPeakRate{trli} = numPeaks/secondsInTrial;
  end
end

%% Calculate the standard deviation of the GFP peak rate
function stdDevGfpPeaks = StdDevGfpPeaks(data)
  for trli=1:length(data.microstateIndices)
    % GFP calculation
    gfp = sqrt(sum(data.trial{trli}.^2,1)/size(data.trial{trli},1));
    % Find local maxima
    [~, peakLocs] = findpeaks(gfp,'MINPEAKDISTANCE',3);
    secondsBetweenPeaks = diff(peakLocs/data.fsample);
    stdDevGfpPeaks{trli} = std(secondsBetweenPeaks);
    
    
  end
end



