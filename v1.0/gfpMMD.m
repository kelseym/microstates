% Extract microstate features

function [meanMsDuration, stdDevMsDuration, startIndex, stepSize, centerIndices] = gfpMMD(trialSize, trialFreq, trialTemplateCorrelations, trialGfpPkLocs, windowLength, stepLength)

%% MMD - Mean Microstate Duration (milliseconds)
%  computed over a N second sliding window at M second intervals
windowSize = windowLength*trialFreq;
stepSize = int32(stepLength*trialFreq);
if stepSize<1
    error('Selected step size is too small for the resolution of this data.');
end
% maxCorrTemplIdx contains the indices of template maps for each sample
[~, maxCorrTemplIdx] = max(trialTemplateCorrelations);
startIndex = floor((windowSize+1)/2);
stopIndex = trialSize - floor((windowSize+1)/2);
meanMsDuration = [];
stdDevMsDuration = [];
centerIndices = [];
for wndwCntrIdx=startIndex:stepSize:stopIndex
   wndwStrtIdx = wndwCntrIdx-floor(windowSize/2);
   wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
   % store templates from gfp peaks in this interval only
   gfpWindowIdxSet = intersect(trialGfpPkLocs, wndwStrtIdx:wndwStpIdx);
   tmpltIndcs = maxCorrTemplIdx(gfpWindowIdxSet);
   [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
   % include indices to represent the first and final full templates in the window
   tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
   % find average length of template match
   msDuration = diff(tmplSwtchIdx);
   centerIndices(end+1) = wndwCntrIdx;
   meanMsDuration(end+1) = mean(msDuration);
   stdDevMsDuration(end+1) = std(msDuration);
end