% Test dependence of cluster training locality on stability

clear;

numMicrostates = 3;
fileName = GetLocalDataFile();


% select and open preprocessed HCP MEG data file
load(fileName, 'data');
[~, scanLabel, ~] = fileparts(fileName);

% dataStructs contains a cell array of fieldtrip data strutures - which
% will be concatenated to derive microstate templates - just one for now
dataStructs{1} = data;

% band filter preprocess
cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);

% Find local cluster centers (using all data in single file)
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = dataStructs;
cfg.clustertrainingstyle = 'local';
localMicrostateTemplates = ExtractMicrostateTemplates(cfg);

%% Test stability of clusters when data is partitioned into N second chunks
continuousData = ConcatenateTrials(data);
for trialLength=[1,2,4,8,16,32,64,128,256]
  % Compose N second trials
  cfg = [];
  cfg.length=trialLength;
  cfg.overlap=0.0;
  nSecTrialData = ft_redefinetrial(cfg, continuousData);

  % Find trial cluster centers
  cfg = [];
  cfg.numtemplates = numMicrostates;
  cfg.datastructs = {nSecTrialData};
  cfg.clustertrainingstyle = 'trial';
  trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);

  % For each N sec trial, find the distance to the corresponding local cluster
  templateDistance = zeros(numMicrostates, length(trialMicrostateTemplates{1}));
  for trlIndx=1:length(trialMicrostateTemplates{1})
    trialTemplate = trialMicrostateTemplates{1}{trlIndx};
    for msIndx=1:numMicrostates
      templateDistance(msIndx,trlIndx) = norm(trialTemplate(msIndx,:) - localMicrostateTemplates{1}{1}(msIndx,:));
    end
  end

  % Plot global cluster centers at integers. Normalize, then plot trial cluster distances to global center
  mx = max(max(templateDistance));
  mn = min(min(templateDistance));
  normTemplateDistance = (templateDistance-mn)/mx;
  figure;
  title(sprintf('%i Second Trial Template Map Stability',trialLength)); 
  hold on;
  for i=1:numMicrostates
    tmpDist = normTemplateDistance(i,:)+i;
    plot(tmpDist);
  end
  hold off;
end
  
  
