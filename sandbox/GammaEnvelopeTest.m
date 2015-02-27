%% compute templates and metrics on band limited data and envelopes
clear;
% load data
fileName = GetLocalDataFile();

numMicrostates = 3;
maxFreq = 120;
% frequencyBands = GetFrequencyBands();
% bands =       frequencyBands.bands;
% bandLabels =  frequencyBands.bandLabels;
bands =       [1,50;       1,120;    4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};

load(fileName);
data = ConcatenateTrials(data);
cfg = [];
cfg.resamplefs = maxFreq*2;
cfg.detrend    = 'yes';
cfg.demean     = 'yes';
cfg.feedback   = 'no';
cfg.trials     = 'all';
cfg.continuous = 'yes';


fh1 = figure;
for bndi=1:size(bands,1)
  band = bands(bndi,:);

  cfg.bpfilter = 'yes';
  cfg.bpfreq = band;
  if strfind(bandLabels{bndi},'Env')
    cfg.hilbert = 'abs';
  end
  dataBL = ft_preprocessing(cfg, data);

  % compute microstate templates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataBL;
  cfg.clustertrainingstyle = 'global';
  globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);
  microstateTemplates = globalMicrostateTemplates{1}{1};
  dataBL.microstateTemplates = globalMicrostateTemplates{1};
  
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
  cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks','templatedominance'};
  dataBL = MeasureFeatures(cfg, dataBL);

  % collect feature values
  
  meanDuration(bndi) = mean(GetFeatureValue(dataBL, 'meanduration'));
  stdDuration(bndi) = mean(GetFeatureValue(dataBL, 'stdduration'));
  gfpPeakRate(bndi) = mean(GetFeatureValue(dataBL, 'gfppeakrate'));
  stdGfpPeaks(bndi) = mean(GetFeatureValue(dataBL, 'stdgfppeaks'));
  templateDominance(bndi) = mean(GetFeatureValue(dataBL, 'templatedominance'));
  
end

%% Plot features
figure;
bar(meanDuration);
set(gca, 'XTickLabel', bandLabels);
title('Mean Duration');

figure;
bar(stdDuration);
set(gca, 'XTickLabel', bandLabels);
title('STD Duration');

figure;
bar(gfpPeakRate);
set(gca, 'XTickLabel', bandLabels);
title('GFP Peak Rate');

figure;
bar(stdGfpPeaks);
set(gca, 'XTickLabel', bandLabels);
title('STD GFP Peak Rate');

figure;
bar(templateDominance);
set(gca, 'XTickLabel', bandLabels);
title('Dominance');
