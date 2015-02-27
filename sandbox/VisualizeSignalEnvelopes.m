%% Visualize Signal Envelopes

clear;
% load data
fileName = GetLocalDataFile();

plotNSec = 5; 
baseBand =         [4,10];
baseBandLabel =    {'ThetaAlpha'};
gammaBands =       [35,50;     50,76;      76,120];
gammaBandLabels = {'GammaLow','GammaMid', 'GammaHigh'};


load(fileName);
data = ConcatenateTrials(data);

%% Plot one channel of base signal with envelope
cfg = [];
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';
cfg.continuous = 'yes';

cfg.bpfilter = 'yes';
cfg.bpfreq = baseBand;
dataBL = ft_preprocessing(cfg, data);

cfg = [];
cfg.hilbert = 'abs';
dataBLEnv = ft_preprocessing(cfg, dataBL);

cfg = [];
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';
cfg.continuous = 'yes';
dataBLEnv = ft_preprocessing(cfg, dataBLEnv);


figure;
numPlots = length(gammaBands)+1;
subplot(numPlots,1,1);

plot(dataBL.trial{1}(1,1:dataBL.fsample*plotNSec),'b');
set(gca,'XLim',[1 dataBL.fsample*plotNSec]);
hold on;
plot(dataBLEnv.trial{1}(1,1:dataBL.fsample*plotNSec),'r', 'LineWidth',2);
title(baseBandLabel);
hold off;

%% Plot Gamma signals (one channel) with there envelopes
for bndi=1:size(gammaBands,1)
  cfg = [];
  cfg.detrend    = 'yes';
  cfg.demean     = 'yes';
  cfg.feedback   = 'no';
  cfg.trials     = 'all';
  cfg.continuous = 'yes';
  band = gammaBands(bndi,:);

  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
  dataBL = ft_preprocessing(cfg, data);
  
  cfg = [];
  cfg.hilbert = 'abs';
  dataBLEnv = ft_preprocessing(cfg, dataBL);

  cfg = [];
  cfg.detrend    = 'yes';
  cfg.demean     = 'yes';
  cfg.feedback   = 'no';
  cfg.trials     = 'all';
  cfg.continuous = 'yes';
  dataBLEnv = ft_preprocessing(cfg, dataBLEnv);
  
  subplot(numPlots,1,bndi+1);
  plot(dataBL.trial{1}(1,1:dataBL.fsample*plotNSec),'b');
  set(gca,'XLim',[1 dataBL.fsample*plotNSec]);
  hold on;
  plot(dataBLEnv.trial{1}(1,1:dataBL.fsample*plotNSec),'r', 'LineWidth',2);
  title(gammaBandLabels{bndi});
  hold off;
end
  
  
%% Plot correlation between base signal and gamma signals (across all channels)



