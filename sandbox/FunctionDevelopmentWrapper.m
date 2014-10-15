%% Process ECoG data using microstate analysis
clear;

% call function to load a few filenames, bad channel lists, etc
files = GetFileNames();

% open and preprocess scan(s)
dataStructs = OpenAndPreprocess(files);


%% extract N microstate templates
cfg = [];
cfg.numtemplates = 4;
cfg.datastructs = dataStructs;
microstateTemplates = ExtractMicrostateTemplates(cfg);

%% partition data into N second (non-)overlaping trials
cfg = [];
cfg.length=10;
cfg.overlap=0.1;
for i=1:length(dataStructs)
  dataStructs{i} = ft_redefinetrial(cfg, dataStructs{i});
end
  
%% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = microstateTemplates;
for i=1:length(dataStructs)
  dataStructs{i} = AssignMicrostateLabels(cfg, dataStructs{i});
end

%% extract features from microstate sequence
cfg = [];
cfg.features = {'meanduration','stdduration','gfppeakrate','stdgfppeaks'};
for i=1:length(dataStructs)
  dataStructs{i} = MeasureFeatures(cfg, dataStructs{i});
end




