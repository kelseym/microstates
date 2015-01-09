%% Given a set of microstate templates, cluster templates to find close relatives and outliers

clear;
plotTopo = 1;

% Use custom subplot to reduce plot border thickness
%                                  gap:[height width] fig border:[bottom top]
%subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

numMicrostates = 3;
trialLengths = [60];
combinationThreshold = 1/numMicrostates;
numMicrostateBins = 4;

fileName = GetLocalDataFile();
load(fileName);

cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);


%% Open layout file
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

%% compute microstates
data = ConcatenateTrials(data);
% compute global microstates
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);

% Compute trial-wise microstates
for trlLngth=trialLengths
  cfg = [];
  cfg.length=trlLngth;
  cfg.overlap=0.0;
  trialData = ft_redefinetrial(cfg, data);

  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = trialData;
  cfg.clustertrainingstyle = 'trial';
  microstateTemplates = ExtractMicrostateTemplates(cfg);


  % Combine all microstateTemplates for the purpose of template clustering
  X = [];
  for i=1:length(microstateTemplates{1})
    X = cat(1, X, microstateTemplates{1}{i});
  end

  clusterId = ClusterTemplates(X, combinationThreshold);

  for cid=1:length(unique(clusterId))
    clusterCount(cid) = length(find(clusterId==cid));
  end
  [~, clusterSortingI] = sort(clusterCount,2,'descend');
  clusterIdSq = reshape(clusterId,numMicrostates,[])';
  
  %% Plot templates aligned by clusterID
  if plotTopo
    rows = size(X,1)/numMicrostates;
    cols = length(unique(clusterId));
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
          tmpltIndx2 = ((ri-1)*numMicrostates)+tmpltIndx;
          PlotMicrostateTemplate(X(tmpltIndx2,:),trialData.label,lay);
        end
      end
    end
  end
  
  %% Force topographies into numMicrostates groups
  numTrials = size(clusterIdSq,1);
  % convert X to a 3d matrix to ease template addressing
  Xsq = reshape(X,numMicrostates,numTrials,[]);
  Xsq = permute(Xsq,[2 1 3]);  % Xsq(i,j,k) i=trial index, j=template index, k=sensor index
  
  rows = size(X,1)/numMicrostates;
  cols = numMicrostateBins;
  
  for ri=1:rows
    for ci=1:cols
      
    end
  end
    
    
    
    
    
    
 
  
  
  
  
  
end






