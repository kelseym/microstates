function trainingDataLabel = HierarchicalCluster(trainingData, targetNumClusters)
  distMetric = 'correlation';

  distTree = pdist(trainingData, distMetric);
  clustTree = linkage(distTree, 'average');
  % choose N clusters, assign sample points to 1 of N microstates
  trainingDataLabel = cluster(clustTree,'maxclust',targetNumClusters);
end
