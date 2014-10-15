% Extract microstate features
% Return mean state durration in seconds - average duration of any state
% sample Indices contains a 2xN list of start,end indicies for each sample window
function [meanMsDuration, stdDevMsDuration, startIndex, stepSize, centerIndices] = continuousMMD(trialSize, trialFreq, trialTemplateCorrelations, windowLength, stepLength)

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
   wndwStrtIdx = wndwCntrIdx+1-floor(windowSize/2);
   wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
   tmpltIndcs = maxCorrTemplIdx(wndwStrtIdx:wndwStpIdx);
   % discard the leading and trailing template map runs, since it is unlikly that we are capturing the full run
   [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
   if numel(tmplSwtchIdx) >  1 
       tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
       [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
       % include indices to represent the first and final full templates in the window
       tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
       % find average length of template match
       msDuration = diff(tmplSwtchIdx);
       % Remove < 10ms (10 samples @ 1kHz)
       lowCutoffMs = 10;
       lowCutoffSamples = lowCutoffMs/1000*trialFreq;
       msDuration = msDuration(msDuration>=lowCutoffSamples);
       
       
       centerIndices(end+1) = wndwCntrIdx;
       meanMsDuration(end+1) = mean(msDuration);
       stdDevMsDuration(end+1) = std(msDuration);
   else
       centerIndices(end+1) = wndwCntrIdx;
       meanMsDuration(end+1) = NaN;
       stdDevMsDuration(end+1) = NaN;
   end
end
% Convert duration measure from samples to seconds
meanMsDuration = meanMsDuration/trialFreq;

