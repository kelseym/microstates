%% Given a set of microstate templates, cluster templates to find close relatives and outliers

clear;
plotTopo = 1;

% Use custom subplot to reduce plot border thickness
%                                  gap:[height width] fig border:[bottom top]
%subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

numMicrostates = 3;
numMicrostateBins = 3;
trialLengths = [5 10:10:240];
%trialLengths = [130];
combinationThreshold = 1/numMicrostates;

baseDir = GetLocalDataDirectory();
fileNames = dir([baseDir '105923*.mat']);

% Open layout file
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);



dataStructs = {};
for fi=1:length(fileNames)

  load([baseDir fileNames(fi).name]);
  cfg = [];
  cfg.continuous = 'yes';
  cfg.demean = 'yes';
  cfg.detrend = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq = [1.0 40.0];
  data = ft_preprocessing(cfg, data);
  data = ConcatenateTrials(data);
  data.filename = fileNames(fi).name;
  dataStructs{fi} = data;
  clear data;
end

% Keep only sensor data that is available in every scan
labelIntersection = GetSensorLabelIntersection(dataStructs);
for dsi=1:length(dataStructs)
  [~, lblIndcs] = match_str(labelIntersection, dataStructs{dsi}.label);
  dataStructs{dsi}.label = labelIntersection;
  dataStructs{dsi}.trial{:} = dataStructs{dsi}.trial{:}(lblIndcs,:);
end

%% compute microstates
% compute global microstates
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = dataStructs{1};
cfg.clustertrainingstyle = 'local';
globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
if plotTopo
  figure('name','Global Microstates');
  for i=1:numMicrostates
    subplot(1,numMicrostates,i);
    PlotMicrostateTemplate(globalMicrostateTemplates{1}{1}(i,:),labelIntersection, lay);
  end
end

%% Compute trial-wise microstates
for exprmnti=1:length(trialLengths)
  trlLngth = trialLengths(exprmnti)
  cfg = [];
  cfg.length=trlLngth;
  cfg.overlap=0.0;
  
  trialDataStructs = {};
  for dti=1:length(dataStructs)
    trialDataStructs{dti} = ft_redefinetrial(cfg, dataStructs{dti});
  end
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = trialDataStructs;
  cfg.clustertrainingstyle = 'trial';
  microstateTemplates = ExtractMicrostateTemplates(cfg);


  % Combine all microstateTemplates for the purpose of template clustering
  X = [];
  for i=1:length(microstateTemplates) 
    for j=1:length(microstateTemplates{i})
      trialDataMatrix = microstateTemplates{i}{j};
      X = cat(1, X, trialDataMatrix);
    end
  end

  clusterId = ClusterTemplates(X, combinationThreshold, numMicrostateBins);

  clusterCount=[];
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
        tmpltIndx = find(clusterIdSq(ri,:)==clusterIdToPlot, 1, 'first');
        if ~isempty(tmpltIndx)
          subplot(rows,cols,eli);
          tmpltIndx2 = ((ri-1)*numMicrostates)+tmpltIndx;
          PlotMicrostateTemplate(X(tmpltIndx2,:),labelIntersection,lay);
        end
      end
    end
  end
  
  %% Force topographies into numMicrostates groups
  numTrials = size(clusterIdSq,1);
  % convert X to a 3d matrix to ease template addressing
  Xsq = reshape(X,numMicrostates,numTrials,[]);
  Xsq = permute(Xsq,[2 1 3]);  % Xsq(i,j,k) i=trial index, j=template index, k=sensor index
  
  %Reshape Xsq to reflect sorted and grouped microstates guided by clusterIdSq and clusterSortingI 
  %   sortedXsq should match the representation in the above figure
  sortedXsq = -Inf*ones(size(Xsq,1),length(clusterSortingI),size(Xsq,3));
  for toCol=1:length(clusterSortingI)
    clstrId=clusterSortingI(toCol);
    for ri=1:size(Xsq,1)
      fromCol = find(clusterIdSq(ri,:)==clstrId, 1, 'first');
      if ~isempty(fromCol)
        sortedXsq(ri,toCol,:) = Xsq(ri,fromCol,:);
      end
    end
  end
  
  % for each microstate bin, fill in empty template maps with those from the leftover bin.
  % start with the largest groups in the leftovers (first column in leftoverBinXSq
  binnedXsq = sortedXsq(:,1:numMicrostateBins,:);
  if size(sortedXsq,2) > numMicrostateBins
    binnedXsq = sortedXsq(:,1:numMicrostateBins,:);
    leftoverBinXsq = sortedXsq(:,numMicrostateBins+1:size(sortedXsq,2),:);
    for toCol=1:size(binnedXsq,2)
      colAvgTemplate = squeeze(mean(binnedXsq(find(binnedXsq(:,toCol,1)~=-Inf),toCol,:),1))';
      for toRow=1:size(binnedXsq,1)
        if binnedXsq(toRow,toCol,1) == -Inf %empty bin found, fill with template from the leftover bin with max corrcoef
          coef=[];
          for lftvri=1:size(leftoverBinXsq,2)
            coefSq = corrcoef(squeeze(colAvgTemplate), squeeze(leftoverBinXsq(toRow,lftvri,:)));
            coef(end+1) = coefSq(1,2);
          end
          [~, maxCorrI] = max(coef); % maxCorrI holds the column index into leftoverBinXsq containing the best fit template to the missing space in binnedXsq
          binnedXsq(toRow,toCol,:) = leftoverBinXsq(toRow,maxCorrI,:);
          leftoverBinXsq(toRow,maxCorrI,:) = -Inf;
        end
      end
    end
  end
  
  % Plot binned topographies
  if plotTopo
    figure('name',sprintf('Trial Length: %i sec',trlLngth));
    rows = size(binnedXsq,1);
    cols = size(binnedXsq,2);
    for ri=1:rows
      for ci=1:cols
        subplot(rows,cols,(ri-1)*cols+ci);
        PlotMicrostateTemplate(squeeze(binnedXsq(ri,ci,:))',labelIntersection,lay);
      end
    end
  end

  %% Measure stability within members of each bin (column in binnedXsq)
  for ci=1:size(binnedXsq,2)
    validRows = find(binnedXsq(:,ci,1) ~= -Inf);
    % compute pairwise cluster distance
    dist = pdist(squeeze(binnedXsq(validRows,ci,:)),'correlation');
    corr = (dist-1)*-1;
    binStability(exprmnti,ci) = sum(corr)/length(corr);
  end 
    
end

%% Plot bin stability across trial length experiments
figure('name','Binned Templates Stability');
hold on;
lgnd={};
colors = lines;
for tmplti=1:size(binnedXsq,2)
  plot(squeeze(binStability(:,tmplti)),'.', 'MarkerSize', 30, 'Color', colors(tmplti,:));
  lgnd{end+1} = sprintf('Bin: %i',tmplti);
end
ylabel('Template Bin Stability');
xlabel('Trial Length (sec)');
set(gca,'XTick',1:length(trialLengths));
set(gca,'XTickLabel',trialLengths);
legend(lgnd);
hold off;




