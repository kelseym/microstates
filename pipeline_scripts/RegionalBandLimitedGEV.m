%% compute global explained variance of a microstate template set
%clear;



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
if ~exist('bands','var')
  bands =       [1,35;       1,120;    4,10;        35,50;     50,76;      76,120];
  bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh'};
  % bands =       [4,10;        35,50;     50,76;      76,120;      35,50;        50,76;         76,120];
  % bandLabels = {'ThetaAlpha','GammaLow','GammaMid', 'GammaHigh','EnvGammaLow','EnvGammaMid', 'EnvGammaHigh'};
end
if ~iscell(bandLabels)
  bandLabels = {bandLabels};
end



maxNumMicroStates = 15;

% load 9 region map
load('4D248_labelROI.mat');

load(fileName);

data = ConcatenateTrials(data);
cfg.length=trialLength;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);


for bndi=1:size(bands,1)
  band = bands(bndi,:);
  
  disp(sprintf('Processing %s Band', bandLabels{bndi}));
  
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
  
  % All region indices
  roiIndices = unique(labelROI);
  for rgni=1:length(roiIndices)
    if roiIndices(rgni) <1 
      continue;
    end
    roiChannels = labels(labelROI==roiIndices(rgni));
    cfg = [];
    cfg.channel = roiChannels;
    rgnDataBL = ft_selectdata(cfg, dataBL);
    cfg = [];
    cfg.maxnummicrostates = 15;
    % GEV metrics for each region. gev is further partitioned by numMicrostates and trial. i.e. gev(bandIndex,regionIndex,numMicrostates,trialIndex)
    [gevArea(rgni,:), maxExVar(rgni,:), gev(rgni,:,:)] = ComputeGEVMetrics(cfg,rgnDataBL);
    clear 'rgnDataBL';
  end
  
  % save band specific gev
  [~,dataName,~] = fileparts(fileName);
  outputFileName = [outputDir filesep sprintf('%s_RegionalBandLimitedGEV_%sBand_%iSecTrial.mat',dataName,bandLabels{bndi},trialLength)];
  save(outputFileName, 'gevArea', 'maxExVar', 'gev');
  
  clear 'dataBL' 'gevArea' 'maxExVar' 'gev';
end

