% Extract microstate features

function perTemplateDuration = durationPerTemplate(trialSize, trialFreq, trialTemplateCorrelations, windowLength, stepLength)

windowSize = windowLength*trialFreq;
stepSize = int32(stepLength*trialFreq);
if stepSize<1
    error('Selected step size is too small for the resolution of this data.');
end
startIndex = floor((windowSize+1)/2);
stopIndex = trialSize - floor((windowSize+1)/2);
[~, maxCorrTemplIdx] = max(trialTemplateCorrelations);
perTemplateDuration = [];
for wndwCntrIdx=startIndex:stepSize:stopIndex
   wndwStrtIdx = wndwCntrIdx+1-floor(windowSize/2);
   wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
   templateIndicesInWindow = maxCorrTemplIdx(:, wndwStrtIdx:wndwStpIdx);
   ratioTotalTimeInWindowPerTemplate = [];
   for i=1:size(trialTemplateCorrelations,1)
       ratioTotalTimeInWindowPerTemplate(i) = length(find(templateIndicesInWindow == i))/length(templateIndicesInWindow);
   end
   perTemplateDuration(end+1,:) = ratioTotalTimeInWindowPerTemplate;
end

   tmpltIndcs = maxCorrTemplIdx(wndwStrtIdx:wndwStpIdx);
   % discard the leading and trailing template map runs, since it is unlikly that we are capturing the full run
   [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
   tmpltIndcs = tmpltIndcs((tmplSwtchIdx(1)+1):tmplSwtchIdx(end));
   [~, tmplSwtchIdx] = find(diff(tmpltIndcs));
   % include indices to represent the first and final full templates in the window
   tmplSwtchIdx = [0 tmplSwtchIdx length(tmpltIndcs)];
   % find average length of template match
   msDuration = diff(tmplSwtchIdx);
   meanMsDuration(end+1) = mean(msDuration);
   stdDevMsDuration(end+1) = std(msDuration);
end
% Convert duration measure from samples to seconds
meanMsDuration = meanMsDuration/trialFreq;

