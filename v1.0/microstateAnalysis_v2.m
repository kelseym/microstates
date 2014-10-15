%% microstateAnalysis.m

%% McD03 Grids
%  corr_channels_list_mat = [1 32 ; 33 52] ;
%  bad_channels_list      = [ ] ;
%  grid_size_mat          = [4 8 ; 4 5] ;

clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end
showNSecPlots = 5;
lineColors = lines;close;

% filename = {'C:\Projects\EON\R21Dev\McD03_wake_1726-173.edf',...
%             'C:\Projects\EON\R21Dev\McD03_SWS_0113-0118.EDF',...
%             'C:\Projects\EON\R21Dev\McD03_N2_0057-0102.EDF'};
% subjectLabel = 'McD03';
% trialLabel = {'Wake',...
%               'SWS',...
%               'N2'};
% sensorList = 1:32;
% 
% filename = {'C:\Projects\McDonnell\McD04_wake_2006-2011.edf',...
%             'C:\Projects\McDonnell\McD04_SWS_2151-2156.edf',...
%             'C:\Projects\McDonnell\McD04_N2_2131-2136.edf'};
% subjectLabel = 'McD04';
% trialLabel = {'Wake',...
%               'SWS',...
%               'N2'};
% sensorList = [1:8 12:16 20:24 25:40];

% filename = {'C:\Projects\McDonnell\McD05_wake_2124-2129.edf',...
%             'C:\Projects\McDonnell\McD05_SWS_2844-2849.edf',...
%             'C:\Projects\McDonnell\McD05_N2_2304-2309.edf'};
% subjectLabel = 'McD05';
% trialLabel = {'Wake',...
%               'SWS',...
%               'N2'};
% sensorList = [5:8 13:16 21:24 29:32];

% filename = {'C:\Projects\McDonnell\McD06_wake_0349-0354.edf',...
%             'C:\Projects\McDonnell\McD06_SWS_0037-0042.edf',...
%             'C:\Projects\McDonnell\McD06_N2_0121-0126.edf'};
% subjectLabel = 'McD06';
% trialLabel = {'Wake',...
%               'SWS',...
%               'N2'};
% sensorList = [1:64];

% filename = {'C:\Projects\McDonnell\McD07_wake_0253-0258.edf',...
%             'C:\Projects\McDonnell\McD07_SWS_0125-0130.edf'};
% subjectLabel = 'McD07';
% trialLabel = {'Wake',...
%               'SWS'};
% sensorList = [1:64];

% filename = {'C:\Projects\McDonnell\McD08_wake_2037-2042.edf',...
%             'C:\Projects\McDonnell\McD08_SWS_0208-0213.edf'};
% subjectLabel = 'McD08';
% trialLabel = {'Wake',...
%               'SWS'};
% sensorList = [22:51];

filename = {'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV_WAKE1.EDF',...
            'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-STAGE2-1.EDF',...
            'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-SWS1.EDF'};
subjectLabel = 'McD08';
trialLabel = {'Wake',...
              'N2',...
              'SWS'};
% bad channels 5, 32, 48, 55, 65, 66
sensorList = [1:4,6:31,33:47,49:64,67:70];


% compose data as trials if there are more than one file
for i=1:length(filename)
    %% Load ECoG data and pre-process
    cfg = [];
    cfg.datafile = filename{i};
    cfg.channels = sensorList;
    cfg.continuous = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [59 61; 119 121; 179 181];
    cfg.demean = 'yes';
    cfg.detrend = 'yes';
    % cfg.polyremoval = 'yes';
    % cfg.polyorder = 2;
    %cfg.preproc.baselinewindow = [-0.1 -.001];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [1.0 40.0];
    data = ft_preprocessing(cfg);

    % Grab important values from data
    numChan{i} = length(data.label);
    trialData{i} = data.trial{1};
    trialTime{i} = data.time{1};
    trialFreq{i} = data.fsample;
    trialSize{i} = size(trialData{i},2);
    trialSampleInfo{i} = data.sampleinfo;
