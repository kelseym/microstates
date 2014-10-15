%% Fieldtrip walkthrough on self EEG
clear;
filename = 'D:\Projects\MEGCONNECTOME\from_ftp\Phase1\HCP_Pilot7_19Dec2011\p0\s5\n0\r0\0'

cfg = [];
cfg.dataset = filename;
cfg.bsfilter = 'yes';
cfg.bsfreq = [59 61; 119 121; 179 181];
trialdata = ft_preprocessing(cfg);


% browse data to look for artifacts
cfg = [];
cfg.viewmode = 'vertical';
cfg.continuous = 'yes';
cfg.blocksize = 10;
cfg = ft_databrowser(cfg,trialdata);

% ICA
cfg = [];
cfg.channel = {'E1' 'E49' 'E9' 'E57' 'E17' 'E25' 'E33' 'E41' 'E3' 'E51' 'E11' 'E59' 'E19' 'E27' 'E35' 'E43' 'E5' 'E53' 'E13' 'E61' 'E21' 'E29' 'E37' 'E45' 'E7' 'E55' 'E15' 'E63' 'E23' 'E31' 'E39' 'E47' 'E2' 'E50' 'E10' 'E58' 'E18' 'E26' 'E34' 'E42' 'E4' 'E52' 'E12' 'E60' 'E20' 'E28' 'E36' 'E44' 'E6' 'E54' 'E14' 'E62' 'E22' 'E30' 'E38' 'E46' 'E8' 'E56' 'E16' 'E64' 'E24' 'E32' 'E40' 'E48'};
ic_data = ft_componentanalysis(cfg,trialdata);

