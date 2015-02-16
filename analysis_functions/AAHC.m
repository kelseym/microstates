% AAHC - Maximize GEV while selecting cluster members

% Uncomment for function testing
% load fisheriris;
% trainingData = meas;
% targetNumClusters = 4;

function trainingDataLabel = AAHC(trainingData, targetNumClusters)

% trainingData = OxM matrix. O = number of observations, M = number of sensors.

distMetric = 'correlation';

% Compute GFP of peaks
numChan = size(trainingData,2);
gfpPeaks = sqrt(sum(trainingData.^2,2)/numChan);

% each point starts as a cluster center
clusterCenters = trainingData(:,:);
trainingDataLabel = 1:size(clusterCenters,1);


gevDenom = gfpPeaks'*gfpPeaks;
while size(clusterCenters,1) > targetNumClusters
  % Assign each observation in training data a label based on maximal correlation to cluster centers.
  corrClustersToTrainingData = abs(corr(clusterCenters(:,:)',trainingData(:,:)'));
  [~, maxCorrClstrIdx] = max(corrClustersToTrainingData,[],1);

  % Measure GEV of each cluster center.
  gevk = zeros(size(clusterCenters,1),1);
  for cli=1:size(clusterCenters,1)
      clusterMatchMask = maxCorrClstrIdx == cli;
      prod = gfpPeaks(clusterMatchMask).*corrClustersToTrainingData(cli,clusterMatchMask)';
      gevNumer = prod'*prod;      
      gevk(cli) = gevNumer/gevDenom;
  end

  % disolve (atomize) cluster witn minimum GEV by setting membership to -Inf
  [~, clstrIdDisolve] = min(gevk);
  trainingDataLabel(trainingDataLabel==clstrIdDisolve) = -Inf;
  clusterCenters(clstrIdDisolve,:) = -Inf;

  % reassign disolved cluster members each to the closest cluster center
  % rows indices of dist correspoind to trainingDataLabel indices, cols correspond to clusterCenters
  dist = pdist2(trainingData(trainingDataLabel==-Inf,:), clusterCenters, distMetric);
  [~, newClusterIds] = min(dist, [], 2);
  trainingDataLabel(trainingDataLabel==-Inf) = newClusterIds;

  % recompute cluster centers for changed clusters
  for cli=newClusterIds'
    clusterCenters(cli,:) = mean(trainingData(trainingDataLabel==cli, :), 1);
  end

  % reassign trainingDataLabels 1:numClusters
  clusterCenters(clstrIdDisolve,:) = [];
  oldClusterIds = unique(trainingDataLabel);
  newTrainingDataLabel = -Inf*ones(size(trainingDataLabel));
  for cli=1:length(oldClusterIds)
    oldId = oldClusterIds(cli);
    newTrainingDataLabel(trainingDataLabel == oldId) = cli;
  end
  trainingDataLabel = newTrainingDataLabel;

end

