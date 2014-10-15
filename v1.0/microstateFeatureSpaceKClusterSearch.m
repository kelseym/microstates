function microstateFeatureSpaceKClusterSearch(featureMaps, featureClustTreeEuc, maxClusters)

maxClusters = 32;

% Setup GEV plot
figure, hold on;
title('Cluster Quantity Selection');
ylabel('Cluster Correlation');
xlabel('Number of Clusters');
grid on;
xlim([1 maxClusters]);

% Sort feature maps into N clusters
for numClusters=1:maxClusters
    featureMembership = cluster(featureClustTreeEuc,'maxclust',numClusters);
    clusterCorr = zeros(numClusters, size(featureMaps,1));
    for i=1:numClusters
        meanMap = mean(featureMaps(featureMembership == i, :), 1);
        clusterCorr(i,:) = corr(meanMap', featureMaps');
    end
    maxCorr = max(clusterCorr,[],1);
    
% 
%     % Compute GEV
%     numer = sumsqr(gfp.*maxCorr);
%     denom = sumsqr(gfp);
%     gev = numer/denom;
%     globalExVar(numClusters) = gev;

    globalExVar(numClusters) = sumsqr(maxCorr)/numel(maxCorr);

%     % plot GEV
%     if ~isempty(h1)
%         set(h1,'Visible','off');
%     end
% 
%     h1 = plot(globalExVar(1:numClusters),'k.-','LineWidth',1);

end

plot(globalExVar,'k.-','LineWidth',1);





