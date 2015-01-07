%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();
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

%% compute microstate templates and gfp
[gfp, gfpPkLocs] = LocateGfpPeaks(dataMatrix);
maxNumMicroStates = 20;
for numMicrostates=1:maxNumMicroStates
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = data;
  cfg.clustertrainingstyle = 'global';
  globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);

  microstateTemplates = globalMicrostateTemplates{1}{1};

  % Compute correlation between templates and original signal
  templateCorrelations = zeros(size(microstateTemplates,1),size(dataMatrix,2));
  for tmpltj=1:size(microstateTemplates,1)
      template = microstateTemplates(tmpltj,:)';
      templateCorrelations(tmpltj,:) = abs(corr(template,dataMatrix(:,:)));
  end
  [maxCorrTempl, maxCorrTemplIdx] = max(templateCorrelations,[],1);

  % GEV per template
  gevk = zeros(numMicrostates,1);
  gfpPeakMask = zeros(size(maxCorrTemplIdx));
  gfpPeakMask(gfpPkLocs) = 1;
  maxCorrTemplIdx = gfpPeakMask.*maxCorrTemplIdx;
  for msi=1:numMicrostates
      templateMatchMask = maxCorrTemplIdx == msi;
      prod = gfp(templateMatchMask).*templateCorrelations(msi,templateMatchMask);
      numer = sumsqr(prod);
      denom = sumsqr(gfp(find(gfpPeakMask)));
      gevk(msi) = numer/denom;
  end
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






  