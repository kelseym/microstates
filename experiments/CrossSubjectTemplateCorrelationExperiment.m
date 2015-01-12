%% Plot sorted microstate template maps across subjects
%   Initial set of microstate templates should be ordered by some metric,
%   while remaining sets will be ordered based on maximum corrilation to
%   the initial set.
clear;


baseDir = GetLocalDataDirectory();
outputDir = GetLocalOutputDirectory();
numMicrostates = 6;

%% Load a few scans and extract microstate templates from each
files = dir([baseDir '1*5-Restin*.mat']);
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

  data = ConcatenateTrials(data);

  %% extract N microstate templates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = data;
  cfg.clustertrainingstyle = 'global';
  microstateTemplates = ExtractMicrostateTemplates(cfg);
  data.microstateTemplates = microstateTemplates{1};
  
  %% find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = data.microstateTemplates{1};
  data = AssignMicrostateLabels(cfg, data);
  
  dataStructs{filei} = data;
  
end

%% Sort templates from first scan by decending cluster "order"

masterData = dataStructs{1};
% compute variance
cfg = [];
cfg.clusterstatistic = 'standarddeviation';
cfg.microstatetemplates = microstateTemplates{1};
clusterSpread = TemplateStatistics(cfg, masterData);
% Plot templates sorted by cluster variance (ascending)
[sortedClusterVariance, I] = sort(clusterSpread);
sortedMasterMicrostateTemplates = masterData.microstateTemplates{1}(I,:);
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
topoFigureH = figure;
hold on;
for i=1:numMicrostates
  subplot(length(dataStructs),numMicrostates,i);
  PlotMicrostateTemplate(sortedMasterMicrostateTemplates(i,:), masterData.label, lay);
end
varianceFigureH = figure;
subplot(length(dataStructs),1,1);
plot(sortedClusterVariance,'b*-','LineWidth', 2);
title('Cluster Spread');
xlabel('Cluster Index');
set(gca, 'XTick', 1:numMicrostates);
set(gca, 'XTickLabel', 1:numMicrostates);

% Find sensors that exist in all scans
sensorLabelIntersection = GetSensorLabelIntersection(dataStructs);

% Match templates from remaining scans to ordered scan
[a,b] = match_str(masterData.label, sensorLabelIntersection);
sortedMasterMicrostateTemplates = sortedMasterMicrostateTemplates(:,a);
for scni=2:length(dataStructs)
  [a,b] = match_str(dataStructs{scni}.label, sensorLabelIntersection);
  microstateTemplatesToMatch = dataStructs{scni}.microstateTemplates{1}(:,a);
  % similarityMatrix holds corrilation between ith masterTemplate and jth comparisonTemplate
  similarityMatrix = TemplateSetCorrelation(sortedMasterMicrostateTemplates, microstateTemplatesToMatch);
  %similarityMatrix = abs(similarityMatrix);
  figure(topoFigureH);
  for i=1:numMicrostates
    % find template with highest abs correlation to Nth master template
    [maxCorrVal,I] = max(similarityMatrix(i,:));
    sortedClusterVariance(i) = maxCorrVal;
    similarityMatrix(:,I) = -Inf;
    subplot(length(dataStructs),numMicrostates,i+(scni-1)*numMicrostates);
    PlotMicrostateTemplate(dataStructs{scni}.microstateTemplates{1}(I,:),dataStructs{scni}.label , lay);
    title(sprintf('%f',maxCorrVal));
  end
  figure(varianceFigureH);
  subplot(length(dataStructs),1,scni);
  plot(sortedClusterVariance,'b*-','LineWidth', 2);
  title('Cluster Variance');
  xlabel('Cluster Index');
  set(gca, 'XTick', 1:numMicrostates);
  set(gca, 'XTickLabel', 1:numMicrostates);
  
end

  






