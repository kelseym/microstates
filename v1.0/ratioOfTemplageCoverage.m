% Extract microstate features

function [ratioTotalTimePerTemplate, stdDevTemplateCoverage, centerIndices] = ratioOfTemplageCoverage(trialSize, trialFreq, trialTemplateCorrelations, windowLength, stepLength)

windowSize = windowLength*trialFreq;
stepSize = int32(stepLength*trialFreq);
if stepSize<1
    error('Selected step size is too small for the resolution of this data.');
end
startIndex = floor((windowSize+1)/2);
stopIndex = trialSize - floor((windowSize+1)/2);
[~, maxCorrTemplIdx] = max(trialTemplateCorrelations);
ratioTotalTimePerTemplate = [];
stdDevTemplateCoverage = [];
centerIndices = [];
for wndwCntrIdx=startIndex:stepSize:stopIndex
   wndwStrtIdx = wndwCntrIdx+1-floor(windowSize/2);
   wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
   templateIndicesInWindow = maxCorrTemplIdx(:, wndwStrtIdx:wndwStpIdx);
   ratioTotalTimeInWindowPerTemplate = [];
   for i=1:size(trialTemplateCorrelations,1)
       ratioTotalTimeInWindowPerTemplate(i) = length(find(templateIndicesInWindow == i))/length(templateIndicesInWindow);
   end
   ratioTotalTimePerTemplate(end+1,:) = ratioTotalTimeInWindowPerTemplate;
   stdDevTemplateCoverage(end+1) = std(ratioTotalTimeInWindowPerTemplate);
   centerIndices(end+1) = wndwCntrIdx;
end
