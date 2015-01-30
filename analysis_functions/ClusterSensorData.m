%% ClusterSensorData
%  Cluster data using the specified method

%  
%  Input:
%  cfg.maxcluster = intValue, integer value denoting the number of clusters to find
%  cfg.sensordata = SxM double matrix, where S=number_of_sensors and M=number_of_data_points
%          NOTE: sensordata should only include timepoints of interest for clustering, e.g. data at gfp peaks
%  cfg.clustermethod = 'kmeans', 'hierarchical', 'aahc', 'taahc'
%  cfg.gfppeakvalues = 1xM array containing gfp values at points corresponding to samples in sensordata. Required for aahc method

%  Return:
%  cfg.clusterassignment = 1XM matrix populated with integers identifying the cluster membership of each data point

function cfg = ClusterSensorData(cfg)

  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'maxcluster'});
  cfg = ft_checkconfig(cfg, 'required', {'sensordata'});
  cfg = ft_checkconfig(cfg, 'required', {'clustermethod'});
  
  % ensure that the options are valid
  cfg = ft_checkopt(cfg, 'maxcluster', 'double');
  cfg = ft_checkopt(cfg, 'sensordata', 'double');
  cfg = ft_checkopt(cfg, 'clustermethod', 'char', {'kmeans', 'hierarchical', 'aahc', 'taahc'});

  % get the options
  maxCluster = ft_getopt(cfg, 'maxcluster');
  sensorData = ft_getopt(cfg, 'sensordata');
  clusterMethod = ft_getopt(cfg, 'clustermethod');
  
  % dependent options
  if strcmp(clusterMethod, 'aahc')
    cfg = ft_checkconfig(cfg, 'required', {'gfppeakvalues'});
    cfg = ft_checkopt(cfg, 'gfppeakvalues', 'double');
    gpfPeakValues = ft_getopt(cfg, 'gfppeakvalues');
  end
  
  %% AAHC computation
  %  1. Measure GEV of each cluster - initially each point is a cluster
  %  2. Atomize cluster with minimum GEV
  %  2a. Each point in atomized cluster is reassigned to a remaining cluster to which it is most highly correlated
  %  3. Stop if target number of clusters has been reached, otherwise, goto 1.
  
  
  
  
  
  
  
  
  
  
end

