%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();

maxNumMicroStates = 10;
maxFreq = 100;
bands =       [1,50;       1,4;    4,7;   7,13;    13,30; 30,50];
bandLabels = {'Broadband','Delta','Theta','Alpha','Beta','LowGamma','HighGamma'};
%bands =       [1 100; 50 100];
%bandLabels = {'1-100', '50-100'};
colors = lines();

load(fileName);
data = ConcatenateTrials(data);
cfg = [];
cfg.resamplefs = maxFreq;
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';

gev = zeros(size(bands,1),maxNumMicroStates);
for bndi=1:size(bands,1)
  band = bands(bndi,:);

  cfg = [];
  cfg.continuous = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
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


