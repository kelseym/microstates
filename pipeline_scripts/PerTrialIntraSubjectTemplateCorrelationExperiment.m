%% Plot sorted microstate template maps for a single subject while varing the number of allowed microstates

clear;

fileName = GetLocalDataFile();
outputDir = GetLocalOutputDirectory();
trialLength = 60;
numMicrostates = 2;

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


%% Open layout
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

%% partition data into N second (non-)overlaping trials
cfg = [];
cfg.length=trialLength;
cfg.overlap=0.0;
% Concatenate time series data end-to-end in a single trial
data = ConcatenateTrials(data);
% Redistribute into new trial lengths
data = ft_redefinetrial(cfg, data);

%% extract N global microstate templates across all trials
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'local';
globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);

%% extract N microstate templates for each trial
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'trial';
trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);
data.microstateTemplates = trialMicrostateTemplates{1};
% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = data.microstateTemplates{1};
data = AssignMicrostateLabels(cfg, data);

%% Plot N global microstates
% sort global templates by cluster spread
cfg = [];
cfg.clusterstatistic = 'standarddeviation';
cfg.microstatetemplates = globalMicrostateTemplates{1}{1};
globalData = ConcatenateTrials(data);
clusterSpread = TemplateStatistics(cfg, globalData);
[~, globalSortingI] = sort(clusterSpread);
sortedGlobalTemplates = globalMicrostateTemplates{1}{1}(globalSortingI,:);
for msi=1:numMicrostates
  subplot(length(data.trial)+1, numMicrostates, msi);
  PlotMicrostateTemplate(sortedGlobalTemplates(msi,:), data.label, lay);
  title('Global');
end

%% Plot N independant microstates for each trial
%  Sort according to correlation with global templates
for trli=1:length(data.trial)
  templates = data.microstateTemplates{1,trli};
  similarityMatrix = TemplateSetCorrelation(sortedGlobalTemplates, templates);
  for msi=1:numMicrostates
    [maxCorrVal,I] = max(similarityMatrix(msi,:));
    sortedClusterVariance(msi) = maxCorrVal;
    similarityMatrix(:,I) = -Inf;
    subplot(length(data.trial)+1, numMicrostates, numMicrostates*trli+msi);
    PlotMicrostateTemplate(templates(I,:), data.label, lay);
    title(sprintf('%1.2f',sortedClusterVariance(msi)));
  end
end








