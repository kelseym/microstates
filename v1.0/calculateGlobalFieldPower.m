%% calculateGlobalFieldPower.m
% from Brodbeck 2012
% GFP quantifies the overall potential variance across the given set of electrodes.
% High GFP is associated with a stable EEG topography around its peak
%

%% McD03 Grids
%  corr_channels_list_mat = [1 32 ; 33 52] ;
%  bad_channels_list      = [ ] ;
%  grid_size_mat          = [4 8 ; 4 5] ;

clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end
filename = {'C:\Projects\McDonnell\McD03\McD03_wake_1726-173.edf',...
            'C:\Projects\McDonnell\McD03\McD03_SWS_0113-0118.EDF'};

% compose data as trials if there are more than one file
for i=1:length(filename)
    %% Load ECoG data and pre-process
    cfg = [];
    cfg.datafile = filename{i};
    cfg.channels = 1:32;
    cfg.continuous = 'yes';
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [59 61; 119 121; 179 181];
    cfg.demean = 'yes';
    cfg.detrend = 'yes';
    % cfg.polyremoval = 'yes';
    % cfg.polyorder = 2;
    %cfg.preproc.baselinewindow = [-0.1 -.001];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [0.2 40];
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
    % trialTime{i} = trialTime{i}(1:2500);
    % trialData{i} = trialData{i}(1:32, 1:2500);
    trialData{i} = trialData{i}(1:32, :);
    numChan{i} = size(trialData{i},1);
    % trialSize{i} = size(trialData{i},2);
end

%% GFP calculation
for i=1:length(trialData)
    gfp{i} = sqrt(sum(trialData{i}.^2,1)/numChan{i});
    % figure, plot(trialTime{i}, gfp{i});
    % title('Global Field Power');
    % xlabel('Seconds');
    % ylabel('GFP');

    %% Find local maxima
    [gfpPks, gfpPkLocs{i}] = findpeaks(gfp{i},'MINPEAKDISTANCE',3);
    disp(['Found' length(gfpPks) 'GFP local maxima']);
    tLocs = trialTime{i}(gfpPkLocs{i});
    % hold on;
    % plot(tLocs, gfpPks,'g.');
    % highlight peaks > 1 std dev from mean
    mGfp = mean(gfp{i});
    stdGfp = std(gfp{i});
    bigPksI = find(gfpPks>(mGfp+stdGfp));
%     plot(tLocs(bigPksI), gfpPks(bigPksI),'r.');
end

