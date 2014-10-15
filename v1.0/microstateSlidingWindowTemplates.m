% Extract microstate templates in sliding window
%  Return NxMxD array, with N time samples, M sensors and D number of requested template maps.
%  Cluster vpMaps over sampleWindowLength (sec), assign template maps to sampleWindowLength (sec)
%  Center assignment window in sample window, unless at data beginning/end. Then, come as close as possible.

function [compressedSlidingWindowTemplates, templateStartIndices] = microstateSlidingWindowTemplates(trialData, trialFreq, gfpPkLocs, sampleWindowLength, assignmentWindowLength, numTemplates)
trialSize = size(trialData, 2);
numSensors = size(trialData, 1);
sampleWindowSize = sampleWindowLength*trialFreq;
assignmentWindowSize = int32(assignmentWindowLength*trialFreq);

if sampleWindowSize>trialSize
    error('sampleWindowSize must be less than or equal to trial length.');
end
if assignmentWindowSize<1
    error('Selected step size is too small for the resolution of this data.');
end

sampleTailSize = floor((sampleWindowSize-assignmentWindowSize)/2);
% NxMxD array, with N time samples, M sensors and D number of requested template maps
compressedSlidingWindowTemplates = zeros(length(1:assignmentWindowSize:trialSize),numSensors, numTemplates);
templateStartIndices = zeros(length(1:assignmentWindowSize:trialSize),1);
ti=1;
for aStrtIndx=1:assignmentWindowSize:trialSize
    aStpIndx = min(trialSize, aStrtIndx+assignmentWindowSize-1);
    wndwStrtIdx = max(aStrtIndx-sampleTailSize,1);
    wndwStpIdx  = wndwStrtIdx+sampleWindowSize-1;
    % correct sample window position if we run into the end of the trial
    if wndwStpIdx > trialSize
        wndwStpIdx = trialSize;
        wndwStrtIdx = trialSize-sampleWindowSize+1;
    end
    
    % get template maps using data from sample window
    wndwGfpPkLocsIndcs = find(gfpPkLocs >= wndwStrtIdx & gfpPkLocs <= wndwStpIdx);
    wndwGfpPkLocs = gfpPkLocs(wndwGfpPkLocsIndcs);
    microstateTemplates = getTemplateMaps(trialData, wndwGfpPkLocs, numTemplates);
    
    templateStartIndices(ti) = aStrtIndx;
    compressedSlidingWindowTemplates(ti,:,:) = microstateTemplates;
    ti=ti+1;
%     % assign templates to all time points in the assignment wintdow
%     for i=aStrtIndx:aStpIndx
%         expandedSlidingWindowTemplates(i,:,:) = microstateTemplates;
%     end
end

% % keep individual templates and their start times for each window
% i = 1;
% n = length(1:assignmentWindowSize:trialSize);
% compressedSlidingWindowTemplates = zeros(n,numSensors, numTemplates);
% templateStartIndices = zeros(numTemplates,1);
% for aStrtIndx=1:assignmentWindowSize:trialSize
%     compressedSlidingWindowTemplates(i,:,:) = expandedSlidingWindowTemplates(aStrtIndx,:,:);
%     templateStartIndices(i) = aStrtIndx;
%     i=i+1;
% end



end

function microstateTemplates = getTemplateMaps(trialData, gfpPkLocs, numMicrostates)

%% Collect voltage potential maps at GFP peaks
% Rows of vpMaps correspond to observations, and columns correspond to channels. 

vpMaps = trialData(:,gfpPkLocs)';
eucD = pdist(vpMaps, 'correlation');
clustTreeEuc = linkage(eucD, 'average');

%% Calculate N microstate template maps as the mean average of all member vpMaps
mapMembership = cluster(clustTreeEuc,'maxclust',numMicrostates);
microstateTemplates = zeros(size(vpMaps,2), numMicrostates);
for i=1:numMicrostates
    meanMap = mean(vpMaps(mapMembership == i, :), 1);
    microstateTemplates(:, i) = meanMap(:);
end


end
