%% Plot sorted microstate template maps for a single subject while varing the number of allowed microstates

clear;


fileName = GetLocalDataFile();
outputDir = GetLocalOutputDirectory();
microstatesRange = [2,3,4,5,6,7,8,9,10];

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
dataStructs={};
for numMicrostates=microstatesRange;
  % extract N microstate templates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = data;
  cfg.clustertrainingstyle = 'global';
  microstateTemplates = ExtractMicrostateTemplates(cfg);
  data.microstateTemplates = microstateTemplates{1};
  % find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = data.microstateTemplates{1};
  data = AssignMicrostateLabels(cfg, data);
  % compute features
  cfg = [];
  cfg.features = {'statetransitions'};
  data = MeasureFeatures(cfg, data);
  % Store computed microstate set in data struct array
  dataStructs{end+1} = data;
end


%% Find sensors that exist in all scans
sensorLabelIntersection = dataStructs{1}.label;
for scni=2:length(dataStructs)
  sensorLabelIntersection = intersect(sensorLabelIntersection, dataStructs{scni}.label);
end

%% Open layout
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

%% Plot N microstate set with correlation to N-1 set
nTemplateResortIndx = [];
for scni=2:length(dataStructs)
  nMinusOneMicrostateData = dataStructs{scni-1};
  nMicrostateData = dataStructs{scni};
  [a,~] = match_str(nMinusOneMicrostateData.label, sensorLabelIntersection);
  nMinusOneMicrostateTemplates = nMinusOneMicrostateData.microstateTemplates{1}(:,a);
  % this insures that the order of subsequent template plots remain sorted
  if length(nTemplateResortIndx) == size(nMinusOneMicrostateTemplates,1)
    nMinusOneMicrostateTemplates = nMinusOneMicrostateTemplates(nTemplateResortIndx,:);
  end
  [a,~] = match_str(nMicrostateData.label, sensorLabelIntersection);
  nMicrostateTemplates = nMicrostateData.microstateTemplates{1}(:,a);
  % similarityMatrix holds corrilation between ith nMinusOneMicrostateTemplates and jth nMicrostateTemplates
  similarityMatrix = TemplateSetCorrelation(nMinusOneMicrostateTemplates, nMicrostateTemplates);
  % Build a figure which shows nMinusOne templates with their highly correlated counterparts in the n set
  topoFigureH = figure;
  subplot(2,max(size(nMinusOneMicrostateTemplates,1), size(nMicrostateTemplates,1)), 1);
  % compute the number of matches to the ith template
  [~,maxCorrIndx]=max(similarityMatrix,[],1);
  scanDuration = nMinusOneMicrostateData.sampleinfo(2)/nMinusOneMicrostateData.fsample;
  durationFeatureIndex = strcmp(nMinusOneMicrostateData.featurelabels, 'durationpermicrostate');
  % Plot nMinusOneTemplates in first row
  for i=1:size(nMinusOneMicrostateTemplates,1)
    microstateDuration = nMinusOneMicrostateData.featurevalues{durationFeatureIndex}{i};
    colStart = nnz(maxCorrIndx<i)+1;
    colEnd = colStart + nnz(maxCorrIndx==i) - 1;
    subplot(2,max(size(nMinusOneMicrostateTemplates,1), size(nMicrostateTemplates,1)), colStart:colEnd);
    PlotMicrostateTemplate(nMinusOneMicrostateTemplates(i,:), nMinusOneMicrostateData.label, lay);
    title(sprintf('%1.2f', mean(microstateDuration)));
  end
  % Plot nTemplates under highest correlated nMinusOneTemplate
  [~,nTemplateResortIndx] = sort(maxCorrIndx);
  scanDuration = nMicrostateData.sampleinfo(2)/nMicrostateData.fsample;
  durationFeatureIndex = strcmp(nMicrostateData.featurelabels, 'durationpermicrostate');
  for i=1:size(nMicrostateTemplates,1)
    microstateDuration = nMicrostateData.featurevalues{durationFeatureIndex}{i};
    tmpltIndx = nTemplateResortIndx(i);
    subplot(2,max(size(nMinusOneMicrostateTemplates,1), size(nMicrostateTemplates,1)), max(size(nMinusOneMicrostateTemplates,1), size(nMicrostateTemplates,1))+i);
    PlotMicrostateTemplate(nMicrostateTemplates(tmpltIndx,:), nMicrostateData.label, lay);
    title(sprintf('%1.3f', mean(microstateDuration)));
    %title(sprintf('%1.2F', similarityMatrix
  end
  %tightfig;
end








