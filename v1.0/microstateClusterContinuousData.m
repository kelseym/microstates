%% microstateClusterContinuousData.m
%   Extract microstate features from individual 5 min segments
%   Attempt unsupervised classification/clustering to see which segments "look" similar


%% McD03 Grids
%  corr_channels_list_mat = [1 32 ; 33 52] ;
%  bad_channels_list      = [ ] ;
%  grid_size_mat          = [4 8 ; 4 5] ;

clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end


showNSecPlots = 0;
lineColors = lines;close;

%% Load 5 minute segments as seperate trials
[numChan, trialData, trialTime, trialFreq, trialSize, trialSampleInfo, trialLabel] = loadContinuousMcD03();
% Sleep stage key elements crrespond to 24 five minute segments
%  where 1=Awake, 2=N2, 3=SWS
sleepStageKey_perTrial = [1 2 2 2 3 3 1 2 2 3 3 3 3 1 2 2 3 3 3 3 2 1 1 1];

%% GFP calculation
for i=1:length(trialData)
    windowLength = 0;
    stdDevFactor = 0;
    [gfp{i}, gfpPkLocs{i}] = microstateGfpPeaks(trialData{i}, trialSize{i}, trialFreq{i}, numChan{i}, windowLength, stdDevFactor);
    disp(['Found ' num2str(length(gfpPkLocs{i})) ' GFP local maxima in ' trialLabel{i}]);

    windowLength = 30;
    stdDevFactor = 1;
    [~, bigGfpPkLocs{i}] = microstateGfpPeaks(trialData{i}, trialSize{i}, trialFreq{i}, numChan{i}, windowLength, stdDevFactor);
    disp(['Found ' num2str(length(bigGfpPkLocs{i})) ' big GFP peaks ' trialLabel{i}]);

    if showNSecPlots > 0
        pltSmpls = 1:showNSecPlots*trialFreq{i};
        figure, plot(trialTime{i}(pltSmpls), gfp{i}(pltSmpls));
        title([trialLabel{i} ' - Global Field Power']);
        xlabel('Seconds');
        ylabel('GFP');
        hold on;
        pltPksIndx = gfpPkLocs{i}(gfpPkLocs{i}<(showNSecPlots*trialFreq{i}));
        plot(trialTime{i}(pltPksIndx), gfp{i}(pltPksIndx),'g.');
        % highlight peaks > N std dev from mean
        pltPksIndx = bigGfpPkLocs{i}(bigGfpPkLocs{i}<(showNSecPlots*trialFreq{i}));
        plot(trialTime{i}(pltPksIndx), gfp{i}(pltPksIndx),'r.');
    end
%     gfpPkLocs = bigGfpPkLocs;
end


