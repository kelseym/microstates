%% ClusterSensorData
%  Cluster data using the specified method

%  
%  Input:
%  cfg.maxcluster = intValue, integer value denoting the number of clusters to find
%  cfg.sensordata = SxM double matrix, where S=number_of_sensors and M=number_of_data_points
%  cfg.clustermethod = 'kmeans', 'hierarchical', 'aahc', 'taahc'

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
  
  
  %% T-AAHC computation
  %  
  %  1. Group unmatched data points 
  
  
  
  
  
  
  
  
  
  
end

