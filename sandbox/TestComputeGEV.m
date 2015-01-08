%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();
maxNumMicroStates = 6;
trialLength = 40;


load(fileName);
cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);
data = ConcatenateTrials(data);
dataMatrix = data.trial{1};

%% compute microstate templates
for numMicrostates=1:maxNumMicroStates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = data;
  cfg.clustertrainingstyle = 'global';
  globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
  microstateTemplates = globalMicrostateTemplates{1}{1};

  gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataMatrix);
  gev(numMicrostates) = sum(gevk);
  
end

%% Plot GEV
figure, hold on;
title('Template Quantity Selection');
ylabel('GEV');
xlabel('Number of Microstate Templates');
plot(gev,'-', 'LineWidth', 3);
grid off;
set(gca, 'XGrid', 'on');
xlim([1 maxNumMicroStates]);
set(gca,'XTick',1:maxNumMicroStates);

%% For each trial, plot GEV
cfg = [];
cfg.length=trialLength;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);

for numMicrostates=1:maxNumMicroStates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = data;
  cfg.clustertrainingstyle = 'trial';
  trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);
  for trli=1:length(data.trial)
    microstateTemplates = trialMicrostateTemplates{1}{trli};
    dataMatrix = data.trial{trli};
    gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataMatrix);
    trialGev(trli, numMicrostates) = sum(gevk);
  end
end

%% Plot GEV
figure, hold on;
title('Per Trial Template Quantity Selection');
ylabel('GEV');
xlabel('Number of Microstate Templates');
plot(trialGev','-', 'LineWidth', 1);
grid off;
set(gca, 'XGrid', 'on');
xlim([1 maxNumMicroStates]);
set(gca,'XTick',1:maxNumMicroStates);
lgnd = {};
for i=1:length(data.trial)
  lgnd{end+1}=sprintf('%i',i);
end
legend(lgnd);
plot(mean(trialGev),'k-*','LineWidth',2,'MarkerSize', 15);


plot(gev,'b-', 'LineWidth', 3);


