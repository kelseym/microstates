% Extract microstate features
% Count Global Field Power Peaks per Second - in a sliding window time interval
% Report mean gfp peaks per second and std dev of the gfp peak rate across window
function [gfpPeaksPerSecond, stdDevPeakRate, centerIndices] = gfpPeakRate(trialSize, trialFreq, trialGfpPkLocs, windowLength, stepLength)
  %  GFP rate (peaks/sec) computed over a N second sliding window at M second intervals
  windowSize = windowLength*trialFreq;
  stepSize = int32(stepLength*trialFreq);
  if stepSize<1
    error('Selected step size is too small for the resolution of this data.');
  end
  startIndex = floor((windowSize+1)/2);
  stopIndex = trialSize - floor((windowSize+1)/2);
  gfpPeaksPerSecond = [];
  stdDevPeakRate = [];
  centerIndices = [];
  for wndwCntrIdx=startIndex:stepSize:stopIndex
    wndwStrtIdx = wndwCntrIdx-floor(windowSize/2);
    wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
    % store gfp peaks in this interval only
    gfpPkIdxSet = intersect(trialGfpPkLocs, wndwStrtIdx:wndwStpIdx);
    pksInWindow = length(gfpPkIdxSet);
    secondsInWindow = windowSize/trialFreq;
    gfpPeaksPerSecond(end+1) = pksInWindow/secondsInWindow;
    samplesBetweenPeaks = diff(gfpPkIdxSet);
    stdDevPeakRate(end+1) = std(double(samplesBetweenPeaks));
    centerIndices(end+1) = wndwCntrIdx;
  end