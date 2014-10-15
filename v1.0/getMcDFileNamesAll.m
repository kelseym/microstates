%% McDXX file structures
function subjects = getMcDFileNames()
    subjects = {};

    %% McD03
    sub.filenames = {'C:\Projects\EON\R21Dev\McD03_wake_1726-173.edf',...
                'C:\Projects\EON\R21Dev\McD03_SWS_0113-0118.EDF',...
                'C:\Projects\EON\R21Dev\McD03_N2_0057-0102.EDF'};
    sub.subjectLabel = 'McD03';
    sub.trialLabels = {'Wake',...
                  'SWS',...
                  'N2'};
    sub.sensorList = 1:32;

    subjects{end+1} = sub;

    %% McD04
    sub.filenames = {'C:\Projects\McDonnell\McD04_wake_2006-2011.edf',...
                'C:\Projects\McDonnell\McD04_SWS_2151-2156.edf',...
                'C:\Projects\McDonnell\McD04_N2_2131-2136.edf'};
    sub.subjectLabel = 'McD04';
    sub.trialLabels = {'Wake',...
                  'SWS',...
                  'N2'};
    sub.sensorList = [1:8 12:16 20:24 25:40];

    subjects{end+1} = sub;

    %% McD05
    sub.filenames = {'C:\Projects\McDonnell\McD05_wake_2124-2129.edf',...
                'C:\Projects\McDonnell\McD05_SWS_2844-2849.edf',...
                'C:\Projects\McDonnell\McD05_N2_2304-2309.edf'};
    sub.subjectLabel = 'McD05';
    sub.trialLabels = {'Wake',...
                  'SWS',...
                  'N2'};
    sub.sensorList = [5:8 13:16 21:24 29:32];

    subjects{end+1} = sub;

    %% McD06
    sub.filenames = {'C:\Projects\McDonnell\McD06_wake_0349-0354.edf',...
                'C:\Projects\McDonnell\McD06_SWS_0037-0042.edf',...
                'C:\Projects\McDonnell\McD06_N2_0121-0126.edf'};
    sub.subjectLabel = 'McD06';
    sub.trialLabels = {'Wake',...
                  'SWS',...
                  'N2'};
    sub.sensorList = [1:32];

    subjects{end+1} = sub;

    %% McD09
    sub.filename = {'C:\Projects\McDonnell\MCD09_release\MCD09_WAKEA.EDF',...
            'C:\Projects\McDonnell\MCD09_release\MCD09_STAGE2A.EDF',...
            'C:\Projects\McDonnell\MCD09_release\MCD09_SWSA.EDF'};
    sub.subjectLabel = 'McD09';
    sub.trialLabel = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 7,8,70,71
    sub.sensorList = [1:6 9:32];
    subjects{end+1} = sub;
    
    %% McD10
    sub.filename = {'C:\Projects\McDonnell\MCD10_EDF_release\MCD10_WAKEA.EDF',...
            'C:\Projects\McDonnell\MCD10_EDF_release\MCD10_STAGE2A.EDF',...
            'C:\Projects\McDonnell\MCD10_EDF_release\MCD10_SWSA.EDF'};
    sub.subjectLabel = 'McD10';
    sub.trialLabel = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 93, 98
    sub.sensorList = [1:32];
    subjects{end+1} = sub;
    
    %% McD12
    sub.filename = {'C:\Projects\McDonnell\MCD12_WAKEA.EDF',...
            'C:\Projects\McDonnell\MCD12_STAGE2A.EDF',...
            'C:\Projects\McDonnell\MCD12_SWSA.EDF'};
    sub.subjectLabel = 'McD12';
    sub.trialLabel = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 49,57
    sub.sensorList = [1:32];
    subjects{end+1} = sub;
    
    %% McD13
    sub.filename = {'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV_WAKE1.EDF',...
            'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-STAGE2-1.EDF',...
            'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-SWS1.EDF'};
    sub.subjectLabel = 'McD13';
    sub.trialLabel = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 5, 32, 48, 55, 65, 66
    sub.sensorList = [1:4,6:31];
    subjects{end+1} = sub;
    
    
    %% McD07
    sub.filenames = {'C:\Projects\McDonnell\McD07_wake_0253-0258.edf',...
                'C:\Projects\McDonnell\McD07_SWS_0125-0130.edf'};
    sub.subjectLabel = 'McD07';
    sub.trialLabels = {'Wake',...
                  'SWS'};
    sub.sensorList = [1:64];

    subjects{end+1} = sub;

    %% McD08
    sub.filenames = {'C:\Projects\McDonnell\McD08_wake_2037-2042.edf',...
                'C:\Projects\McDonnell\McD08_SWS_0208-0213.edf'};
    sub.subjectLabel = 'McD08';
    sub.trialLabels = {'Wake',...
                  'SWS'};
    sub.sensorList = [22:51];

    subjects{end+1} = sub;

end