%% Test TemplateSimilarity function's ability to sort templates
clear;

baseDir = GetLocalDataDirectory();
outputDir = GetLocalOutputDirectory();
numMicrostates = 4;


files = dir([baseDir '*.mat']);
for filei=1:3
  fileName = [baseDir files(filei).name];
  [~, scanLabel{filei}, ~] = fileparts(fileName);
  
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
  dataStructs{filei} = data;

  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataStructs;
  cfg.clustertrainingstyle = 'global';
  templateCells{filei} = ExtractMicrostateTemplates(cfg);
  microstateTemplates{filei} = templateCells{filei}{1}{1};
end

%% Plot Template Maps
for msi=1:length(microstateTemplates);
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(microstateTemplates{msi}, dataStructs{msi}.label, lay, scanLabel{msi});
  
end

%% Sort templates by distance to origin
for msi=1:length(microstateTemplates);
  cfg = [];
  cfg.compareto = 'zero';
  cfg.similaritymetric = 'euclidean';
  distToZero = TemplateSimilarity(microstateTemplates{msi}, cfg);
  [~, distToZeorOrder] = sort(distToZero);
  sortedMicrostateTemplates{msi} = microstateTemplates{msi}(distToZeorOrder,:);
end
  
%% Plot Distance Sorted Template Maps
for msi=1:length(sortedMicrostateTemplates);
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(sortedMicrostateTemplates{msi}, dataStructs{msi}.label, lay, scanLabel{msi});
  
end

% %% Use correlation to the first template set as the method to define order
% sampleTemplateSet = sortedMicrostateTemplates{1};
% corrSortedMicrostateTemplates{1} = sampleTemplateSet;
% for msi=2:length(microstateTemplates);
%   cfg = [];
%   cfg.compareto = 'sample';
%   cfg.sampletemplate = sampleTemplateSet;
%   cfg.similaritymetric = 'correlation';
%   corrToSample = TemplateSimilarity(microstateTemplates{msi}, cfg);
%   [~, corrOrder] = sort(corrToSample);
%   corrSortedMicrostateTemplates{mis} = microstateTemplates{msi}(corrOrder,:);
% end
% 
% %% Plot Correlation Sorted Template Maps
% for msi=1:length(corrSortedMicrostateTemplates);
%   cfg = [];
%   cfg.layout = '4D248.mat';
%   lay = ft_prepare_layout(cfg);
%   fh = PlotMicrostateTemplateSet(corrSortedMicrostateTemplates{msi}, dataStructs{msi}.label, lay, scanLabel{msi});
%   
% end
% 


