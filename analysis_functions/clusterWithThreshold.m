%% Cluster with threshold

% Each row in X contains an observation 
% Observations are clustered according to pairwise correlation >= given 'threhold' value
% clusterID is returned as an array of cluster labels 1-M, with m being the number of resultant clusters.
% Observations that do not meet the correlation threshold criteria are labeled with -1 in the clusterID array.

function clusterID = clusterWithThreshold(X, threshold, label, layout)
  
  % cluster analysis
  %  generate a distance array in the form of pdist() output
  distTree = [];
  for i=1:size(X,1)
    for j=1:size(X,1)
      if j<=i
        continue;
      end
      coeffs = corrcoef(X(i,:), X(j,:));
      distTree(end+1) = coeffs(1,2);
    end
  end

  sqDistTree = squareform(distTree);
  clustTree = linkage(1-distTree, 'average');
  % each row of clusterIDs contains cluster assignments (1-M) for each observation of X
  % Choose the cluster assignment column that results in all correlations >= threshold
  clusterIDs = cluster(clustTree,'maxclust',1:size(X,1));
  
  % find cluster assignment (column in clusterIDs) that results in all cluster members correlated >= threshold
  for numClusters=1:size(clusterIDs,2)
    ids = clusterIDs(:,numClusters);
    minCoef = Inf;
    for clusterNum=unique(ids)'
      sampleIndices = find(ids==clusterNum);
      for i=1:length(sampleIndices)
        for j=1:length(sampleIndices)
          if j<=i
            continue;
          end
          smpli = sampleIndices(i);
          smplj = sampleIndices(j);
          coeffs= corrcoef(X(smpli,:), X(smplj,:));
          minCoef = min(minCoef, coeffs(1,2));
        end
      end
    end
    numClusters, minCoef
    if minCoef >= threshold
      clusterID = ids;
      break;
    end
  end
      
    
  
  
  
end