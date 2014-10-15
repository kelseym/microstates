%% Extract microstate templates
%  Given one or more data structure and the number of desired template maps,
%  use data at GFP peaks to find cluster centers from concatonated data
%
%  cfg.numtemplates = value, explain the value here (default = something)
%  cfg.datastructs = data or {data1, data2, ...}


function microstateTemplates = ExtractMicrostateTemplates(cfg)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'numtemplates'});
  cfg = ft_checkconfig(cfg, 'required', {'datastructs'});

  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'numtemplates', 'double');

  % get the options
  numTemplates = ft_getopt(cfg, 'numtemplates');
  dataStructs = ft_getopt(cfg, 'datastructs');

  % determine if dataStructs is a single data structure or a cell array of data structures
  % concatonate all timecourse data
  dataMatrix = [];
  if isstruct(dataStructs)
    for i=1:length(dataStructs.trial);
      dataMatrix = cat(2, dataMatrix, dataStructs.trial{i});
    end
  elseif iscell(dataStructs) && length(dataStructs)>=1 && isstruct(dataStructs{1})
    for j=length(dataStructs)
      for i=1:length(dataStructs{j}.trial);
        dataMatrix = cat(2, dataMatrix, dataStructs{j}.trial{i});
      end
    end
  end
  
  % find gfp peaks
  [~, gfpPkLocs] = LocateGfpPeaks(dataMatrix);
  % sample sensor data at gfp peaks
  trainingMaps = dataMatrix(:,gfpPkLocs)';
  % cluster analysis
  distTree = pdist(trainingMaps, 'correlation');
  clustTree = linkage(distTree, 'average');
  % choose N clusters, assign sample points to 1 of N microstates
  sampleMapMembership = cluster(clustTree,'maxclust',numTemplates);
  % find cluster centroids
  microstateTemplates = zeros(numTemplates, size(trainingMaps,2));
  for i=1:numTemplates
      meanMap = mean(trainingMaps(sampleMapMembership == i, :), 1);
      microstateTemplates(i, :) = meanMap(:);
  end
  
  
end  