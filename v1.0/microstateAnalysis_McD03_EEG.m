%% microstateAnalysis_ContinuousMcD03.m

clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end
showNSecPlots = 5;
lineColors = lines;

filename = 'D:\Projects\McDonnell\MCD03EEG.EDF';
trialLabel = '2hr McD03';
sensorList = 3:19;
layoutFile = 'EEG1020.lay';

% Sleep stage key elements crrespond to 24 five minute segments
%  where 0=Awake, 2=N2, 3=SWS
sleepStageKey_per5min = [0 2 2 2 3 3 0 2 2 3 3 3 3 0 2 2 3 3 3 3 2 0 0 0];



%% Load ECoG data and pre-process
cfg = [];
cfg.datafile = filename;
cfg.channels = sensorList;
cfg.continuous = 'yes';
%     cfg.bsfilter = 'yes';
%     cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.demean = 'yes';
cfg.detrend = 'yes';
% cfg.polyremoval = 'yes';
% cfg.polyorder = 2;
%cfg.preproc.baselinewindow = [-0.1 -.001];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg);

% Grab important values from data
numChan = length(data.label);
trialData = data.trial{1};
trialTime = data.time{1};
trialFreq = data.fsample;
trialSize = size(trialData,2);
trialSampleInfo = data.sampleinfo;
clear data;

% %% Restrict to 32 channels on grid 1 and (optionally) the first 5 seconds for testing 
% trialData = trialData(sensorList, :);
% % %     %%%% Remove these lines to include full time course. From here,
% %     trialTime = trialTime(1:2500);
% %     trialData = trialData(sensorList, 1:2500);
% %     numChan = size(trialData,1);
% % %     %%%%% to here
% trialSize = size(trialData,2);


%% GFP calculation
windowLength = 0;
stdDevFactor = 0;
[gfp, gfpPkLocs] = microstateGfpPeaks(trialData, trialSize, trialFreq, numChan, windowLength, stdDevFactor);
disp(['Found ' num2str(length(gfpPkLocs)) ' GFP local maxima in ' trialLabel]);

windowLength = 30;
stdDevFactor = 1;
[~, bigGfpPkLocs] = microstateGfpPeaks(trialData, trialSize, trialFreq, numChan, windowLength, stdDevFactor);
disp(['Found ' num2str(length(bigGfpPkLocs)) ' big GFP peaks ' trialLabel]);
if showNSecPlots > 0
    pltSmpls = 1:showNSecPlots*trialFreq;
    figure, plot(trialTime(pltSmpls), gfp(pltSmpls));
    title([trialLabel ' - Global Field Power']);
    xlabel('Seconds');
    ylabel('GFP');
    hold on;
    pltPksIndx = gfpPkLocs(gfpPkLocs<(showNSecPlots*trialFreq));
    plot(trialTime(pltPksIndx), gfp(pltPksIndx),'g.');
    % highlight peaks > N std dev from mean
    pltPksIndx = bigGfpPkLocs(bigGfpPkLocs<(showNSecPlots*trialFreq));
    plot(trialTime(pltPksIndx), gfp(pltPksIndx),'r.');
    pause(1);
end

%% Calculate N microstate template maps for each time segment using a sliding window
numMicrostates = 4;
sampleWindowLength = 300;
assignmentWindowLength = 60;
% slidingWindowTemplates contains an NxMxD array, with N time samples, M sensors and D number of requested template maps
[compressedSlidingWindowTemplates, templateStartIndices] = microstateSlidingWindowTemplates(trialData, trialFreq, gfpPkLocs, sampleWindowLength, assignmentWindowLength, numMicrostates);


%% Compute correlation coefficent between sliding templates and original signal
templateCorrelations = microstaeGetTemplateCorrelations(trialData, compressedSlidingWindowTemplates, templateStartIndices);

