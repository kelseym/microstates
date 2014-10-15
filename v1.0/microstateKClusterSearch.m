clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end
lineColors = lines;close;

filename = {'C:\Projects\EON\R21Dev\McD03_wake_1726-173.edf',...
            'C:\Projects\EON\R21Dev\McD03_SWS_0113-0118.EDF',...
            'C:\Projects\EON\R21Dev\McD03_N2_0057-0102.EDF'};
trialLabel = {'Wake',...
              'SWS',...
              'N2'};
sensorList = 1:32;

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

%% GFP calculation
for i=1:length(trialData)
    gfp{i} = sqrt(sum(trialData{i}.^2,1)/numChan{i});

    %% Find local maxima
    [gfpPks, gfpPkLocs{i}] = findpeaks(gfp{i},'MINPEAKDISTANCE',3);
    disp(['Found ' num2str(length(gfpPks)) ' GFP local maxima in ' trialLabel{i}]);
    tLocs = trialTime{i}(gfpPkLocs{i});
    mGfp = mean(gfp{i});
    stdGfp = std(gfp{i});
    bigPksI = find(gfpPks>(mGfp+stdGfp));
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


%% Collect voltage potential maps at GFP peaks
% Rows of vpMaps correspond to observations, and columns correspond to channels. 
% Combine all vpMaps for the purpose of template clustering
vpMaps = [];
for i=1:length(trialData)
    vpMaps = cat(1, vpMaps, trialData{i}(:,gfpPkLocs{i})');
end
eucD = pdist(vpMaps, 'euclidean');
clustTreeEuc = linkage(eucD, 'average');

%% Calculate N microstate template maps as the mean average of all member vpMaps
%  Track GEV - Global Explained Variance - for each N
%  Track per map and per number of number of maps N, for each trial
maxNumMicroStates = 20;
globalExVarK = cell(length(trialData),maxNumMicroStates);
globalExVar = zeros(length(trialData),maxNumMicroStates);
for numMicrostates=1:maxNumMicroStates
    % Cluster concatenated vpMaps
    mapMembership = cluster(clustTreeEuc,'maxclust',numMicrostates);
    microstateTemplates = zeros(numMicrostates, size(vpMaps,2));
    for i=1:numMicrostates
        meanMap = mean(vpMaps(mapMembership == i, :), 1);
        microstateTemplates(i, :) = meanMap(:);
    end
    % Compute correlation between templates and original signal
    templateCorrelations = cell(1,length(trialData));
    maxCorr = cell(1,length(trialData));
    maxCorrTemplIdx = cell(1,length(trialData));
    for trli=1:length(trialData)
        templateCorrelations{trli} = zeros(size(microstateTemplates,1),size(trialData{trli},2));
        for j=1:size(microstateTemplates,1)
            template = microstateTemplates(j,:)';
            templateCorrelations{trli}(j,:) = abs(corr(template,trialData{trli}(:,:)));
        end
        % Label each sample with 1 of N templates, corresponding to max correlation
        [maxCorr{trli}, maxCorrTemplIdx{trli}] = max(templateCorrelations{trli},[],1);
    end
    %% Compute GEV - maps are generated using concatonated data, but GEV can be reported per trial
    %   compute per map
    for trli=1:length(trialData)
        gevk = zeros(numMicrostates,1);
        for msi=1:numMicrostates
            tmpltMtchMsk = maxCorrTemplIdx{trli} == msi;
            prod = gfp{trli}(tmpltMtchMsk).*templateCorrelations{trli}(msi,tmpltMtchMsk);
            numer = sumsqr(prod);
            denom = sumsqr(gfp{trli}(tmpltMtchMsk));
            gevk(msi) = numer/denom;
        end
        globalExVarK{trli, numMicrostates} = gevk;
    end
    % compute overall, as a check
    for trli=1:length(trialData)
        numer = sumsqr(gfp{trli}.*maxCorr{trli});
        denom = sumsqr(gfp{trli});
        gev = numer/denom;
        globalExVar(trli, numMicrostates) = gev;
    end
end

%% Plot GEV
figure, hold on;
title('Template Quantity Selection');
ylabel('GEV');
xlabel('Number of Microstate Templates');
for trli=1:length(trialData)
   plot(globalExVar(trli, :),'-','Color', lineColors(trli,:), 'LineWidth', 3);
end
plot(mean(globalExVar(:, :),1),'k.-', 'LineWidth', 3);
legend([trialLabel {'Average'}], 'Location', 'SouthEast');
grid off;
set(gca, 'XGrid', 'on');
xlim([1 maxNumMicroStates]);




