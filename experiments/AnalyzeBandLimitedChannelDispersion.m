%% load, analyze and plot channel dispersion metrics generated using RegionalBandLimitedChannelDispersion.m
clear;

dataDir = GetLocalOutputDirectory();

bands =       [1,35;  1,120;          1,4;    4,8;    8,15;   15,26;     26,35;     35,50;     50,76;      76,120;     35,50;        50,76;         76,120];
bandLabels = {'Broadband','Fullband','Delta','Theta','Alpha','BetaLow', 'BetaHigh','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};

trialLength = 240;

numMicrostates = 3;

experimentids = {'105923_MEG_3-Restin', ...
% '106521_MEG_3-Restin', ...
% '109123_MEG_3-Restin', ...
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
      avgCorr = zeros(length(data.microstateTemplates),1);
      for trli=1:length(data.microstateTemplates)
        for 
      
    end
    
  end

  
  
end






