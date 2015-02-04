%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();

numMicrostates = 3;
maxFreq = 120;
bands =       [1,50;  1,100;  1,4;    4,8;    8,15;   15,26;     26,35;     35,50;     50,76;      76,120];
bandLabels = {'1-50','1-100','Delta','Theta','Alpha','BetaLow', 'BetaHigh','GammaLow','GammaMid', 'GammaHigh'};
% bands =       [1,50; 1,4];
% bandLabels = {'1-50', '1-4'};

load(fileName);
data = ConcatenateTrials(data);
cfg = [];
cfg.resamplefs = maxFreq;
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';


fh1 = figure;
for bndi=1:size(bands,1)
  band = bands(bndi,:);

  cfg = [];
  cfg.continuous = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
  dataBL = ft_preprocessing(cfg, data);

  % compute microstate templates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataBL;
  cfg.clustertrainingstyle = 'global';
  globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
  microstateTemplates = globalMicrostateTemplates{1}{1};
  
  % Plot templates
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  for plti=1:numMicrostates
    subplot(size(bands,1), numMicrostates, ((bndi-1)*numMicrostates)+plti);
    PlotMicrostateTemplate(microstateTemplates(plti,:), dataBL.label, lay);
    if plti==1
      title(bandLabels{bndi});
    end
  end
  
  
  % find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = microstateTemplates;
  dataBL = AssignMicrostateLabels(cfg, dataBL);

  % extract features from microstate sequence
  cfg = [];
  cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks'};
  dataBL = MeasureFeatures(cfg, dataBL);

  % collect feature values
  
  meanDuration(bndi) = mean(GetFeatureValue(dataBL, 'meanduration'));
  gfpPeakRate(bndi) = mean(GetFeatureValue(dataBL, 'gfppeakrate'));
  
end

%% Plot features
figure;
bar(meanDuration);
set(gca, 'XTickLabel', bandLabels);
title('Mean Duration');

figure;
bar(gfpPeakRate);
set(gca, 'XTickLabel', bandLabels);
title('GFP Peak Rate');

