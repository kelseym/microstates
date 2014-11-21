%% Generate table showing mean microstate duration per subject per N microstates
clear;


baseDir = GetLocalDataDirectory();
baseOutputDir = GetLocalOutputDirectory();
outputFileName = 'microstateDuration.csv';
numMicrostatesToTest = [2,3,4,5,6,7,8,9,10];

files = dir([baseDir '*.mat']);
meanDurationByScan = {};

for filei=1:length(files)

  fprintf('### Processing file %i of %i ###', filei, length(files));
  
  fileName = [baseDir files(filei).name];
  [~, scanLabel, ~] = fileparts(fileName);
  
  % select and open preprocessed HCP MEG data file
  load(fileName, 'data');

  % band filter preprocess
  cfg = [];
  cfg.continuous = 'yes';
  cfg.bsfilter = 'yes';
  cfg.bsfreq = [59 61; 119 121; 179 181];
  cfg.demean = 'yes';
  cfg.detrend = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq = [1.0 40.0];
  data = ft_preprocessing(cfg, data);

  % Reshape data into N second trials to define windows for feature exraction
  data = ConcatenateTrials(data);
  cfg = [];
  cfg.length = 15;
  cfg.overlap = 0.0;
  data = ft_redefinetrial(cfg, data);


  %% extract N microstate templates
  for numMicrostatesIndx=1:length(numMicrostatesToTest)
    numMicrostates = numMicrostatesToTest(numMicrostatesIndx);

    cfg = [];
    cfg.numtemplates = numMicrostates;
    cfg.datastructs = data;
    cfg.clustertrainingstyle = 'global';
    microstateTemplates = ExtractMicrostateTemplates(cfg);

    % find microstate sequence in electroneurophys data
    cfg = [];
    cfg.microstateTemplates = microstateTemplates{1}{1};
    data = AssignMicrostateLabels(cfg, data);


    % extract features from microstate sequence
    cfg = [];
    cfg.features = {'meanduration'};
    data = MeasureFeatures(cfg, data);

    % store mean duration array and scan label in cell array
    meanDurationByScan{end+1} = {scanLabel, numMicrostatesIndx, data.featurevalues{1}};
  end
  
end

%% Write meanDurationByScan to csv file

% open file
outputFileID = fopen([baseOutputDir filesep outputFileName], 'w');

fprintf(outputFileID,'%s,%s,%s', 'ScanID','NumMicrostates','MeanDuration');
fprintf(outputFileID,'\n');
% for every scan
for scanIdx=1:length(meanDurationByScan)
  fprintf(outputFileID, '%s', meanDurationByScan{scanIdx}{1});
  fprintf(outputFileID, ',%i', meanDurationByScan{scanIdx}{2});
  featureValues =  meanDurationByScan{scanIdx}{3};
  fprintf(outputFileID, ',%f', mean(featureValues));
  % for every feature measurement in this scan
  for featurei=1:length(featureValues)
    fprintf(outputFileID,',%f',featureValues(featurei));
  end
  fprintf(outputFileID,'\n');
end
  
% close file
fclose(outputFileID);
