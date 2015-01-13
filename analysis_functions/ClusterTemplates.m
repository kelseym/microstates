
function clusterId = ClusterTemplates(microstateTemplates, combinationThreshold, minUniqueClusters)
  X = microstateTemplates;
  %% cluster analysis
  %  generate a distance array in the form of pdist() output
  distTree = zeros(1,(size(X,1)*(size(X,1)-1))/2);
  coeffs = corrcoef(X');
  k = 1;
  for i=1:size(X,1)
    for j=1:size(X,1)
      if j<=i
        continue;
      end
      distTree(k) = coeffs(i,j);
      k=k+1;
    end
  end
  sqDistTree = squareform(distTree);
  clustTree = linkage(1-distTree, 'single');
  clusterIDs = cluster(clustTree,'maxclust',1:size(X,1));

  % find cluster assignment (column in clusterIDs) that results in all cluster members correlated >= threshold
  for numClusters=minUniqueClusters:size(clusterIDs,2)
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
    if minCoef >= combinationThreshold
      clusterId = ids;
      break;
    end
  end
end
