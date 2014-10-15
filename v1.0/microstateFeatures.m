%% Extrtact microstate features from template match matrix
% Return 1xN feature labels, MxN feature values, M time stamps

% Inputs: templateCorrelations: PxQ matrix should corespond to P templates over the course of a single labeled state/subject
%         trialFreq, windowLength, stepLength
%
function microstateFeatures(templateCorrelations, gfpPkLocs, trialFreq, windowLengthSec, stepLengthSec)
  %  computed over a N second sliding window at M second intervals
  %  convert input window sizes from seconds to samples
  windowSizeSamp = windowLengthSec*trialFreq;
  stepSizeSamp = int32(stepLengthSec*trialFreq);
  if stepSizeSamp<1
    error('Selected step size is too small for the resolution of this data.');
  end
  
  % maxCorrTemplIdx contains the indices of template maps for each sample
  [~, maxCorrTemplIds] = max(templateCorrelations);
  
  meanDurationSec = [];
  stdDevDurationSec = [];
  gfpPksPerSecond = [];
  stdDevPeakRateSec = [];
  templateDominance = [];
  
  wndwStrtIndx = 1;
  while wndwStrtIndx+windowSizeSamp-1 <= length(maxCorrTemplIds)
    wndwStpIndx = int32(wndwStrtIndx+windowSizeSamp-1);
    
    %% Compute features for given time window
    
    % Mean microstate duration
    meanDurationSec(end+1) = featureMeanDuration(maxCorrTemplIds(wndwStrtIndx:wndwStpIndx), 0)/trialFreq;
    
    % Standard deviation of microstate duration (within sliding window)
    stdDevDurationSec(end+1) = featureStdDevDuration(maxCorrTemplIds(wndwStrtIndx:wndwStpIndx), 0)/trialFreq;
    
    % GFP peak rate
    gfpPksPerSecond(end+1) = featureGfpPeakRate(wndwStrtIndx:wndwStpIndx, gfpPkLocs)/trialFreq;
    
    % Standard deviation of GFP peak rate (within sliding window)
    stdDevPeakRateSec(end+1) = featureStdDevGfpPeakRate(wndwStrtIndx:wndwStpIndx, gfpPkLocs)/trialFreq;
    
    % Template dominance
    templateDominance(end+1) = featureTemplateDominance(maxCorrTemplIds(wndwStrtIndx:wndwStpIndx));
    
    % update window start index
    wndwStrtIndx = int32(wndwStrtIndx + stepSizeSamp);
  end
  
  %% Setup feature labels and matrix 
  %   feature matrix contains one row per feature, one column per sampling window
  featureLabels = {'meanDurationSec'; 'stdDevDurationSec'; 'gfpPksPerSecond'; 'stdDevPeakRateSec'; 'templateDominance'};
  features = [meanDurationSec;...
              stdDevDurationSec;...
              gfpPksPerSecond;...
              stdDevPeakRateSec;...
              templateDominance;...
              ];

  
end





function meanDuration = featureMeanDuration(wndwTmpltIndcs, lowCutoff)
  % discard the leading and trailing template map runs, since it is unlikly that we are capturing the full run
  [~, tmplSwtchIdx] = find(diff(wndwTmpltIndcs));
  if numel(tmplSwtchIdx) >  1
    wndwTmpltIndcs = wndwTmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
    [~, tmplSwtchIdx] = find(diff(wndwTmpltIndcs));
    % include indices to represent the first and final full templates in the window
    tmplSwtchIdx = [0 tmplSwtchIdx length(wndwTmpltIndcs)];
    % find average length of template match
    duration = diff(tmplSwtchIdx);
    duration = duration(duration>=lowCutoff);
    meanDuration = mean(duration);
  else
    meanDuration = NaN;
  end
end

function stdDevDuration = featureStdDevDuration(wndwTmpltIndcs, lowCutoff)
  % discard the leading and trailing template map runs, since it is unlikly that we are capturing the full run
  [~, tmplSwtchIdx] = find(diff(wndwTmpltIndcs));
  if numel(tmplSwtchIdx) >  1
    wndwTmpltIndcs = wndwTmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
    [~, tmplSwtchIdx] = find(diff(wndwTmpltIndcs));
    % include indices to represent the first and final full templates in the window
    tmplSwtchIdx = [0 tmplSwtchIdx length(wndwTmpltIndcs)];
    % find average length of template match
    duration = diff(tmplSwtchIdx);
    duration = duration(duration>=lowCutoff);
    stdDevDuration = std(duration);
  else
    stdDevDuration = NaN;
  end
end

function gfpPksPerSample = featureGfpPeakRate(wndwIndcs, gfpPkLocs)
  % store gfp peaks in this interval only
  gfpPkIdxSet = intersect(gfpPkLocs, wndwIndcs);
  pksInWindow = length(gfpPkIdxSet);
  gfpPksPerSample = pksInWindow/length(wndwIndcs);
end

function stdDevPeakRate = featureStdDevGfpPeakRate(wndwIndcs, gfpPkLocs)
  % analyze gfp peaks in this interval only
  gfpPkIdxSet = intersect(gfpPkLocs, wndwIndcs);
  samplesBetweenPeaks = diff(gfpPkIdxSet);
  stdDevPeakRate = std(double(samplesBetweenPeaks));
end

function templateDominance = featureTemplateDominance(wndwTmpltIndcs)
  % discard the leading and trailing template map runs, since it is unlikly that we are capturing the full run
  [~, tmplSwtchIdx] = find(diff(wndwTmpltIndcs));
  if numel(tmplSwtchIdx) >  1
    wndwTmpltIndcs = wndwTmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
    [~, tmplSwtchIdx] = find(diff(wndwTmpltIndcs));
    tmplSwtchVl = wndwTmpltIndcs([tmplSwtchIdx length(wndwTmpltIndcs)]);
    % include indices to represent the first and final full templates in the window
    tmplSwtchIdx = [0 tmplSwtchIdx length(wndwTmpltIndcs)];
    % find average length of template match
    msDuration = diff(tmplSwtchIdx);
    segmentDuration = tmplSwtchIdx(end)-tmplSwtchIdx(1);
    tmpltCvrg = zeros(length(unique(wndwTmpltIndcs)),1);
    for tmplti=1:length(unique(wndwTmpltIndcs))
      tmpltCvrg(tmplti) = sum(msDuration(tmplSwtchVl==tmplti)/segmentDuration);
    end
    templateDominance = sumsqr(tmpltCvrg);
  else
    templateDominance = NaN;
  end
  
end