if showNSecPlots > 0
    pltSmpls = 1:showNSecPlots*trialFreq;

    %% Plot correlation per template
    figure; hold on;
    title([trialLabel ' - Correlation with Microstate Templates']);
    xlabel('Seconds');
    ylabel('Correlation');
    for j=1:size(templateCorrelations(:,pltSmpls), 1)
        plot(trialTime(pltSmpls), templateCorrelations(j,pltSmpls),'Color', lineColors(j,:));
    end
    
    %% Plot GFP with microstate designation in color
    [maxCorr, maxCorrTemplIdx] = max(templateCorrelations(:,pltSmpls),[],1);
    [~, tmplSwitchIdx] = find(diff(maxCorrTemplIdx));
    % include extra index to catch the final value
    tmplSwitchIdx(end+1) = length(maxCorrTemplIdx);
    tmplSwitchVal = maxCorrTemplIdx(tmplSwitchIdx);
    figure; hold on;
    plot(trialTime(pltSmpls)*1000, gfp(pltSmpls),'k');
    title([trialLabel ' - GFP w/Microstate']);
    ylabel('GFP');
    xlabel('Time (ms)');
    startIdx = 1;
    for j=1:length(tmplSwitchIdx)
        endIdx = tmplSwitchIdx(j);
        area(trialTime(startIdx:endIdx)*1000, gfp(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal(j),:));
        startIdx = tmplSwitchIdx(j)+1;
    end

    %% Plot Max Correlation with microstate designation in color
    figure; hold on;
    h1 = plot(trialTime(pltSmpls)*1000, maxCorr, 'g');
    title([trialLabel ' - Correlation w/Microstate']);
    ylabel('Template Correlation');
    xlabel('Time (ms)');
    meanCorr = mean(templateCorrelations(:,pltSmpls), 1);
    h2 = plot(trialTime(pltSmpls)*1000, meanCorr, 'c');
    legend('Max Corr','Avg Corr');
    startIdx = 1;
    for j=1:length(tmplSwitchIdx)
        endIdx = tmplSwitchIdx(j);
        area(trialTime(startIdx:endIdx)*1000, maxCorr(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal(j),:), 'BaseValue', min(meanCorr));
        startIdx = tmplSwitchIdx(j)+1;
    end
    uistack(h1, 'top');
    uistack(h2, 'top');
    pause(1);
end

%% Collect features in a N second sliding window
% from Brodbeck 2012
% MMD - Mean Microstate Duration (milliseconds)
% PPS - global field Power Peaks per Second
% RTT - Ratio of Total Time covered (per template)

%% Continuous MMD
cMMDWindowLength = 10;
cMMDStepLength = 5;
[cMMDmean, cMMDstdDev, cMMDStartIndex, cMMDStepSize] = continuousMMD(trialSize, trialFreq, templateCorrelations, cMMDWindowLength, cMMDStepLength);

%% GFP MMD - Duration is measure in gfp-peaks
gfpMMDWindowLength = 10;
gfpMMDStepLength = 5;
[gfpMMDmean, gfpMMDstdDev, gfpMMDStartIndex, gfpMMDStepSize] = gfpMMD(trialSize, trialFreq, templateCorrelations, gfpPkLocs, gfpMMDWindowLength, gfpMMDStepLength);

%% GFP PPS - Global Field Power Peaks Per Second
gfpPkWindowLength = 10;
gfpPkStepLength = 5;
[gfpPeaksPerSecond, stdDevPeakRate] = gfpPeakRate(trialSize, trialFreq, gfpPkLocs, gfpPkWindowLength, gfpPkStepLength);


%% Plot features %%

% Interpolate sleep stage labels to cover full time course - given labels are assigned to
% the mid-point of the five minute interval, with linear interpolation between.
tNew = linspace(1,numel(sleepStageKey_per5min),size(trialData,2));
sleepStageKey = interp1(sleepStageKey_per5min, tNew);

%% Plot features over time
movie(1:length(cMMDmean)) = struct('cdata', [],'colormap', []);
featureFig = figure;
% Sleep Score
subplot(4,1,1);
hold on;
sleepScorePlot = plot(sleepStageKey,'b');
title(trialLabel);
xlabel('Time (min)');
set(gca, 'XLim', [0 size(trialData,2)]);
set(gca, 'XTick', 0:size(trialData,2)/24:size(trialData,2));
set(gca, 'XTickLabel', 0:5:120);
ylabel('Sleep Score');
set(gca, 'YLim', [-0.5 4.5]);
set(gca, 'YTick', [0 2 3]);
set(gca, 'YTickLabel', {'Awake', 'N2', 'SWS'});
hold off;

