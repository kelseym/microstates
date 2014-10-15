% Load 5-minute segments. Concatenate into single trial with labeled segments.

function [numChan, trialData, trialTime, trialFreq, trialSize, trialSampleInfo, trialLabel] = loadContinuousMcD03()

    % baseDirectory = 'D:\Projects\McDonnell\McD03 time series anon';
    baseDirectory = 'D:\Projects\McDonnell\McD03 challenge files';
    filenames = getFiles(baseDirectory);
    sensorList = 1:32;
    % get trial labels
    trialLabel = cell(length(filenames),1);
    for fi=1:length(filenames)
        trialLabel{fi} = ['McD03_' filenames{fi}(end-5:end-4)];
    end

%     filename = {'C:\Projects\McDonnell\McD04_wake_2006-2011.edf',...
%                 'C:\Projects\McDonnell\McD04_SWS_2151-2156.edf',...
%                 'C:\Projects\McDonnell\McD04_N2_2131-2136.edf'};
%     trialLabel = {'McD04 Wake',...
%                   'McD04 SWS',...
%                   'McD04 N2'};


    % compose data as trials if there are more than one file
    for i=1:length(filenames)
        %% Load ECoG data and pre-process
        cfg = [];
        cfg.datafile = filenames{i};
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


end

function fileList = getFiles(baseDir)
    fileList = {};
    list = dir(baseDir);
    for li=1:length(list)
        if strcmp(list(li).name, '.') || strcmp(list(li).name, '..')
            continue;
        elseif list(li).isdir
            fileList = [fileList getFiles([baseDir filesep list(li).name])];
        elseif ~isempty(strfind(list(li).name, '.EDF'))
            fileList{end+1} = fullfile(baseDir, list(li).name);
        end
    end
end

    
    
    
    
    
