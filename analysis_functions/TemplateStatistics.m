%% Microstate template cluster measure

%   Measure cluster statistics such as spatial contrast or roughness (local maxima)

%   Input:
%   microstateTemplates = NxS matrix where each row defines microstates template over S sensors
%   cfg.clusterstatistic = 'spatialcontrast', 'roughness' - used with cfg.compareto='self'
%   cfg.similaritymetric = 'euclidean' (default), 'correlation' - used with cfg.compareto='eachother'|'zero'|'sample'
%   cfg.ignorepolarity = 'yes' (default), 'no'- used with cfg.compareto!='self'

function statisticMatrix = TemplateStatistics(microstateTemplates, cfg)

  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'clusterstatistic', 'char', {'spatialcontrast','roughness'});


  % get the options
  clusterStatistic = ft_getopt(cfg, 'clusterstatistic','spatialcontrast');
  sensorNeighbors = ft_getopt(cfg, 'sensorneighbors');
  sensorLabels = ft_getopt(cfg, 'sensorlabels');
  sampleTemplate = ft_getopt(cfg, 'sampletemplate', []);
  ignorePolarity = ft_getopt(cfg, 'ignorepolarity', 'no');

  %% Gather statistics for each cluster independently
  if strcmp(clusterStatistic, 'spatialcontrast')
    if ~isempty(sensorNeighbors)
      sensorContrast = ComputeSpatialContrast(microstateTemplates, sensorLabels, sensorNeighbors);
      statisticMatrix = mean(sensorContrast,2);
    else
      error('Missing sensorneighbors structure');
    end
  elseif strcmp(clusterStatistic, 'roughness')
      sensorRoughness = ComputeMeanLocalMaxima(microstateTemplates, sensorLabels, sensorNeighbors);
      statisticMatrix = sensorRoughness;
  else
    error('Unknown clusterstatistic option.');
  end
      
  
end

% Return average spatial contrast for each sensor in a set of microstate template
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


