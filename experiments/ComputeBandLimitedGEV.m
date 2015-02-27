%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();

maxNumMicroStates = 10;
maxFreq = 120;
%bands =       [1,50;       1,120;    4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
%bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
bands =       [1 120; 50 76; 50 76];
bandLabels = {'FullBand','GammaMid','EnvGammaMid'};
colors = lines();

load(fileName);
data = ConcatenateTrials(data);
cfg = [];
cfg.resamplefs = maxFreq*2;
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';
cfg.continuous = 'yes';

gev = zeros(size(bands,1),maxNumMicroStates);
for bndi=1:size(bands,1)
  band = bands(bndi,:);
  bandLabels{bndi}

  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
  if strfind(bandLabels{bndi},'Env')
    cfg.hilbert = 'abs';
  end
  dataBL = ft_preprocessing(cfg, data);

  %% compute microstate templates
  
  for numMicrostates=1:maxNumMicroStates
    cfg = [];
    cfg.numtemplates = numMicrostates;
    cfg.datastructs = dataBL;
    cfg.clustertrainingstyle = 'global';
    globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
    microstateTemplates = globalMicrostateTemplates{1}{1};

    gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataBL.trial{1});
    gev(bndi,numMicrostates) = sum(gevk);
  end
  clear 'dataBL';
end

%% Plot GEV
figure, hold on;
title('Template Quantity Selection');
ylabel('GEV');
xlabel('Number of Microstate Templates');
hold on;
for bndi=1:size(gev,1)
  plot(gev(bndi,:),'.-', 'LineWidth', 2, 'Color', colors(bndi,:));
end
grid off;
set(gca, 'XGrid', 'on');
xlim([1 maxNumMicroStates]);
set(gca,'XTick',1:maxNumMicroStates);
legend(bandLabels);


