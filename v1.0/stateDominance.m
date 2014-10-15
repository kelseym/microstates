% Extract microstate features

function [templateDominance, startIndex, stepSize, centerIndices] = stateDominance(trialSize, trialFreq, trialTemplateCorrelations, windowLength, stepLength)

%% MSD - Microstate State Domenance
%  computed over a N second sliding window at M second intervals
windowSize = windowLength*trialFreq;
stepSize = int32(stepLength*trialFreq);
if stepSize<1
    error('Selected step size is too small for the resolution of this data.');
end
% maxCorrTemplIdx contains the indices of template maps for each sample
[~, maxCorrTemplIdx] = max(trialTemplateCorrelations,[],1);
startIndex = floor((windowSize+1)/2);
stopIndex = trialSize - floor((windowSize+1)/2);
templateDominance = [];
centerIndices = [];
for wndwCntrIdx=startIndex:stepSize:stopIndex
   wndwStrtIdx = wndwCntrIdx+1-floor(windowSize/2);
   wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
   tmpltIndcs = maxCorrTemplIdx(wndwStrtIdx:wndwStpIdx);
   % discard the leading and trailing template map runs, since it is unlikly that we are capturing the full run
   [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
   if numel(tmplSwtchIdx) > 1 
       tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
       [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
       tmplSwtchVl = tmpltIndcs([tmplSwtchIdx length(tmpltIndcs)]);
       % include indices to represent the first and final full templates in the window
       tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
       % find coverate ratio of each template
       msDuration = diff(tmplSwtchIdx);
       segmentDuration = tmplSwtchIdx(end)-tmplSwtchIdx(1);
       for tmplti=1:size(trialTemplateCorrelations,1)
           tmpltCvrg(tmplti) = sum(msDuration(tmplSwtchVl==tmplti)/segmentDuration);
       end
       templateDominance(end+1) = sumsqr(tmpltCvrg);
       centerIndices(end+1) = wndwCntrIdx;
   else
       templateDominance(end+1) = NaN;
       centerIndices(end+1) = wndwCntrIdx;
   end
end

