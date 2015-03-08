%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();

maxNumMicroStates = 15;
% bands =       [1,50;       1,120;    4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
% bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
bands =       [4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
bandLabels = {'ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
colors = lines();

% load 9 region map
load('4D248_labelROI.mat');

load(fileName);

data = ConcatenateTrials(data);

for bndi=1:size(bands,1)
  band = bands(bndi,:);

  cfg = [];
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
  dataBL = ft_preprocessing(cfg, data);

  if strfind(bandLabels{bndi},'Env')
    cfg = [];
    cfg.detrend    = 'yes';
    cfg.demean     = 'yes';
    cfg.feedback   = 'no';
    cfg.trials     = 'all';
    cfg.continuous = 'yes';
    dataBL = ft_preprocessing(cfg, dataBL);
  end
  
  % All region indices
  roiIndices = unique(labelROI);
  for rgni=1:length(roiIndices)
    roiChannels = labels(labelROI==roiIndices(rgni));
    cfg = [];
    cfg.channel = roiChannels;
    rgnDataBL = ft_selectdata(cfg, dataBL);
    [gevArea(bndi,rgni), maxExVar(bndi,rgni), gev(bndi,rgni)] = ComputeGEVMetrics(cfg,rgnDataBL);
    clear 'rgnDataBL';
  end
  
  clear 'dataBL';
end
% 
% %% Plot GEV
% for trli=1:length(data.trial)
%   figure, hold on;
%   title('Template Quantity Selection');
%   ylabel('GEV');
%   xlabel('Number of Microstate Templates');
%   hold on;
%   for bndi=1:size(gev,1)
%     plot(gev(bndi,:,trli),'.-', 'LineWidth', 2, 'Color', colors(bndi,:));
%   end
%   grid off;
%   set(gca, 'XGrid', 'on');
%   xlim([1 maxNumMicroStates]);
%   set(gca,'XTick',1:maxNumMicroStates);
%   legend(bandLabels);
% end