%% Collect voltage potential maps at GFP peaks
% Rows of vpMaps correspond to observations, and columns correspond to channels. 
% Combine all vpMaps for the purpose of template clustering
vpMaps = [];
for i=1:length(trialData)
    vpMaps = cat(1, vpMaps, trialData{i}(:,gfpPkLocs{i})');
end
eucD = pdist(vpMaps, 'euclidean');
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

%% Prepare and display microstate templates
% cfg = [];
% cfg.image = 'C:\Projects\McDonnell\McD03.png';
% lay = ft_prepare_layout(cfg);
% cfg = [];
% cfg.image = 'C:\Projects\McDonnell\McD03.png';
% cfg.layout = lay;
% ft_layoutplot(cfg);

msStruct.label = rawData.label(1:32);
msStruct.fsample = 500;
msStruct.individual = microstateTemplates;
msStruct.dimord = 'subj_chan';

% load('C:\Projects\McDonnell\McD03_1-32_layout.mat');
% 
% for i=1:size(microstateTemplates,1)
%     figure; hold on;
%     ft_plot_lay(lay, 'box', 'off');
%     xPos = lay.pos(1:32,1);
%     yPos = lay.pos(1:32,2);
%     template = microstateTemplates(i,:)';
%     ft_plot_topo(xPos, yPos, template, 'gridscale',150, 'interpmethod', 'nearest');
%     %axis([-0.6 0.6 -0.6 0.6]);
%     axis off;
%     minVP = min(min(microstateTemplates));
%     maxVP = max(max(microstateTemplates));
%     caxis([minVP maxVP]);
%     colorbar
%     title('Microstate Template');
% end

%% Compute correlation between templates and original signal
templateCorrelations = zeros(size(microstateTemplates,1),size(trialData,2));
for i=1:size(microstateTemplates,1)
    template = microstateTemplates(i,:)';
    templateCorrelations(i,:) = corr(template,trialData(:,:));
end
% figure; hold on;
% lineColors = lines;
% title('Correlation with Microstate Templates');
% xlabel('Seconds');
% ylabel('Correlation');
% for i=1:size(templateCorrelations, 1)
%     plot(trialTime, templateCorrelations(i,:),'Color', lineColors(i,:));
% end

%% Plot GFP with microstate designation in color
[maxCorr, maxCorrTemplIdx] = max(templateCorrelations);
[~, tmplSwitchIdx] = find(diff(maxCorrTemplIdx));
% include extra index to catch the final value
tmplSwitchIdx(end+1) = length(maxCorrTemplIdx);
tmplSwitchVal = maxCorrTemplIdx(tmplSwitchIdx);
% figure; hold on;
% plot(trialTime, gfp, 'k');
% title('GFP w/Microstate');
% ylabel('GFP');
% xlabel('Seconds');
% startIdx = 1;
% for i=1:length(tmplSwitchIdx)
%     endIdx = tmplSwitchIdx(i);
%     area(trialTime(startIdx:endIdx), gfp(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal(i),:));
%     startIdx = tmplSwitchIdx(i)+1;
% end

% %% Plot Max Correlation with microstate designation in color
% figure; hold on;
% h1 = plot(trialTime, maxCorr, 'g');
% title('Correlation w/Microstate');
% ylabel('Template Correlation');
% xlabel('Seconds');
% meanCorr = mean(templateCorrelations, 1);
% h2 = plot(trialTime, meanCorr, 'c');
% legend('Max Corr','Avg Corr');
% startIdx = 1;
% for i=1:length(tmplSwitchIdx)
%     endIdx = tmplSwitchIdx(i);
%     area(trialTime(startIdx:endIdx), maxCorr(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal(i),:), 'BaseValue', min(meanCorr));
%     startIdx = tmplSwitchIdx(i)+1;
% end
% uistack(h1, 'top');
% uistack(h2, 'top');

%% Collect features in a 5 second sliding window
% from Brodbeck 2012
% MMD - Mean Microstate Duration (milliseconds)
% RTT - Ratio of Total Time covered (per template)
% PPS - global field Power Peaks per Second
if ~(exist('gfp','var') && exist('gfpPks','var') && exist('gfpPkLocs','var')...
        && exist('trialFreq','var') && exist('maxCorrTemplIdx','var') && exist('trialSize','var'))
    error('Variable check failed');
end
%% MMD - Mean Microstate Duration (milliseconds)
%  computed over a N second sliding window at M second intervals
windowLength = 10; % 5 seconds
windowSize = int32(windowLength*trialFreq);
stepLength = 5; % 1 second
stepSize = int32(stepLength*trialFreq);
if stepSize<1
    error('Selected step size is too small for the resolution of this data.');
end
% maxCorrTemplIdx contains the indices of template maps for each sample
startIndex = floor((windowSize+1)/2);
stopIndex = trialSize - floor((windowSize+1)/2);
numSteps = floor((trialSize-windowSize)/stepSize);
meanMsDuration = [];
stdDevMsDuration = [];
for wndwCntrIdx=startIndex:stepSize:stopIndex
   wndwStrtIdx = wndwCntrIdx-floor(windowSize/2);
   wndwStpIdx  = wndwCntrIdx+floor(windowSize/2)-1;
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

figure; hold on;
[ax,h1,h2] = plotyy(trialTime(startIndex:stepSize:stopIndex), (meanMsDuration/trialFreq)/1000,...
    trialTime(startIndex:stepSize:stopIndex), (stdDevMsDuration/trialFreq)/1000);
xlabel('Time (s)');
axes(ax(1));
ylabel('Mean MS Duration (ms)');
set(ax(1), 'YMinorTick', 'on');
axes(ax(2));
ylabel('Std Dev MS Duration (ms)');
set(ax(2), 'YMinorTick', 'on');


%% T-test
% find step indices for each state
c1MMDIdx = startIndex:stepSize:trialSampleInfo(1,2);
c2MMDIdx = trialSampleInfo(2,1):stepSize:stopIndex;
[t1hMMDMean,t1pMMDMean,t1ciMMDMean] = ttest(meanMsDuration(c1MMDIdx),mean(meanMsDuration(c1MMDIdx)));
[t2hMMDMean,t2pMMDMean,t2ciMMDMean] = ttest(meanMsDuration(c1MMDIdx),meanMsDuration(c2MMDIdx));
[t2hMMDStDev,t2pMMDStDev,t2ciMMDStDev] = ttest(stdDevMsDuration(c1MMDIdx),stdDevMsDuration(c2MMDIdx));

