% Pipeline should be contructed to run in a non-interactive environment
% Options should be passed using the following workspace variables:

% subjectid = string indicating subject id. Used to label output files
% filename = string containing full path to data file. Can also be a list of filenames (several for same subject)
% numMicrostates = integer specifying the number of microstate clusters to find
% outputDir = string containing full path to the output directory

if ~exist('subjectid', 'var') 
  error('Missing input parameter: subjectid')
elseif ~exist('filename', 'var') 
  error('Missing input parameter: filename')
elseif ~exist('numMicrostates', 'var')
  error('Missing input parameter: numMicrostates')
elseif ~exist('outputDir', 'var')
  error('Missing input parameter: outputDir')
end

% Print variables to output
subjectid
filename
numMicrostates
outputDir

% plotTopo = 0;

% setup frequency partitions
% downsample data to 2x max frequency
frequencyBands = GetFrequencyBands();
bands =       frequencyBands.bands;
bandLabels =  frequencyBands.bandLabels;
maxFreq = max(max(bands))*2;

% setup time partitions
numMicrostateBins = numMicrostates;
trialLengths = [5 10:10:240];

% Open layout file
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

% template corrilation combination threshold
combinationThreshold = 1/numMicrostates;

% if filename specifies a single file, force it into cell-array format
if ischar(filename)
  filename = {filename};
end

% open and preprocess specified data files
rawDataStructs = cell(length(filename),1);
for fi=1:length(filename)
  load(filename{fi});
  cfg = [];
  cfg.continuous = 'yes';
  cfg.demean = 'yes';
  cfg.detrend = 'yes';
  data = ft_preprocessing(cfg, data);
  data = ConcatenateTrials(data);
  data.filename = filename{fi};
  rawDataStructs{fi} = data;
  clear data;
end

% Keep only sensor data that is available in every scan
labelIntersection = GetSensorLabelIntersection(rawDataStructs);
for dsi=1:length(rawDataStructs)
  [~, lblIndcs] = match_str(labelIntersection, rawDataStructs{dsi}.label);
  rawDataStructs{dsi}.label = labelIntersection;
  rawDataStructs{dsi}.trial{:} = rawDataStructs{dsi}.trial{:}(lblIndcs,:);
end

%% For each frequency band and trial length measure topography stability
for bndi=1:size(bands,1)
  freqBand = bands(bndi,:);
  
  % bandpass data
  for dsi=1:length(rawDataStructs)
    cfg=[];
    cfg.continuous = 'yes';
    cfg.bpfilter = 'yes';
    cfg.bpfreq = freqBand;
    dataStructs{dsi} = ft_preprocessing(cfg, rawDataStructs{dsi});
  end

  % compute global(inter-scan) microstates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataStructs{1};
  cfg.clustertrainingstyle = 'local';
  globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);

  fh = figure('name','Global Microstates');
  for i=1:numMicrostates
    subplot(1,numMicrostates,i);
    PlotMicrostateTemplate(globalMicrostateTemplates{1}{1}(i,:),labelIntersection, lay);
  end
  
  % save global microstates and plots
  save([outputDir filesep sprintf('%i_%i',subjectid, numMicrostates) 'MS' '_globalMicrostateTemplates_' frequencyBands.bandLabels{bndi} '.mat'], 'globalMicrostateTemplates', 'labelIntersection', 'lay');

  saveas(fh, [outputDir filesep sprintf('%i_%i', subjectid, numMicrostates) 'MS' '_GlobalMicrostates_' frequencyBands.bandLabels{bndi}],'fig');
  saveas(fh, [outputDir filesep sprintf('%i_%i', subjectid, numMicrostates) 'MS' '_GlobalMicrostates_' frequencyBands.bandLabels{bndi}],'png');
  close all;


  % Compute trial-wise microstates
  for trlLngthi=1:length(trialLengths)
    trlLngth = trialLengths(trlLngthi)
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
  %   if plotTopo
  %     rows = size(X,1)/numMicrostates;
  %     cols = length(unique(clusterId));
  %     % plot clusters with the most members first (left)
  %     figure('name',sprintf('%i repeating out of %i distinct microstates', length(find(clusterCount>1)),length(unique(clusterId))));
  %     for ri=1:rows
  %       for ci=1:cols
  %         eli = ((ri-1)*cols)+ci;
  %         clusterIdToPlot = clusterSortingI(ci);
  %         % if row ri contans clusterIdToPlot, plot it here
  %         tmpltIndx = find(clusterIdSq(ri,:)==clusterIdToPlot, 1, 'first');
  %         if ~isempty(tmpltIndx)
  %           subplot(rows,cols,eli);
  %           tmpltIndx2 = ((ri-1)*numMicrostates)+tmpltIndx;
  %           PlotMicrostateTemplate(X(tmpltIndx2,:),labelIntersection,lay);
  %         end
  %       end
  %     end
  %   end

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
  %   if plotTopo
  %     figure('name',sprintf('Trial Length: %i sec',trlLngth));
  %     rows = size(binnedXsq,1);
  %     cols = size(binnedXsq,2);
  %     for ri=1:rows
  %       for ci=1:cols
  %         subplot(rows,cols,(ri-1)*cols+ci);
  %         PlotMicrostateTemplate(squeeze(binnedXsq(ri,ci,:))',labelIntersection,lay);
  %       end
  %     end
  %   end

    %% Measure stability within members of each bin (column in binnedXsq)
    for ci=1:size(binnedXsq,2)
      validRows = find(binnedXsq(:,ci,1) ~= -Inf);
      % compute pairwise cluster distance
      dist = pdist(squeeze(binnedXsq(validRows,ci,:)),'correlation');
      corr = (dist-1)*-1;
      binStability(bndi,trlLngthi,ci) = sum(corr)/length(corr);
    end 
  end
end

% save binStability with freqBands and trial lengths
save([outputDir filesep sprintf('%i_%i', subjectid, numMicrostates) 'MS' '_binStability.mat'], 'binStability', 'frequencyBands', 'trialLengths');

%% Plot bin stability across trial length experiments
for bndi=1:size(binStability,1)
  fh = figure('name','Binned Templates Stability');
  hold on;
  lgnd={};
  colors = lines;
  for tmplti=1:size(binStability,3)
    plot(squeeze(binStability(bndi,:,tmplti)),'.', 'MarkerSize', 30, 'Color', colors(tmplti,:));
    lgnd{end+1} = sprintf('Bin: %i',tmplti);
  end
  title(sprintf('%s Band Limited',frequencyBands.bandLabels{bndi}));
  ylabel('Template Bin Stability');
  ylim([-1 1]);
  xlabel('Trial Length (sec)');
  set(gca,'XTick',1:length(trialLengths));
  set(gca,'XTickLabel',trialLengths);
  legend(lgnd, 'Location', 'SouthWest');
  hold off;
  
  saveas(fh, [outputDir filesep sprintf('%i_%i', subjectid, numMicrostates) 'MS' '_BinnedTemplatesStability_' frequencyBands.bandLabels{bndi}],'fig');
  saveas(fh, [outputDir filesep sprintf('%i_%i', subjectid, numMicrostates) 'MS' '_BinnedTemplatesStability_' frequencyBands.bandLabels{bndi}],'png');
  close(fh);
end

close all;



