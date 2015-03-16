%% BandLimitedChannelDispersion
%   Measure and display microstate template dispersion by channel

%% load data and variables using static values unless already defined (e.g. using cluster scripts)
if ~exist('fileName','var')
  disp('fileName not defined. Using local test file.');
  fileName = GetLocalDataFile();
end
if ~exist('outputDir','var')
  disp('outputDir not defined. Using local test directory.');
  outputDir = GetLocalOutputDirectory();
end
if ~exist('trialLength','var')
  disp('trialLength not defined. Using 240s default.');
  trialLength = 240;
end
if ~exist('numMicrostates','var')
  disp('numMicrostates not defined. Using 3 as default.');
  numMicrostates = 3;
end
if ~exist('bands','var')
  bands =       [1,35;  1,120;          1,4;    4,8;    8,15;   15,26;     26,35;     35,50;     50,76;      76,120;     35,50;        50,76;         76,120];
  bandLabels = {'Broadband','Fullband','Delta','Theta','Alpha','BetaLow', 'BetaHigh','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
  % bands =       [4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
  % bandLabels = {'ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
end
if ~iscell(bandLabels)
  bandLabels = {bandLabels};
end
if exist('path', 'var')
    addpath(path)
end

% print matlab version information
ver

% print parameters to output
fileName
outputDir
trialLength
numMicrostates
bands
bandLabels
path

tic;
load(fileName);

% parse trials
data = ConcatenateTrials(data);
cfg.length=trialLength;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);

% optionally replace signal with noise
replaceWithNoise = 0;
if replaceWithNoise 
  for trli=1:length(data.trial)
    overallRange = mean(range(data.trial{trli},2));
    overallMin = mean(min(data.trial{trli},2));
    randTrial = randn(size(data.trial{trli},1), size(data.trial{trli},2));
    randTrial = randTrial.*overallRange;
    randTrial = randTrial + overallRange;
    data.trial{trli} = randTrial;
  end
end


dataBL = cell(size(bands,1),1);
for bndi=1:size(bands,1)
  band = bands(bndi,:);
  
  fprintf('Processing %s ', bandLabels{bndi});
 
  % band pass filter the data
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
  dataBL{bndi} = ft_preprocessing(cfg, data);

  % de-mean enveloped signal to form dipole like activity
  if strfind(bandLabels{bndi},'Env')
    cfg = [];
    cfg.detrend    = 'yes';
    cfg.demean     = 'yes';
    cfg.feedback   = 'no';
    cfg.trials     = 'all';
    cfg.continuous = 'yes';
    dataBL{bndi} = ft_preprocessing(cfg, dataBL{bndi});
  end

  % extract microstates from bp data
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataBL{bndi};
  cfg.clustertrainingstyle = 'trial';
  templates = ExtractMicrostateTemplates(cfg);
  dataBL{bndi}.microstateTemplates = templates{1};

  % Plot Template Maps
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh1 = PlotMicrostateTemplateSet(dataBL{bndi}.microstateTemplates{1}, data.label, lay, bandLabels{bndi});
  colormap(jet);
  % save template topo plot
  [~,dataName,~] = fileparts(fileName);
  outputFileName = [outputDir filesep sprintf('%s_BandLimitedChannelDispersion_Templates_NumMicrostates-%i_TrialLength-%i_Band-%s',dataName,numMicrostates,trialLength,bandLabels{bndi})];
  saveas(fh1,outputFileName,'fig')
  saveas(fh1,outputFileName,'png')
  
  %% find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = dataBL{bndi}.microstateTemplates{1};
	dataBL{bndi} = AssignMicrostateLabels(cfg, dataBL{bndi});
  
  % compute per channel dispersion of each template
  cfg = [];
  cfg.channelstatistic = 'dispersion';
  dataBL{bndi} = PerChannelTemplateStatistic(cfg, dataBL{bndi});
  
  % plot per channel dispersion
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh2 = PlotMicrostateTemplateSet(dataBL{bndi}.dispersion{1}, data.label, lay, [bandLabels{bndi} ' Channel Dispersion']);
  colormap(cool);
  % save template topo plot
  [~,dataName,~] = fileparts(fileName);
  outputFileName = [outputDir filesep sprintf('%s_BandLimitedChannelDispersion_Dispersion_NumMicrostates-%i_TrialLength-%i_Band-%s',dataName,numMicrostates,trialLength,bandLabels{bndi})];
  saveas(fh2,outputFileName,'fig')
  saveas(fh2,outputFileName,'png')
  

  close all
  % clear trial data from dataBL to save space
  dataBL{bndi}.trial = {};
end

[~,dataName,~] = fileparts(fileName);
outputFileName = [outputDir filesep sprintf('%s_BandLimitedChannelDispersion_NumMicrostates-%i_TrialLength-%i.mat',dataName,numMicrostates,trialLength)];
save(outputFileName, 'dataBL', 'bands', 'bandLabels', 'dataName');
toc;
  
