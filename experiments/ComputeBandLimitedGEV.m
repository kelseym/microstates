%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();

maxNumMicroStates = 10;
% bands =       [1,50;       1,120;    4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
% bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
bands =       [1,35;  1,120;          1,4;    4,8;    8,15;   15,26;     26,35;     35,50;     50,76;      76,120];
bandLabels = {'Broadband','Fullband','Delta','Theta','Alpha','BetaLow', 'BetaHigh','GammaLow','GammaMid', 'GammaHigh'};
colors = hsv(length(bandLabels));

load(fileName);
data = ConcatenateTrials(data);
gev = zeros(size(bands,1),maxNumMicroStates);
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


  %% compute microstate templates

  for numMicrostates=1:maxNumMicroStates
    cfg = [];
    cfg.numtemplates = numMicrostates;
    cfg.datastructs = dataBL;
    cfg.clustertrainingstyle = 'trial';
    trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);

    for trli=1:length(data.trial)
      microstateTemplates = trialMicrostateTemplates{1}{trli};
      gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataBL.trial{trli});
      gev(bndi,numMicrostates,trli) = sum(gevk);
    end
  end
  clear 'dataBL';
end

%% Plot GEV
for trli=1:length(data.trial)
  figure, hold on;
  title('Template Quantity Selection');
  ylabel('GEV');
  xlabel('Number of Microstate Templates');
  hold on;
  for bndi=1:size(gev,1)
    plot(gev(bndi,:,trli),'.-', 'LineWidth', 2, 'Color', colors(bndi,:));
  end
  grid off;
  set(gca, 'XGrid', 'on');
  xlim([1 maxNumMicroStates]);
  set(gca,'XTick',1:maxNumMicroStates);
  legend(bandLabels);
end