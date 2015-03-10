%% compute amplitude correlation between band limited data and envelopes

clear;
% load data
fileName = GetLocalDataFile();

% bands =       [1,50;       1,120;    4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
% bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};

bands =       [1,4;    4,8;    4,10;        8,15;   15,26;     26,35;     35,50;     50,76;      76,120;     1,4;       4,8;       4,10;           8,15;      15,26;        26,35;        35,50;        50,76;         76,120];
bandLabels = {'Delta','Theta','ThetaAlpha','Alpha','BetaL', 'BetaH','GammaL','GammaM', 'GammaH','EnvDelta','EnvTheta','EnvThetaAlpha','EnvAlpha','EnvBetaL', 'EnvBetaH','EnvGammaL','EnvGammaM', 'EnvGammaH',};


load(fileName);
data = ConcatenateTrials(data);

dataBL = cell(size(bands,1),1);
for bndi=1:size(bands,1)
  band = bands(bndi,:);

  cfg = [];
  %cfg.resamplefs = maxFreq*2;
  cfg.detrend    = 'yes';
  cfg.demean     = 'yes';
  cfg.feedback   = 'no';
  cfg.trials     = 'all';
  cfg.continuous = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
  if strfind(bandLabels{bndi},'Env')
    cfg.hilbert = 'abs';
  end
  dataBL{bndi} = ft_preprocessing(cfg, data);
  
  if strfind(bandLabels{bndi},'Env')
    cfg = [];
    cfg.detrend    = 'yes';
    cfg.demean     = 'yes';
    cfg.feedback   = 'no';
    cfg.trials     = 'all';
    cfg.continuous = 'yes';
    dataBL{bndi} = ft_preprocessing(cfg, dataBL{bndi});
  end
end


%% compute pairwise correlations
numTrials = size(data.trial,2);
avgCorr = zeros(size(bands,1),size(bands,1),numTrials);
minCorr = zeros(size(bands,1),size(bands,1),numTrials);
maxCorr = zeros(size(bands,1),size(bands,1),numTrials);
for bndi=1:size(bands,1)
  for bndj=1:size(bands,1)
    for trli=1:numTrials
      dataMatrix1 = dataBL{bndi}.trial{trli};
      data1Label = bandLabels{bndi};
      dataMatrix2 = dataBL{bndj}.trial{trli};
      data2Label = bandLabels{bndj};
      channelLevelCorr(bndi,bndj,trli,:) = diag(corr(zscore(dataMatrix1'), zscore(dataMatrix2')));
      avgCorr(bndi,bndj,trli) = mean(abs(channelLevelCorr(bndi,bndj,trli,:)));
      minCorr(bndi,bndj,trli) = min(channelLevelCorr(bndi,bndj,trli,:));
      maxCorr(bndi,bndj,trli) = max(channelLevelCorr(bndi,bndj,trli,:));
    end
   end
end

%% Plot overall band limited amplitude correlations
for trli=1:numTrials
  figure;
  imagesc(avgCorr(:,:,trli));
  set(gca,'XTick', 1:size(bands,1));
  set(gca,'YTick', 1:size(bands,1));
  set(gca,'XTickLabel', bandLabels);
  set(gca,'YTickLabel', bandLabels);
  colorbar;
  title(sprintf('Trial %i Average Correlation',trli));
end


%% Plot regional amplitude correlations
load('4D248_labelROI.mat');
for rgni=1:9
  figure;
  channelLabelMask = labels(labelROI==rgni);
  [channelIndexMask, ~] = match_str(data.label, channelLabelMask);
  for trli=1:numTrials
    regionalChannelLevelCorr = squeeze(channelLevelCorr(:,:,trli,channelIndexMask));
    avgCorr = mean(abs(regionalChannelLevelCorr),3);
    imagesc(avgCorr(:,:));
    set(gca,'XTick', 1:size(bands,1));
    set(gca,'YTick', 1:size(bands,1));
    set(gca,'XTickLabel', bandLabels);
    set(gca,'YTickLabel', bandLabels);
    colorbar;
    title(sprintf('Region %i - Trial %i Average Correlation',rgni,trli));

  end
end

  
% figure;
% imagesc(minCorr);
% set(gca,'XTick', 1:size(bands,1));
% set(gca,'YTick', 1:size(bands,1));
% set(gca,'XTickLabel', bandLabels);
% set(gca,'YTickLabel', bandLabels);
% colorbar;
% title('Min Correlation');
% 
% figure;
% imagesc(maxCorr);
% set(gca,'XTick', 1:size(bands,1));
% set(gca,'YTick', 1:size(bands,1));
% set(gca,'XTickLabel', bandLabels);
% set(gca,'YTickLabel', bandLabels);
% colorbar;
% title('Max Correlation');
