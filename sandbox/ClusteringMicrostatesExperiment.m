%% Given a set of microstate templates, cluster templates to find close relatives and outliers

clear;

numMicrostates = 4;
threshold = .60;

fileName = GetLocalDataFile();
load(fileName);

cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);

data = ConcatenateTrials(data);
cfg = [];
cfg.length=10;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);


cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

%% compute and plot global microstates
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
PlotMicrostateTemplateSet(globalMicrostateTemplates{1}{1}, data.label, lay, 'Global Microstates');

%% Compute and plot trial-wise microstates
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'trial';
microstateTemplates = ExtractMicrostateTemplates(cfg);

% Combine all microstateTemplates for the purpose of template clustering
X = [];
for i=1:length(microstateTemplates{1})
  X = cat(1, X, microstateTemplates{1}{i});
end


% Plot topographies
figure;
cols = numMicrostates;
rows = size(X,1)/numMicrostates;
for i=1:size(X,1)
  subplot(rows,cols,i);
  PlotMicrostateTemplate(X(i,:),data.label,lay);
end

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
clustTree = linkage(1-distTree, 'average');
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
  if minCoef >= threshold
    clusterId = ids;
    break;
  end
end

%% Plot templates aligned by clusterID
rows = size(X,1)/numMicrostates;
cols = length(unique(clusterId));
for cid=1:length(unique(clusterId))
  clusterCount(cid) = length(find(clusterId==cid));
end
[~, clusterSortingI] = sort(clusterCount,2,'descend');
clusterIdSq = reshape(clusterId,numMicrostates,[])';
% plot clusters with the most members first (left)
figure('name',sprintf('%i repeating out of %i distinct microstates', length(find(clusterCount>1)),length(unique(clusterId))));
for ri=1:rows
  for ci=1:cols
    eli = ((ri-1)*cols)+ci;
    clusterIdToPlot = clusterSortingI(ci);
    % if row ri contans clusterIdToPlot, plot it here
    tmpltIndx = find(clusterIdSq(ri,:)==clusterIdToPlot);
    if ~isempty(tmpltIndx)
      subplot(rows,cols,eli);
      tmpltIndx = ((ri-1)*numMicrostates)+tmpltIndx;
      PlotMicrostateTemplate(X(tmpltIndx,:),data.label,lay);
    end
    
    
  end
end
    
 



