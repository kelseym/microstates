%% Given a set of microstate templates, cluster templates to find close relatives and outliers

clear;

numMicrostates = 5;
threshold = .75;

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
cfg.length=30;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);


cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

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



