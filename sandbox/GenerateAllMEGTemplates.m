%% Plot N microstate template maps for 20 MEG subjects
clear;


baseDir = '/Users/Kelsey/Projects/EON/MEG 20 subjects/hcp_microstate_data_restin/';
%outputDir = ;
numMicrostates = 4;

files = dir([baseDir '*.mat']);
for filei=1:length(files)
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
  microstateTemplates = ExtractMicrostateTemplates(cfg);


  %% Plot Template Maps
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(microstateTemplates, data.label, lay, scanLabel);

end