%% Collect voltage potential maps at big GFP peaks
% Rows of vpMaps correspond to observations, and columns correspond to channels. 
% Combine all vpMaps for the purpose of template clustering
vpMaps = [];
for i=1:length(trialData)
    vpMaps = cat(1, vpMaps, trialData{i}(:,bigGfpPkLocs{i})');
end
eucD = pdist(vpMaps, 'correlation');
clustTreeEuc = linkage(eucD, 'average');

%% Calculate N microstate template maps as the mean average of all member vpMaps
%  Start with hard coded N=numMicrostates=4
numMicrostates = 10;
mapMembership = cluster(clustTreeEuc,'maxclust',numMicrostates);
microstateTemplates = zeros(numMicrostates, size(vpMaps,2));
for i=1:numMicrostates
    meanMap = mean(vpMaps(mapMembership == i, :), 1);
    microstateTemplates(i, :) = meanMap(:);
end


%% Compute correlation between templates and original signal
templateCorrelations = cell(1,length(trialData));
for i=1:length(trialData)
    templateCorrelations{i} = zeros(size(microstateTemplates,1),size(trialData{i},2));
    for j=1:size(microstateTemplates,1)
        template = microstateTemplates(j,:)';
        templateCorrelations{i}(j,:) = corr(template,trialData{i}(:,:));
    end
end

%% Collect features in a N second sliding window
% from Brodbeck 2012
% MMD - Mean Microstate Duration (milliseconds)
% PPS - global field Power Peaks per Second
% RTT - Ratio of Total Time covered (per template)

%% Continuous MMD
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [cMMDmean{i}, cMMDstdDev{i}, windowStartIndex{i}, windowStepSize{i}] = continuousMMD(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
end

%% GFP MMD - Duration is measure in gfp-peaks
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [gfpMMDmean{i}, gfpMMDstdDev{i}] = gfpMMD(trialSize{i}, trialFreq{i}, templateCorrelations{i}, gfpPkLocs{i}, windowLength, stepLength);
end

%% GFP PPS - Global Field Power Peaks Per Second
for i=1:length(trialData)
    [gfpPeaksPerSecond{i}, stdDevPeakRate{i}] = gfpPeakRate(trialSize{i}, trialFreq{i}, gfpPkLocs{i}, windowLength, stepLength);
end

%% RTT - Ratio of Total Time covered (per template)
for i=1:length(trialData)
    ratioTotalTimePerTemplate{i} = ratioOfTemplageCoverage(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
end

%% Identify clusters within feature space
msFeatures = {cMMDmean,cMMDstdDev,gfpPeaksPerSecond,stdDevPeakRate};
% Rows of featureMaps correspond to observations, columns correspond to variables.
featureMaps = [];
for i=1:length(msFeatures)
    ftrs = msFeatures{i};
    trlFtr = []; % this column vector corresponds with N observations of a single variable
    for j=1:length(trialData)
        trlFtr = cat(1,trlFtr,ftrs{j}');
    end
    featureMaps = cat(2,featureMaps,trlFtr);
end

featureEucD = pdist(featureMaps, 'correlation');
featureClustTreeEuc = linkage(featureEucD, 'average');

numFeatureClusters = 6;
featureMembership = cluster(featureClustTreeEuc,'maxclust',numFeatureClusters);
featureCentroids = zeros(numFeatureClusters, size(featureMaps,2));
for i=1:numFeatureClusters
    meanMap = mean(featureMaps(featureMembership == i, :), 1);
    featureCentroids(i, :) = meanMap(:);
end

figure;
plotColors = jet(numFeatureClusters);
colormap(plotColors);
scatter(featureMaps(:,1), featureMaps(:,3)',3,featureMembership/24*64,'o','fill')
cb_h = colorbar;
set(cb_h, 'YTickMode','manual');
set(cb_h, 'YTickLabel','');
set(cb_h, 'YTick',[]);


%% Plot time segment assignments compared to sleep staging truth
totalSamples = 0;
for i=1:length(trialData)
    totalSamples = totalSamples + size(trialData{i},2);
end
sleepStageTruth = zeros(totalSamples,1);
for i=1:length(trialData)
    sleepStageTruth(((i-1)*length(trialData{i})+1:i*length(trialData{i}))) = sleepStageKey_perTrial(i);
end

figure; hold on;
plotColors = jet(numFeatureClusters);
colormap(plotColors);
numSegmentsPerTrial = floor(length(featureMembership)/length(sleepStageKey_perTrial));
for i=1:length(sleepStageKey_perTrial)
    strtSgmnt = (i-1)*numSegmentsPerTrial+1;
    endSgmt = strtSgmnt+numSegmentsPerTrial-1;
%    plot([strtSgmnt endSgmt], [sleepStageKey_perTrial(i) sleepStageKey_perTrial(i)], 'k', 'LineWidth', 2);
    colormap(jet);
    for si=strtSgmnt:endSgmt
        area([si si], [sleepStageKey_perTrial(i) sleepStageKey_perTrial(i)], 'EdgeColor', plotColors(featureMembership(si),:), 'BaseValue', 0);
    end
end

set(gca, 'YLim', [0.5 3.5]);
set(gca, 'YTick', [1 2 3]);
set(gca, 'YTickLabel', {'Awake', 'N2', 'SWS'});
cb_h2 = colorbar;
set(cb_h2, 'YTickMode','manual');
set(cb_h2, 'YTickLabel','');
set(cb_h2, 'YTick',[]);






