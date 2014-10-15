%% extractMicrostateFeatures.m

%% Collect features in a N second sliding window
%  Feature values are returned [feature value, sample center index]
function [cMMDmean, cMMDstdDev, gfpMMDmean, gfpMMDstdDev, gfpPeaksPerSecond, stdDevPeakRate, stateDom, stdDevTemplateCoverage] ...
    = extractMicrostateFeatures(trialSize, trialFreq, gfpPkLocs, templateCorrelations)


%% Continuous MMD
cMMDWindowLength = 10;
cMMDStepLength = 5;
[cMMDmean, cMMDstdDev, ~, ~, centerIndices] = continuousMMD(trialSize, trialFreq, templateCorrelations, cMMDWindowLength, cMMDStepLength);
cMMDmean(2,:) = centerIndices(:);
cMMDstdDev(2,:) = centerIndices(:);

%% GFP MMD - Duration is measure in gfp-peaks
gfpMMDWindowLength = 10;
gfpMMDStepLength = 5;
[gfpMMDmean, gfpMMDstdDev, ~, ~, centerIndices] = gfpMMD(trialSize, trialFreq, templateCorrelations, gfpPkLocs, gfpMMDWindowLength, gfpMMDStepLength);
gfpMMDmean(2,:) = centerIndices(:);
gfpMMDstdDev(2,:) = centerIndices(:);

%% GFP PPS - Global Field Power Peaks Per Second
gfpPkWindowLength = 10;
gfpPkStepLength = 5;
[gfpPeaksPerSecond, stdDevPeakRate, centerIndices] = gfpPeakRate(trialSize, trialFreq, gfpPkLocs, gfpPkWindowLength, gfpPkStepLength);
gfpPeaksPerSecond(2,:) = centerIndices(:);
stdDevPeakRate(2,:) = centerIndices(:);

%% RTT - Ratio of Total Time covered (per template)
windowLength = 10;
stepLength = 5;
[~, stdDevTemplateCoverage, centerIndices] = ratioOfTemplageCoverage(trialSize, trialFreq, templateCorrelations, windowLength, stepLength);
stdDevTemplateCoverage(2,:) = centerIndices(:);

%% Microstate Dominance
windowLength = 10;
stepLength = 5;
[stateDom, ~,~, centerIndices] = stateDominance(trialSize, trialFreq, templateCorrelations, windowLength, stepLength);
stateDom(2,:) = centerIndices(:);

end