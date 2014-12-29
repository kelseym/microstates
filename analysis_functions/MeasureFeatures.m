%% Extract microstate features
%  cfg.features={'meanduration','stdduration','gfppeakrate','stdgfppeaks','totaldurationpermicrostate','durationpermicrostate','statetransitions'}

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
      case 'totaldurationpermicrostate'
        featureValues{ftri} = TotalDurationPerMicrostate(data);
      case 'durationpermicrostate'
        featureValues{ftri} = DurationPerMicrostate(data);
      case 'statetransitions'
        featureValues{ftri} = StateTransitions(data);
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
    meanMsDuration(trli) = NaN;
    if numel(tmplSwtchIdx) >  1 
      % discard the leading and trailing template map runs, since it is unlikely that we are capturing the full run
      tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
      [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
      % include indices to represent the first and final full templates in the window
      tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
      % find average length of template match
      msDuration = diff(tmplSwtchIdx);
      meanMsDuration(trli) = mean(msDuration)/data.fsample;
    end
  end
end

%% Calculate the standard deviation of the continuous duration of microstates over the trial window
function stdDevDuration = StdDevDuration(data)
  for trli=1:length(data.microstateIndices)
    tmpltIndcs = data.microstateIndices{trli};
    [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
    stdDevDuration(trli) = NaN;
    if numel(tmplSwtchIdx) >  1 
      % discard the leading and trailing template map runs, since it is unlikely that we are capturing the full run
      tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
      [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
      % include indices to represent the first and final full templates in the window
      tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
      % find average length of template match
      msDuration = diff(tmplSwtchIdx);
      stdDevDuration(trli) = std(msDuration/data.fsample);
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
    gfpPeakRate(trli) = numPeaks/secondsInTrial;
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
    stdDevGfpPeaks(trli) = std(secondsBetweenPeaks);
  end
end

%% Calulate the total duration (in seconds) of each microstate individually
function totalMicrostateDuration = TotalDurationPerMicrostate(data)
  totalMicrostateDuration = zeros(size(data.microstateTemplates{1},1),1);
  for trli=1:length(data.microstateIndices)
    tmpltIndcs = data.microstateIndices{trli};
    [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
    if numel(tmplSwtchIdx) >  1 
      % discard the leading and trailing template map runs, since it is unlikely that we are capturing the full run
      tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
      % count total number of occurances for each template index
      for tmplti=1:size(data.microstateTemplates{1},1)
        totalMicrostateDuration(tmplti) = totalMicrostateDuration(tmplti) + nnz(tmpltIndcs == tmplti)/data.fsample;
      end
    end
  end
end

%% Calulate the individual duration (in seconds) of each microstate presentation
function microstateDuration = DurationPerMicrostate(data)
  for trli=1:length(data.microstateIndices)
    tmpltIndcs = data.microstateIndices{trli};
    [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
    if numel(tmplSwtchIdx) >  1 
      % discard the leading and trailing template map runs, since it is unlikely that we are capturing the full run
      tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
      % find length of each microstate presentation
      for tmplti=1:size(data.microstateTemplates{1},1)
        I = diff([0 (tmpltIndcs == tmplti) 0]);
        microstateDuration{tmplti} = (find(I==-1) - find(I==1))/data.fsample;
      end
    end
  end
end

%% Produce NxM transistion matrix where each element holds a count of transistions from state N to state M
function transitionMatrix = StateTransitions(data)
  for trli=1:length(data.microstateIndices)
  numMicrostates = size(data.microstateTemplates{trli},1);
    tmpltIndcs = data.microstateIndices{trli};
    for sNi=1:numMicrostates
      for sMi=1:numMicrostates
        if sNi==sMi
          continue;
        end
        [~,sNloc] = find(tmpltIndcs==sNi);
        [~,sMloc] = find(tmpltIndcs==sMi);
        % find the locations of transitions from sN to sM
        transitionLoc = intersect(sNloc+1, sMloc);
        n2mTransitions = length(transitionLoc);
        transitionMatrix{trli}(sNi,sMi) = n2mTransitions;
      end
    end
  end
end

