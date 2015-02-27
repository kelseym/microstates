%% Visualize Signal Envelopes

clear;
% load data
fileName = GetLocalDataFile();

bands =       [4,10;       35,50;     50,76;      76,120];
bandLabels = {'ThetaAlpha','GammaLow','GammaMid', 'GammaHigh'};
plotNSec = 5; 

load(fileName);
data = ConcatenateTrials(data);
cfg = [];
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';
cfg.continuous = 'yes';

for bndi=1:size(bands,1)
  band = bands(bndi,:);

  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
  dataBL = ft_preprocessing(cfg, data);
  
  cfg.hilbert = 'abs';
  dataBLEnv = ft_preprocessing(cfg, data);
  
  figure;
  plot(dataBL.trial{1}(1,1:dataBL.fsample*plotNSec),'b');
  hold on;
  plot(dataBLEnv.trial{1}(1,1:dataBL.fsample*plotNSec),'r', 'LineWidth',2);
  title(bandLabels{bndi});
  hold off;
end
  
  
  
