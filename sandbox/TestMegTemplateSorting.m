%% Test TemplateSimilarity function's ability to sort templates
clear;

baseDir = GetLocalDataDirectory();
outputDir = GetLocalOutputDirectory();
numMicrostates = 4;


files = dir([baseDir '*.mat']);
for filei=1:3
  fileName = [baseDir files(filei).name];
  [~, scanLabel, ~] = fileparts(fileName);
  
  % select and open preprocessed HCP MEG data file
  load(fileName, 'data');

  % band filter preprocess
  cfg = [];
  cfg.continuous = 'yes';
  cfg.bsfilter = 'yes';
  cfg.bsfreq = [59 61; 119 121; 179 181];
  cfg.demean = 'yes';
  cfg.detrend = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq = [1.0 40.0];
  data = ft_preprocessing(cfg, data);

  % concatenate time series data end-to-end in a single trial
  data = ConcatenateTrials(data);

  %% extract N microstate templates

  % dataStructs contains a cell array of fieldtrip data strutures - which
  % will be concatenated to derive microstate templates - just one for now
  dataStructs{1} = data;

  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataStructs;
  cfg.clustertrainingstyle = 'global';
  microstateTemplates = ExtractMicrostateTemplates(cfg);

  
end