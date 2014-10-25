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

%% Plot Template Maps
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
fh = PlotMicrostateTemplateSet(localMicrostateTemplates{1}{1}, data.label, lay, ['Local Templates ' scanLabel]);


% Find trial cluster centers (2 second default for HCP data) 
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = dataStructs;
cfg.clustertrainingstyle = 'trial';
trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);

% Plot template maps for each 2sec trial
for trlIndx=1:length(trialMicrostateTemplates{1})
  fh = PlotMicrostateTemplateSet(trialMicrostateTemplates{1}{trlIndx}, data.label, lay, sprintf('Trial %i Templates %s', i, scanLabel));
  drawnow;
  frames(trlIndx) = getframe(fh);
  close(fh);
end

% For each 2sec trial, find the distance to the corresponding local cluster
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
hold on;
for i=1:numMicrostates
  tmpDist = normTemplateDistance(i,:)+i;
  plot(tmpDist);
end
  
  
  
