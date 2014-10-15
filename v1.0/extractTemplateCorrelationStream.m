%% extractTemplateCorrelationStream.m

function [gfp, gfpPkLocs, templateCorrelations] = extractTemplateCorrelationStream(trialData, trialSize, trialFreq, numChan)

%% GFP calculation
windowLength = 0;
stdDevFactor = 0;
[gfp, gfpPkLocs] = microstateGfpPeaks(trialData, trialSize, trialFreq, numChan, windowLength, stdDevFactor);

windowLength = 30;
stdDevFactor = 1;
[~, bigGfpPkLocs] = microstateGfpPeaks(trialData, trialSize, trialFreq, numChan, windowLength, stdDevFactor);

%% Calculate N microstate template maps for each time segment using a sliding window
numMicrostates = 46;
sampleWindowLength = 200;
assignmentWindowLength = 60;
% microstateSlidingWindowTemplates returns an NxMxD array, with N time samples, M sensors and D number of requested template maps
%[templates, templateStartIndices] = microstateSlidingWindowTemplates(trialData, trialFreq, gfpPkLocs, sampleWindowLength, assignmentWindowLength, numMicrostates);
[templates, templateStartIndices] = microstateSingleWindowTemplates(trialData, gfpPkLocs, numMicrostates);

%% Compute correlation coefficent between sliding templates and original signal
templateCorrelations = microstateGetTemplateCorrelations(trialData, templates, templateStartIndices);

end

% Extract microstate templates in single window
%  Return 1xMxD array, with 1 time samples, M sensors and D number of requested template maps.
%  Cluster vpMaps over full trialData size, format output to match microstateSlidingWindowTemplates()
function [singleWindowTemplates, templateStartIndices] = microstateSingleWindowTemplates(trialData, gfpPkLocs, numMicrostates)
% return default start index to match standard Template search function output
templateStartIndices = 1;

%% Collect voltage potential maps at GFP peaks
% Rows of vpMaps correspond to observations, and columns correspond to channels. 
% Combine all vpMaps for the purpose of template clustering
vpMaps = [];
vpMaps = cat(1, vpMaps, trialData(:,gfpPkLocs)');

eucD = pdist(vpMaps, 'correlation');
clustTreeEuc = linkage(eucD, 'average');

%% Calculate N microstate template maps as the mean average of all member vpMaps
mapMembership = cluster(clustTreeEuc,'maxclust',numMicrostates);
singleWindowTemplates = zeros(size(vpMaps,2),numMicrostates);
for i=1:numMicrostates
    meanMap = mean(vpMaps(mapMembership == i, :), 1);
    singleWindowTemplates(:,i) = meanMap(:);
end

singleWindowTemplates = shiftdim(singleWindowTemplates, -1);


end