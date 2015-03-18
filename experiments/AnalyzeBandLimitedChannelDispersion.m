%% load, analyze and plot channel dispersion metrics generated using RegionalBandLimitedChannelDispersion.m
clear;

dataDir = GetLocalOutputDirectory();

bands =       [1,35;  1,120;          1,4;    4,8;    8,15;   15,26;     26,35;     35,50;     50,76;      76,120;     35,50;        50,76;         76,120];
bandLabels = {'Broadband','Fullband','Delta','Theta','Alpha','BetaLow', 'BetaHigh','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};

trialLength = 240;

numMicrostates = 3;

experimentids = {'105923_MEG_3-Restin', ...
'106521_MEG_3-Restin', ...
'109123_MEG_3-Restin', ...
% '114823_MEG_3-Restin', ...
% '153732_MEG_3-Restin', ...
% '166438_MEG_3-Restin', ...
% '172029_MEG_3-Restin', ...
% '185442_MEG_3-Restin', ...
% '189349_MEG_3-Restin', ...
% '205119_MEG_3-Restin', ...
% '255639_MEG_3-Restin', ...
% '287248_MEG_3-Restin', ...
% '559053_MEG_3-Restin', ...
% '568963_MEG_3-Restin', ...
% '601127_MEG_3-Restin', ...
% '660951_MEG_3-Restin', ...
% '665254_MEG_3-Restin', ...
% '715950_MEG_3-Restin', ...
% '820745_MEG_3-Restin', ...
% '912447_MEG_3-Restin'  ...
};

colors = lines(10);

bandLimitedCorr = zeros(length(experimentids),length(bandLabels),numMicrostates);
experimentData = cell(length(experimentids),1);
for exprmntdi=1:length(experimentids)
  experimentid = experimentids{exprmntdi};
  

  matDataFile = dir([dataDir sprintf('*%s*_BandLimitedChannelDispersion_NumMicrostates-%i_TrialLength-%i.mat',experimentid,numMicrostates,trialLength)]);
  if isempty(matDataFile)
    error('No file found matching *%s*_BandLimitedChannelDispersion_NumMicrostates-%i_TrialLength-%i.mat',experimentid,numMicrostates,trialLength);
  else
    if length(matDataFile) >1
      error('Mutiple matches found for *%s*_BandLimitedChannelDispersion_NumMicrostates-%i_TrialLength-%i.mat',experimentid,numMicrostates,trialLength);
    end
    experimentData{exprmntdi} = load([dataDir matDataFile(1).name]);

    % for each band of interest, calculate correlation between topographic template and channel dispersion
    for bndi=1:length(bandLabels)
      [~, bndIdx] = match_str(bandLabels{bndi}, experimentData{exprmntdi}.bandLabels);
      if isempty(bndIdx)
        error('Band Label: %s not found in %s',bandLabels{bndi},experimentData{exprmntdi}.dataName);
      end
      data = experimentData{exprmntdi}.dataBL{bndIdx};
      templat2DispersionCorr = zeros(length(data.microstateTemplates), length(data.microstateTemplates));
      for trli=1:length(data.microstateTemplates)
        for tmplti=1:size(data.microstateTemplates{trli},1)
          template = data.microstateTemplates{trli}(tmplti,:);
          dispersion = data.dispersion{trli}(tmplti,:);
          templat2DispersionCorr(tmplti,trli) = corr2(abs(template)/norm(abs(template)),dispersion/norm(dispersion));
        end
      end
      bandLimitedCorr(exprmntdi,bndi,:) = mean(templat2DispersionCorr,2);
      
%       % Plot Template Maps
%       cfg = [];
%       cfg.layout = '4D248.mat';
%       lay = ft_prepare_layout(cfg);
%       fh1 = PlotMicrostateTemplateSet(data.microstateTemplates{1}, data.label, lay, bandLabels{bndi});
%       colormap(jet);
% 
%       % plot per channel dispersion
%       cfg = [];
%       cfg.layout = '4D248.mat';
%       lay = ft_prepare_layout(cfg);
%       fh2 = PlotMicrostateTemplateSet(data.dispersion{1}, data.label, lay, [bandLabels{bndi} ' Channel Dispersion']);
%       colormap(cool);
    
    end
    
    figure;
    bh1 = bar(squeeze(bandLimitedCorr(exprmntdi,:,:)));
    title(sprintf('Mean Template to Dispersion Correlation - %s',experimentData{exprmntdi}.dataName));
    set(gca, 'XTick', 1:length(bandLabels));
    set(gca, 'XTickLabel',bandLabels);
    xticklabel_rotate;
    
    figure;
    bh2 = bar(squeeze(mean(bandLimitedCorr(exprmntdi,:,:),3)));
    title(sprintf('Template to Dispersion Correlation - %s',experimentData{exprmntdi}.dataName));
    set(gca, 'XTick', 1:length(bandLabels));
    set(gca, 'XTickLabel',bandLabels);
    xticklabel_rotate;
    
    
  end
  
  
end

  
figure;
bh1 = bar(squeeze(mean(bandLimitedCorr(:,:,:),1)));
title(sprintf('Population Template to Dispersion Correlation'));
set(gca, 'XTick', 1:length(bandLabels));
set(gca, 'XTickLabel',bandLabels);
xticklabel_rotate;

figure;
bh2 = bar(squeeze(mean(mean(bandLimitedCorr(:,:,:),1),3)));
title(sprintf('Population Template to Dispersion Correlation'));
set(gca, 'XTick', 1:length(bandLabels));
set(gca, 'XTickLabel',bandLabels);
xticklabel_rotate;