end

% restrict to 32 channels on grid 1 and the first 5 seconds for testing 
for i=1:length(trialData)
    trialData{i} = trialData{i}(sensorList, :);
% %     %%%% Remove these lines to include full time course. From here,
%     trialTime{i} = trialTime{i}(1:2500);
%     trialData{i} = trialData{i}(sensorList, 1:2500);
%     numChan{i} = size(trialData{i},1);
% %     %%%%% to here
    trialSize{i} = size(trialData{i},2);
end

%% Plot trial data
for i=1:length(trialData)
    if showNSecPlots > 0
        pltSmpls = 1:showNSecPlots*trialFreq{i};
        figure;
        title([trialLabel{i}]);
        xlabel('Seconds');
        ylabel('Sensor Potential');
        set(gca, 'YTickLabel', '');
        hold on;
        data = trialData{i}(:,pltSmpls);
        mx = max(max(data));
        mn = min(min(data));
        data = data-mn;
        data = data/(mx-mn)*1.3;
        for j=1:size(data,1)
            plot(trialTime{i}(pltSmpls), data(j,:)+j, 'k');
        end
    end
end

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
        pltPksIndx{i} = gfpPkLocs{i}(gfpPkLocs{i}<(showNSecPlots*trialFreq{i}));
        plot(trialTime{i}(pltPksIndx{i}), gfp{i}(pltPksIndx{i}),'g.');
        % highlight peaks > N std dev from mean
        pltBigPksIndx{i} = bigGfpPkLocs{i}(bigGfpPkLocs{i}<(showNSecPlots*trialFreq{i}));
        plot(trialTime{i}(pltBigPksIndx{i}), gfp{i}(pltBigPksIndx{i}),'r.');
    end
%     gfpPkLocs = bigGfpPkLocs;
end

%% GFP Scrambler
%   Include this code to switch gfp to trial assignment
%   This should be used to validate the gfp peak approach
% gfpPkLocs = circshift(gfpPkLocs, [0 1]);
% gfp = circshift(gfp, [0 1]);
% or 
% evenly spaced sampling of the gfp
% meanPeakCount = 0;
% for i=1:length(trialData)
%     meanPeakCount = meanPeakCount + length(gfpPkLocs{i});
% end
% meanPeakCount = round(meanPeakCount/length(trialData));
% % meanPeakCount = 700;
% for i=1:length(trialData)
%     gfpPkLocs{i} = round(linspace(1, length(gfp{i}), meanPeakCount));
% end
%

% % %% Optionally replace real data with white noise
% trialData = generateWhiteNoiseTrials(trialData, [1.0 40.0], trialFreq);

