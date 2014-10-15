clear;

%% File IDs
filename = {'D:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV_WAKE1.EDF',...
            'D:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV_WWAKE2.EDF',...
            'D:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-STAGE2-1.EDF',...
            'D:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-STAGE2-2.EDF',...
            'D:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-SWS1.EDF',...
            'D:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-SWS2.EDF'};
subjectLabel = 'McD13';
sensorList = 'all';
trialLabel = {'Wake1',...
              'Wake2',...
              'N2',...
              'N2',...
              'SWS',...
              'SWS'};

%% Open and preprocess ECoG data        
for i=1:length(filename)
    cfg = [];
    cfg.datafile = filename{i};
    cfg.channels = sensorList;
    cfg.continuous = 'yes';
    cfg.demean = 'yes';
    cfg.detrend = 'yes';
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [1.0 40.0];
    data = ft_preprocessing(cfg);

    % Visual data inspection
    cfg =[];
    cfg.viewmode = 'vertical';
    cfg.continuous = 'yes';
    cfg.blocksize = 30;
    cfg=ft_databrowser(cfg, data);
    
    % Grab important values from data
    numChan{i} = length(data.label);
    trialData{i} = data.trial{1};
    trialTime{i} = data.time{1};
    trialFreq{i} = data.fsample;
    trialSize{i} = size(trialData{i},2);
    trialSampleInfo{i} = data.sampleinfo;
end          
          



