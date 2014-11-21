%% Plot N microstate template maps for 20 MEG subjects
clear;


baseDir = GetLocalDataDirectory();
outputDir = GetLocalOutputDirectory();
numMicrostates = 5;

outputDir = [outputDir sprintf('%i microstates',numMicrostates)];
mkdir(outputDir);

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

  % Reshape data into N second trials to define windows for feature exraction
  data = ConcatenateTrials(data);
  cfg = [];
  cfg.length = 15;
  cfg.overlap = 0.0;
  data = ft_redefinetrial(cfg, data);

  %% extract N microstate templates

  % dataStructs contains a cell array of fieldtrip data strutures - which
  % will be concatenated to derive microstate templates - just one for now
  dataStructs{1} = data;

  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataStructs;
  cfg.clustertrainingstyle = 'global';
  microstateTemplates = ExtractMicrostateTemplates(cfg);


  %% Plot Template Maps
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}, data.label, lay, scanLabel);

  %% Save output file
  outputFileName = sprintf('%s_%i_templates', scanLabel, numMicrostates);
  saveas(fh, [outputDir filesep outputFileName], 'png');
  close(fh);
  pause(1);
  
  %% find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = microstateTemplates{1}{1};
  for i=1:length(dataStructs)
    dataStructs{i} = AssignMicrostateLabels(cfg, dataStructs{i});
  end
  
  %% Plot microstate sequence: time in sec, visualize small segment of full microstate seq
  cfg = [];
  cfg.trialindex = 1;
  cfg.starttime = 1;
  cfg.endtime = 5;
  fh = PlotMicrostateSequence(dataStructs{1}, cfg);
  outputFileName = sprintf('%s_%i_templates_microstateSequence', scanLabel, numMicrostates);
  saveas(fh, [outputDir filesep outputFileName], 'png');
  close(fh);
  pause(1);

  
  %% extract features from microstate sequence
  cfg = [];
  cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks'};
  for i=1:length(dataStructs)
    dataStructs{i} = MeasureFeatures(cfg, dataStructs{i});
  end
  
  %% Plot microstate features
  data = dataStructs{1};
  fh = PlotFeatureXY(data, 'meanduration', 'stdduration','Microstate Features');
  outputFileName = sprintf('%s_%i_templates_duration', scanLabel, numMicrostates);
  saveas(fh, [outputDir filesep outputFileName], 'png');
  close(fh);
  pause(1);


  data = dataStructs{1};
  fh = PlotFeatureXY(data, 'gfppeakrate','stdgfppeaks','Microstate Features');
  outputFileName = sprintf('%s_%i_templates_gfppeaks', scanLabel, numMicrostates);
  saveas(fh, [outputDir filesep outputFileName], 'png');
  close(fh);
  pause(1);

end
