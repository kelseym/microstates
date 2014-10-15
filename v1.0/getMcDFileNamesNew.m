%% McDXX file structures
function subjects = getMcDFileNamesNew()
    subjects = {};


    %% McD09A
    sub.filenames = {'C:\Projects\McDonnell\MCD09_release\MCD09_WAKEA.EDF',...
            'C:\Projects\McDonnell\MCD09_release\MCD09_STAGE2A.EDF',...
            'C:\Projects\McDonnell\MCD09_release\MCD09_SWSA.EDF'};
    sub.subjectLabel = 'McD09A';
    sub.trialLabels = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 7,8,70,71
    sub.sensorList = [1:6 9:32];
    subjects{end+1} = sub;

    %% McD10A
    sub.filenames = {'C:\Projects\McDonnell\MCD10_EDF_release\MCD10_WAKEA.EDF',...
            'C:\Projects\McDonnell\MCD10_EDF_release\MCD10_STAGE2A.EDF',...
            'C:\Projects\McDonnell\MCD10_EDF_release\MCD10_SWSA.EDF'};
    sub.subjectLabel = 'McD10A';
    sub.trialLabels = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 93, 98
    sub.sensorList = [1:32];
    subjects{end+1} = sub;
    
    %% McD12
    sub.filenames = {'C:\Projects\McDonnell\MCD12_WAKEB.EDF',...
            'C:\Projects\McDonnell\MCD12_STAGE2B.EDF',...
            'C:\Projects\McDonnell\MCD12_SWSB.EDF'};
    sub.subjectLabel = 'McD12';
    sub.trialLabels = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 49,57
    sub.sensorList = [1:32];
    subjects{end+1} = sub;
    
     %% McD13
    sub.filenames = {'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV_WAKE2.EDF',...
            'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-STAGE2-2.EDF',...
            'C:\Projects\McDonnell\MCD13 clips\130523-B5-12-INV-SWS2.EDF'};
    sub.subjectLabels = 'McD13';
    sub.trialLabel = {'Wake',...
                  'N2',...
                  'SWS'};
    % bad channels 5, 32, 48, 55, 65, 66
    sub.sensorList = [1:4,6:31];
    subjects{end+1} = sub;
    
    

end