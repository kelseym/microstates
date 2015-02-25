%% Extract microstate templates
%  Given one or more data structure and the number of desired template maps,
%  use data at GFP peaks to find cluster centers from concatenated data

%  
%  Input:
%  cfg.numtemplates = intValue, integer value denoting the number of clusters to find
%  cfg.datastructs = data or {data1, data2, ...} where data are fieldtrip style data structures
%  cfg.clustertrainingstyle = 'global' (default) or 'local' or 'trial'
          % Which data should be used to form clusters: 
          % global - concatenate all data to determin cluster centers
          % local - concatenate all trials in each data structure (data file) to find unique cluster centers for each
          % trial - find unique cluster centers for each trial individually
%  cfg.clustermethod = 'heiarchal', 'aahc'

          
function globalTemplates = ExtractMicrostateTemplates(cfg)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'numtemplates'});
  cfg = ft_checkconfig(cfg, 'required', {'datastructs'});
  
  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'numtemplates', 'double');
  cfg = ft_checkopt(cfg, 'clustertrainingstyle', 'char', {'global', 'local', 'trial'});

  % get the options
  numTemplates = ft_getopt(cfg, 'numtemplates');
  dataStructs = ft_getopt(cfg, 'datastructs');
  clusterTrainingStyle = ft_getopt(cfg, 'clustertrainingstyle', 'global');

  % if dataStruct input is a single fieldtrip data structure, pack it in a cell element to unify some of the processing below
  if isstruct(dataStructs)
    dataStructs = {dataStructs};
  end
  
  fsample = dataStructs{1}.fsample;
  
  % concatenate trials if finding clusters using global or local option
  if strcmp(clusterTrainingStyle, 'global') || strcmp(clusterTrainingStyle, 'local')
    for j=1:length(dataStructs)
      dataStructs{j} = ConcatenateTrials(dataStructs{j});
    end
  end
    
  % Concatenate input data structures if using global option
  if strcmp(clusterTrainingStyle, 'global')
    dataMatrix = [];
    labelIntersection = GetSensorLabelIntersection(dataStructs);
    for j=1:length(dataStructs)
      [lblIndcs,~] = match_str(dataStructs{j}.label, labelIntersection);
      for i=1:length(dataStructs{j}.trial);
        dataMatrix = cat(2, dataMatrix, dataStructs{j}.trial{i}(lblIndcs,:));
      end
    end
    dataStructs = [];
    dataStructs{1}.trial{1} = dataMatrix;
  end
  globalTemplates = {};
  for strctIndx=1:length(dataStructs)
    localTemplates = {};
    for trlIndx=1:length(dataStructs{strctIndx}.trial)
      dataMatrix = dataStructs{strctIndx}.trial{trlIndx};
      % find gfp peaks
      [~, gfpPkLocs] = LocateGfpPeaks(dataMatrix);
      % sample sensor data at gfp peaks
      trainingMaps = dataMatrix(:,gfpPkLocs)';
      % cluster analysis
      sampleMapMembership = HierarchicalCluster(trainingMaps, numTemplates);
      % find cluster centroids
      trialTemplates = zeros(numTemplates, size(trainingMaps,2));
      for i=1:numTemplates
          meanMap = mean(trainingMaps(sampleMapMembership == i, :), 1);
          trialTemplates(i, :) = meanMap(:);
      end
      localTemplates{trlIndx} = trialTemplates;
    end
    globalTemplates{strctIndx} = localTemplates;
  end
  
end

