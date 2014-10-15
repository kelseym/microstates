%% Process ECoG data using microstate analysis
clear;

%% open and preprocess scan

% McD03a Grid info
channelList = [1:32] ;
badChannels = [1:3] ;
dataFileName = '/Users/Kelsey/Projects/McDonnell/McD03 anon EDF/McD03_wake_1726-173.edf';
dataFileLabel = 'McD03 Wake';

% open
cfg = [];
cfg.datafile = dataFileName;
cfg.continuous = 'yes';
dataRaw = ft_preprocessing(cfg);

% select grid channels and remove bad channels
cfg = [];
cfg.channel = channelList;
cfg.channel(badChannels) = [];
dataClean = ft_selectdata(cfg, dataRaw);
clear dataRaw;

% band filter preprocess
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, dataClean);
clear dataClean;


%% extract N microstate templates
cfg = [];
cfg.numtemplates = 4;
cfg.datastructs = data;
microstateTemplates = ExtractMicrostateTemplates(cfg);

%% find distance between cluster centers
distanceMatrix = dist(microstateTemplates', 'euclidean');
distanceMatrix(distanceMatrix==0)=NaN;
closestClusterNeighboor = min(distanceMatrix);

%% partition data into N second (non-)overlaping trials
cfg = [];
cfg.length=10;
cfg.overlap=0.0;
data = ft_redefinetrial(cfg, data);

%% find microstate sequence in electroneurophys data
for trli=1:length(data.trial)
  % Compute correlation between templates and original signal
  data.templateCorrelations{trli} = zeros(size(microstateTemplates,1),size(data.trial{trli},2));
  for tmpltj=1:size(microstateTemplates,1)
      template = microstateTemplates(tmpltj,:)';
      data.templateCorrelations{trli}(tmpltj,:) = abs(corr(template,data.trial{trli}(:,:)));
  end
  % select template index with maximum correlation to the data at each sample point
  [~, data.microstateIndices{trli}] = max(data.templateCorrelations{trli},[],1);
end

%% extract features from microstate sequence
cfg = [];
cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks'};
data = MeasureFeatures(cfg, data);





