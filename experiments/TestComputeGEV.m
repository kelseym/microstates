%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();
maxNumMicroStates = 10;
trialLengths = [5,10,30,45,60,120,240];


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

%% Compute trial GEV
meanTrialGev = {};
for i=1:length(trialLengths)
  trlLngth=trialLengths(i);
  %% For each trial, plot GEV
  cfg = [];
  cfg.length=trlLngth;
  cfg.overlap=0.0;
  trlData = ft_redefinetrial(cfg, data);

  for numMicrostates=1:maxNumMicroStates
    cfg = [];
    cfg.numtemplates = numMicrostates;
    cfg.datastructs = trlData;
    cfg.clustertrainingstyle = 'trial';
    trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);
    for trli=1:length(trlData.trial)
      microstateTemplates = trialMicrostateTemplates{1}{trli};
      dataMatrix = trlData.trial{trli};
      gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataMatrix);
      trialGev(trli, numMicrostates) = sum(gevk);
    end
  end
  meanTrialGev{i} = mean(trialGev,1);
end

%% Plot GEV
figure, hold on;
title('Per Trial Template Quantity Selection');
ylabel('GEV');
xlabel('Number of Microstate Templates');
grid off;
set(gca, 'XGrid', 'on');
xlim([1 maxNumMicroStates]);
set(gca,'XTick',1:maxNumMicroStates);
lgnd = {};

plot(gev,'b-', 'LineWidth', 3);
lgnd{end+1} = 'Global';
hold on;
for i=1:length(trialLengths)
  trlLngth=trialLengths(i);
  plot(meanTrialGev{i}','-', 'LineWidth', 1);
  lgnd{end+1}=sprintf('%i sec trials',trialLengths(i));
end
legend(lgnd);