% cMMD line plot
subplot(4,1,2)
%title('Continuous MMD');
%xlabel('Time');
% set(gca, 'XLim', [0 size(trialData,2)]);
% set(gca, 'XTick', 0:size(trialData,2)/24:size(trialData,2));
% set(gca, 'XTickLabel', 0:5:120);
ylabel('MMD (ms)');
set(gca, 'YLim', [0 max(cMMDmean)]);
set(gca, 'YTick', 0:0.02:max(cMMDmean));
set(gca, 'YTickLabel', 0:20:max(cMMDmean)*1000);
hold on;
plot(cMMDStartIndex:cMMDStepLength*500:(length(cMMDmean)*cMMDStepLength*500),cMMDmean,'k');

% gfpMMD line plot
subplot(4,1,3)
%title('GFP Peak MMD');
%xlabel('Time');
% set(gca, 'XLim', [0 size(trialData,2)]);
% set(gca, 'XTick', 0:size(trialData,2)/24:size(trialData,2));
% set(gca, 'XTickLabel', 0:5:120);
ylabel('gfpMMD');
% set(gca, 'YLim', [0 max(gfpMMDmean)]);
% set(gca, 'YTick', 0:0.01:max(gfpMMDmean));
% set(gca, 'YTickLabel', 0:10:max(gfpMMDmean)*1000);
hold on;
plot(gfpMMDStartIndex:gfpMMDStepLength*500:(length(gfpMMDmean)*gfpMMDStepLength*500),gfpMMDmean,'k');

subplot(4,1,4)
for i=1:length(trialData)
    plot(gfpPeaksPerSecond{i}, stdDevPeakRate{i}, '.', 'Color', lineColors(i,:));
end
title('GFP Peak rate');
xlabel('GFP Peaks per Second');
ylabel('StdDev of Peak Rate');
legend(trialLabel);


% %% Movie
% % Setup cMMD plot
% subplot(3,1,2)
% title('Continuous MMD');
% xlabel('Mean MMD (ms)');
% set(gca, 'XLim', [0 max(cMMDmean)]);
% set(gca, 'XTick', 0:1/100:floor(max(cMMDmean)));
% set(gca, 'XTickLabel', 0:1/100:floor(max(cMMDmean)));
% ylabel('StdDev MMD');
% set(gca, 'YLim', [0 max(cMMDstdDev)]);
% % set(gca, 'YTickLabel', {'Awake', 'N2', 'SWS'});
% hold on;
% tmlnHndl=[];
% for cMMDIndx=1:length(cMMDmean)
%     smplIndx = cMMDStartIndex + (cMMDStepSize*(cMMDIndx-1));
%     sleepScore = sleepStageKey(smplIndx);
% 
%     % plot cMMD
%     subplot(3,1,2,'replace')
%     title('Continuous MMD');
%     xlabel('Mean MMD (ms)');
%     set(gca, 'XLim', [0 max(cMMDmean)]);
%     set(gca, 'XTick', 0:1/100:floor(max(cMMDmean)));
%     set(gca, 'XTickLabel', 0:1/100:floor(max(cMMDmean)));
%     ylabel('StdDev MMD');
%     set(gca, 'YLim', [0 max(cMMDstdDev)]);
%     set(gca, 'YTick', 1:floor(max(cMMDstdDev)));
%     hold on;
%     plotColors = hot(60);
%     plotColors = plotColors(length(plotColors):-1:1,:);
%     for i=1:cMMDIndx
%         clrIndx = size(plotColors,1);
%         tm = cMMDIndx-i;
%         clrIndx=max(1,clrIndx-tm);
%         pointColor = plotColors(clrIndx,:);
%         if i==cMMDIndx
%             plot(cMMDmean(i), cMMDstdDev(i), '*', 'Color', pointColor);
%         else
%             plot(cMMDmean(i), cMMDstdDev(i), '.', 'Color', pointColor);
%         end
%     end
%     
%     subplot(3,1,1);
%     hold on;
%     if ~isempty(tmlnHndl)
%         set(tmlnHndl,'Visible','off');
%     end
%     tmlnHndl = plot([smplIndx, smplIndx], [0 4],'-k');
%     hold off;
%     movie(cMMDIndx) = getframe(cMMDFig);
%     pause(0.01);
% end




