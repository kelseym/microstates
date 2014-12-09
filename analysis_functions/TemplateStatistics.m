%% Microstate template cluster measure

%   Measure cluster statistics such as spatial contrast, roughness (local maxima) or variance

%   Input:
%   data - required for cluster variance statistic
%   cfg.clusterstatistic = 'spatialcontrast', 'roughness', 'variance', 'standarddeviation'
%   cfg.microstatetemplates = NxS matrix where each row defines microstates template over S sensors

%   cfg.sensorneighbors = fieldtrip style neighbor structure - required for used with 'spatialcontrast'
%   cfg.sensorlabels = fieldtrip label array (from data.label) - required for used with 'spatialcontrast'
%   cfg.similaritymetric = 'euclidean' (default), 'correlation' - used with cfg.compareto='eachother'|'zero'|'sample'
%   cfg.ignorepolarity = 'yes' (default), 'no'- used with cfg.compareto!='self'

function statisticMatrix = TemplateStatistics(cfg, data)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'clusterstatistic'});

  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'clusterstatistic', 'char', {'spatialcontrast','roughness','variance','standarddeviation'});

  % get the options
  microstateTemplates = ft_getopt(cfg, 'microstatetemplates');
  clusterStatistic = ft_getopt(cfg, 'clusterstatistic','spatialcontrast');
  
  sensorNeighbors = ft_getopt(cfg, 'sensorneighbors');
  sampleTemplate = ft_getopt(cfg, 'sampletemplate', []);
  ignorePolarity = ft_getopt(cfg, 'ignorepolarity', 'no');

  %% Gather statistics for each cluster independently
  if strcmp(clusterStatistic, 'spatialcontrast')
    if ~isempty(sensorNeighbors)
      sensorContrast = ComputeSpatialContrast(microstateTemplates, data.label, sensorNeighbors);
      statisticMatrix = mean(sensorContrast,2);
    else
      error('Missing sensorneighbors structure');
    end
  elseif strcmp(clusterStatistic, 'roughness')
      sensorRoughness = ComputeMeanLocalMaxima(microstateTemplates, data.label, sensorNeighbors);
      statisticMatrix = sensorRoughness;
  elseif strcmp(clusterStatistic, 'variance')
    if isfield(data, 'microstateIndices')
      clusterVariance = ComputeClusterVariance(data);
      statisticMatrix = clusterVariance;
    else
      error('data structure is missing microstateIndices field');
    end
  elseif strcmp(clusterStatistic, 'standarddeviation')
    if isfield(data, 'microstateIndices')
      clusterVariance = ComputeClusterStandardDeviation(data);
      statisticMatrix = clusterVariance;
    else
      error('data structure is missing microstateIndices field');
    end
  else
    error('Unknown clusterstatistic option.');
  end
      
  
end

% Return the average spatial contrast for each sensor for each microstate template
function sensorContrast = ComputeSpatialContrast(microstateTemplates, sensorLabels, sensorNeighbors)
  sensorContrast = zeros(size(microstateTemplates));
  for ti=1:size(microstateTemplates,1)
    for si=1:length(sensorNeighbors)
      [lblIndx, ~] = match_str(sensorLabels, sensorNeighbors(si).label);
      if ~isempty(lblIndx)
        [~, nghbrhdIndcs] = match_str(sensorNeighbors(si).neighblabel, sensorLabels);
        neighborhoodValues = microstateTemplates(ti, nghbrhdIndcs);
        sensorContrast(ti, lblIndx) = mean(abs(microstateTemplates(ti,lblIndx)-neighborhoodValues));
      end
    end
  end
end

% Number of local maxima per sensor - where center sensor in a neighborhood has the maximum value
function meanLocalMaxima = ComputeMeanLocalMaxima(microstateTemplates, sensorLabels, sensorNeighbors)
  meanLocalMaxima = zeros(size(microstateTemplates,1),1);
  for ti=1:size(microstateTemplates,1)
    maximaCount = 0;
    for si=1:length(sensorNeighbors)
      [lblIndx, ~] = match_str(sensorLabels, sensorNeighbors(si).label);
      if ~isempty(lblIndx)
        [~, nghbrhdIndcs] = match_str(sensorNeighbors(si).neighblabel, sensorLabels);
        maxNeighborhoodValue = max(microstateTemplates(ti, nghbrhdIndcs));
        sensorValue = microstateTemplates(ti,lblIndx);
        if(sensorValue>maxNeighborhoodValue)
          maximaCount = maximaCount + 1;
        end
      end
    end
    meanLocalMaxima(ti) = maximaCount/length(sensorLabels);
  end
end

% Return cluster variance for each microstate template and assigned data
function clusterVariance = ComputeClusterVariance(data)
  % concatenate trials in data, allowing 
  data = ConcatenateTrials(data);
  indices = unique(data.microstateIndices{1});
  clusterVariance = zeros(size(indices));
  for i=1:length(indices)
    microstateIndex = indices(i);
    clusterVariance(microstateIndex) = var(data.trial{1}(data.microstateIndices{1}==microstateIndex));
  end
end

% Return cluster compactness for each microstate template and assigned data
function clusterStandardDeviation = ComputeClusterStandardDeviation(data)
  % concatenate trials in data, allowing 
  data = ConcatenateTrials(data);
  indices = unique(data.microstateIndices{1});
  clusterStandardDeviation = zeros(size(indices));
  for i=1:length(indices)
    microstateIndex = indices(i);
    clusterStandardDeviation(microstateIndex) = std(data.trial{1}(data.microstateIndices{1}==microstateIndex))/sum(data.microstateIndices{1}==microstateIndex);
  end
end

