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
  disp('trialLength not defined. Using 240s default.');
  numMicrostates = 3;
end
if ~exist('bands','var')
  bands =       [1,35;       1,120;    4,10;        35,50;     50,76;      76,120];
  bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh'};
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
bands
bandLabels
path


load(fileName);

% parse trials
data = ConcatenateTrials(data);
cfg.length=trialLength;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);

for bndi=1:size(bands,1)
  band = bands(bndi,:);
  
  disp(sprintf('Processing %s Band', bandLabels{bndi}));
 
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

  % extract microstates from bp data
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = dataBL;
  cfg.clustertrainingstyle = 'trial';
  templates = ExtractMicrostateTemplates(cfg);
  dataBL.microstateTemplates = templates{1};

  % Plot Template Maps
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(dataBL.microstateTemplates{1}, data.label, lay, bandLabels{bndi});
  
  %% find microstate sequence in electroneurophys data
  cfg = [];
  cfg.microstateTemplates = dataBL.microstateTemplates{1};
	dataBL = AssignMicrostateLabels(cfg, dataBL);
  
  % compute per channel dispersion of each template
  cfg = [];
  cfg.channelstatistic = 'dispersion';
  dataBL = PerChannelTemplateStatistic(cfg, dataBL);
  
  % plot per channel dispersion
  cfg = [];
  cfg.layout = '4D248.mat';
  lay = ft_prepare_layout(cfg);
  fh = PlotMicrostateTemplateSet(dataBL.dispersion{1}, data.label, lay, bandLabels{bndi});
  
  
  
end