%% Collect voltage potential maps at GFP peaks
% Rows of vpMaps correspond to observations, and columns correspond to channels. 
% Combine all vpMaps for the purpose of template clustering
vpMaps = [];
for i=1:length(trialData)
    vpMaps = cat(1, vpMaps, trialData{i}(:,gfpPkLocs{i})');
end
eucD = pdist(vpMaps, 'correlation');
clustTreeEuc = linkage(eucD, 'average');
% cophenet(clustTreeEuc,eucD)
% [h,nodes] = dendrogram(clustTreeEuc,0);
% set(gca,'TickDir','out','TickLength',[.002 0],'XTickLabel',[]);

%% Calculate N microstate template maps as the mean average of all member vpMaps
%  Start with hard coded N=numMicrostates=4
numMicrostates = 4;
mapMembership = cluster(clustTreeEuc,'maxclust',numMicrostates);
microstateTemplates = zeros(numMicrostates, size(vpMaps,2));
for i=1:numMicrostates
    meanMap = mean(vpMaps(mapMembership == i, :), 1);
    microstateTemplates(i, :) = meanMap(:);
end

%% Template Scrambler
%   Include this code to replace the N computed microstateTemplates with N random
%   templates from vpMaps
% microstateTemplates = zeros(numMicrostates, size(vpMaps,2));
% for i=1:numMicrostates
%     randomIndices = round(sort(1+(rand(round(length(vpMaps)/4),1)*(length(vpMaps)-1))));
%     meanMap = mean(vpMaps(randomIndices, :), 1);
%     meanMap = rand(size(meanMap,1),size(meanMap,2),1);
%     microstateTemplates(i, :) = meanMap(:);
% end
%

%% Prepare and display microstate templates
% cfg = [];
% cfg.image = 'C:\Projects\McDonnell\4x8grid.png';
% lay = ft_prepare_layout(cfg);
% cfg = [];
% cfg.image = 'C:\Projects\McDonnell\4x8grid.png';
% cfg.layout = lay;
% ft_layoutplot(cfg);

%%
% if showNSecPlots > 0
%     %msStruct.label = rawData.label(1:32);
%     msStruct.fsample = 500;
%     msStruct.individual = microstateTemplates;
%     msStruct.dimord = 'subj_chan';
%     load('C:\Projects\McDonnell\4x8grid.mat');
%     figure; hold on;
%     for i=1:size(microstateTemplates,1)
%         subplot(ceil(numMicrostates/2),2,i);
%         ft_plot_lay(lay, 'box', 'no', 'label', 'no', 'mask', 'no');
%         xPos = lay.pos(1:32,1);
%         yPos = lay.pos(1:32,2);
%         template = microstateTemplates(i,:)';
%         ft_plot_topo(xPos, yPos, template, 'gridscale',150, 'interpmethod', 'nearest');
%         %axis([-0.6 0.6 -0.6 0.6]);
%         axis off;
%         minVP = min(min(microstateTemplates));
%         maxVP = max(max(microstateTemplates));
%         caxis([minVP maxVP]);
%         colorbar
%         title('Microstate Template');
%     end
% end
%% Compute correlation between templates and original signal
templateCorrelations = cell(1,length(trialData));
for i=1:length(trialData)
    templateCorrelations{i} = zeros(size(microstateTemplates,1),size(trialData{i},2));
    for j=1:size(microstateTemplates,1)
        template = microstateTemplates(j,:)';
        templateCorrelations{i}(j,:) = abs(corr(template,trialData{i}(:,:)));
    end
end

if showNSecPlots > 0
    %% Plot correlation per template
    for i=1:length(trialData)
    pltSmpls = 1:showNSecPlots*trialFreq{i};
        figure; hold on;
        title([trialLabel{i} ' - Correlation with Microstate Templates']);
        xlabel('Seconds');
        ylabel('Correlation');
        for j=1:size(templateCorrelations{i}(:,pltSmpls), 1)
            plot(trialTime{i}(pltSmpls), templateCorrelations{i}(j,pltSmpls),'Color', lineColors(j,:));
        end
    end
    %% Plot GFP with microstate designation in color
    figure;
    for i=1:length(trialData)
        subplot(length(trialData),1,i);
        hold on;
        [maxCorr{i}, maxCorrTemplIdx{i}] = max(templateCorrelations{i}(:,pltSmpls),[],1);
        [minCorr{i}, minCorrTemplIdx{i}] = min(templateCorrelations{i}(:,pltSmpls),[],1);
        [~, tmplSwitchIdx{i}] = find(diff(maxCorrTemplIdx{i}));
        % include extra index to catch the final value
        tmplSwitchIdx{i}(end+1) = length(maxCorrTemplIdx{i});
        tmplSwitchVal{i} = maxCorrTemplIdx{i}(tmplSwitchIdx{i});
        
        plot(trialTime{i}(pltSmpls), gfp{i}(pltSmpls),'k');
        ylabel([trialLabel{i} ' GFP']);
        if i==length(trialData)
            xlabel('Time (s)');
        elseif i==1
            title([subjectLabel ' - Microstate Labeled GFP']);
        end
        startIdx = 1;
        for j=1:length(tmplSwitchIdx{i})
            endIdx = tmplSwitchIdx{i}(j);
            area(trialTime{i}(startIdx:endIdx), gfp{i}(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal{i}(j),:),'EdgeColor', 'k', 'LineStyle', 'none', 'LineWidth', 0.1);
            startIdx = tmplSwitchIdx{i}(j)+1;
        end
        hold off;
    end
    %% Plot Min Max Correlation with microstate designation in color
    for i=1:length(trialData)
        figure; hold on;
        h1 = plot(trialTime{i}(pltSmpls)*1000, maxCorr{i}, 'g');
        h1b = plot(trialTime{i}(pltSmpls)*1000, abs(minCorr{i}), 'b');
        h1c = plot(trialTime{i}(pltPksIndx{i})*1000, maxCorr{i}(pltPksIndx{i}),'r.');
        title([trialLabel{i} ' - Min Max Correlation w/Microstate']);
        ylabel('Template Correlation');
        xlabel('Time (ms)');
%         meanCorr = mean(templateCorrelations{i}(:,pltSmpls), 1);
%         h2 = plot(trialTime{i}(pltSmpls)*1000, meanCorr, 'c');
         legend('Max Corr','ABS Min Corr', 'GFP Peaks');
%         startIdx = 1;
%         for j=1:length(tmplSwitchIdx{i})
%             endIdx = tmplSwitchIdx{i}(j);
%             area(trialTime{i}(startIdx:endIdx)*1000, maxCorr{i}(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal{i}(j),:), 'BaseValue', min(meanCorr));
%             startIdx = tmplSwitchIdx{i}(j)+1;
%         end
%         uistack(h1, 'top');
%         uistack(h2, 'top');
    end
    %% Plot Sum of Correlation with microstate designation in color with gfp
    for i=1:length(trialData)
        figure; hold on;
        plot(trialTime{i}(pltSmpls)*1000, gfp{i}(pltSmpls)/100,'k');
        title([trialLabel{i} ' - Correlation w/Microstate']);
        ylabel('Template Correlation');
        xlabel('Time (ms)');
        sumCorr = sum(templateCorrelations{i}(:,pltSmpls), 1);
        h2 = plot(trialTime{i}(pltSmpls)*1000, sumCorr, 'r');
        h1 = plot(trialTime{i}(pltSmpls)*1000, maxCorr{i}, 'g');
        legend('GFP','Sum Corr','Max Corr');
        startIdx = 1;
%         for j=1:length(tmplSwitchIdx{i})
%             endIdx = tmplSwitchIdx{i}(j);
%             area(trialTime{i}(startIdx:endIdx)*1000, maxCorr{i}(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal{i}(j),:), 'BaseValue', min(meanCorr));
%             startIdx = tmplSwitchIdx{i}(j)+1;
%         end
%         uistack(h1, 'top');
%         uistack(h2, 'top');
    end
end

%% Collect features in a N second sliding window
% from Brodbeck 2012
% MMD - Mean Microstate Duration (milliseconds)
% PPS - global field Power Peaks per Second
% RTT - Ratio of Total Time covered (per template)

%% Microstate Dominance
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [stateDom{i}, ~,~] = stateDominance(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
end
figure, hold on;
for i=1:length(trialData)
    plot(stateDom{i}, '.', 'Color', lineColors(i,:));
end
title('Microstate Dominance');
xlabel('Sample');
ylabel('Microstate Dominance');
legend(trialLabel);

figure, hold on;
for i=1:length(trialData)
    [N,X]=hist(stateDom{i}, 10);
    barh(i) = bar(X,N, 'FaceColor', lineColors(i,:));
end
[N,X]=hist(stateDom{1},5);

title('Microstate Dominance');
xlabel('Mean Microstate Dominance');
legend(trialLabel);

%% Continuous MMD
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [cMMDmean{i}, cMMDstdDev{i}, ~,~] = continuousMMD(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
end
figure, hold on;
for i=1:length(trialData)
    plot(cMMDmean{i}*1000, cMMDstdDev{i}, '.', 'Color', lineColors(i,:));
end
title('Microstate Duration');
xlabel('Mean Duration (ms)');
ylabel('StdDev of Duration');
legend(trialLabel);

%% GFP MMD - Duration is measure in gfp-peaks
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [gfpMMDmean{i}, gfpMMDstdDev{i}] = gfpMMD(trialSize{i}, trialFreq{i}, templateCorrelations{i}, gfpPkLocs{i}, windowLength, stepLength);
end
figure, hold on;
for i=1:length(trialData)
    plot(gfpMMDmean{i}, gfpMMDstdDev{i}, '.', 'Color', lineColors(i,:));
end
title('GFP MMD');
xlabel('Mean MMD (gfp peaks)');
ylabel('StdDev MMD (gfp peaks)');
legend(trialLabel);

%% GFP PPS - Global Field Power Peaks Per Second
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [gfpPeaksPerSecond{i}, stdDevPeakRate{i}] = gfpPeakRate(trialSize{i}, trialFreq{i}, gfpPkLocs{i}, windowLength, stepLength);
end
figure, hold on;
for i=1:length(trialData)
    plot(gfpPeaksPerSecond{i}, stdDevPeakRate{i}, '.', 'Color', lineColors(i,:));
end
title('GFP Peak Rate');
xlabel('GFP Peaks per Second');
ylabel('StdDev of Peak Rate');
legend(trialLabel);

%% RTT - Ratio of Total Time covered (per template)
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    ratioTotalTimePerTemplate{i} = ratioOfTemplageCoverage(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
end

figure, hold on;
title('Ratio of Microstate Template Coverage');
for i=1:length(trialData)
    for j=1:size(ratioTotalTimePerTemplate{i},2)
        meanRatio = mean(ratioTotalTimePerTemplate{i}(:,j));
        stdDevRatio = std(ratioTotalTimePerTemplate{i}(:,j));
        barData(i,j) = meanRatio;
        stdDevData(i,j) = stdDevRatio;
    end
end
barH = bar(barData, 'grouped');
set(gca,'XTick',1:length(trialLabel));
set(gca,'XTickLabel',trialLabel);
barLoc = [];
sdlh = [];
for gi=get(gca,'XTick')
   gWidth = get(barH,'BarWidth');
   for bi=1:length(gWidth)
       gW = gWidth{bi}*.93;
       bWidth = gW/length(gWidth);
       barLoc(gi,bi) = (gi-gW/2)+(bi-1)*bWidth+bWidth/2;
       sdlh(end+1) = plot([barLoc(gi,bi), barLoc(gi,bi)],[barData(gi,bi)-stdDevData(gi,bi), barData(gi,bi)+stdDevData(gi,bi)], '-k', 'LineWidth',3);
   end
end
leg = {};
for i=1:length(gWidth)
    leg{end+1} = ['T' num2str(i)];
end
leg{end+1} = 'StdDev';
legend(leg,'Location','BestOutside');
% plot mean values on bar graph
for gi=get(gca,'XTick')
   gWidth = get(barH,'BarWidth');
   for bi=1:length(gWidth)
    y = ratioTotalTimePerTemplate{gi}(:,bi);
    x = repmat(barLoc(gi,bi),length(y),1);
    x = x+(rand(size(x))-0.5)*0.08; % Add jitter to x for visibility
    plot(x,y,'*r','MarkerSize',2);
   end
end
for i=1:length(sdlh)
    uistack(sdlh(i),'top');
end
hold off


% %% Mean Duration per Template
% %   average temporal duration of individual templates
% windowLength = 10;
% stepLength = 5;
% for i=1:length(trialData)
%     meanTemplateDuration{i} = meanDurationPerTemplate(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
% end



% %% Plot MMD with color designating state dominance
% minDom = 1;
% maxDom = -1;
% for i=1:length(trialData)
%     minDom = min(minDom, min(stateDom{i}));
%     maxDom = max(maxDom, max(stateDom{i}));
% end
% 
% clrs = hot(101);
% smbls = '*o+';
% figure, hold on;
% for i=1:length(trialData)
%     for j=1:length(cMMDmean{i})
%         clrIndx = round((stateDom{i}(j)-minDom)/(maxDom-minDom)*100)+1;
%         plot(cMMDmean{i}*1000, cMMDstdDev{i}, '.', 'Color', clrs(clrIndx,:));
%     end
% end
% title('Continuous MMD');
% xlabel('Mean MMD (ms)');
% ylabel('StdDev MMD');
% legend(trialLabel);
% 



%% T-test
featureLabels = {};
tTestResults = {};
wakeIndex = find(strcmp('Wake', trialLabel));
swsIndex =  find(strcmp('SWS', trialLabel));
n2Index =  find(strcmp('N2', trialLabel));
% cMMDmean
featureLabels{end+1} = 'cMMDmean';
for i=1:length(trialLabel)
    for j=1:length(trialLabel)
        if i==j
            continue;
        end
        test=[trialLabel{i} 'vs' trialLabel{j}];
        [h(i,j),p(i,j),ci(i,j,:)] = ttest2(cMMDmean{i},cMMDmean{j});
    end
end
ttest_h_cMMDmean = h;
ttest_p_cMMDmean = p;
ttest_ci_cMMDmean = ci;

% cMMDstdDev
featureLabels{end+1} = 'cMMDstdDev';
for i=1:length(trialLabel)
    for j=1:length(trialLabel)
        if i==j
            continue;
        end
        test=[trialLabel{i} 'vs' trialLabel{j}];
        [h(i,j),p(i,j),ci(i,j,:)] = ttest2(cMMDstdDev{i},cMMDstdDev{j});
    end
end
ttest_h_cMMDstdDev = h;
ttest_p_cMMDstdDev = p;
ttest_ci_cMMDstdDev = ci;
% gfpPeaksPerSecond
featureLabels{end+1} = 'gfpPeaksPerSecond';
for i=1:length(trialLabel)
    for j=1:length(trialLabel)
        if i==j
            continue;
        end
        test=[trialLabel{i} 'vs' trialLabel{j}];
        [h(i,j),p(i,j),ci(i,j,:)] = ttest2(gfpPeaksPerSecond{i},gfpPeaksPerSecond{j});
    end
end
ttest_h_gfpPeaksPerSecond = h;
ttest_p_gfpPeaksPerSecond = p;
ttest_ci_gfpPeaksPerSecond = ci;
% stdDevPeakRate
featureLabels{end+1} = 'stdDevPeakRate';
for i=1:length(trialLabel)
    for j=1:length(trialLabel)
        if i==j
            continue;
        end
        test=[trialLabel{i} 'vs' trialLabel{j}];
        [h(i,j),p(i,j),ci(i,j,:)] = ttest2(stdDevPeakRate{i},stdDevPeakRate{j});
    end
end
ttest_h_stdDevPeakRate = h;
ttest_p_stdDevPeakRate = p;
ttest_ci_stdDevPeakRate = ci;
% stateDom
featureLabels{end+1} = 'stateDom';
for i=1:length(trialLabel)
    for j=1:length(trialLabel)
        if i>j
            test=[trialLabel{i} 'vs' trialLabel{j}];
            [h(i,j),p(i,j),ci(i,j,:)] = ttest2(stateDom{i},stateDom{j});
        end
    end
end
ttest_h_stateDom = h;
ttest_p_stateDom = p;
ttest_ci_stateDom = ci;


