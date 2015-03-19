%% Extract microstate parameters from MEG scans
clear;

numMicrostates = 3;
fileName = GetLocalDataFile();
lineColors = [147 164 201; 147 201 167; 201 147 147]/255;


% select and open preprocessed HCP MEG data file
load(fileName, 'data');
[~, scanLabel, ~] = fileparts(fileName);

% % select channels from specified region
% roiIndex = 1;
% load('4D248_labelROI.mat');
% roiChannels = labels(labelROI==roiIndex);
% cfg = [];
% cfg.channel = roiChannels;
% data = ft_selectdata(cfg, data);

% band filter preprocess
cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 40];
data = ft_preprocessing(cfg, data);

data = ConcatenateTrials(data);

%% Plot single channel time series
pltSmpls = 0:0.5*data.fsample;
pltSmpls = floor(pltSmpls)+1;
fh = figure;
xlabel('Seconds');
ylabel('Sensor Amplitude');
hold on;
signal = data.trial{1}(10,pltSmpls);
time = data.time{1}(pltSmpls);
mx = max(signal);
mn = min(signal);
plot(time, signal, 'k', 'LineWidth', 3);
ylim([mn mx]);

ylim = get(gca, 'YLim');
xlim = get(gca, 'XLim');
limitLine = ones(1,length(time))*ylim(2);


%% Extract GFP Peaks
for trli=1:length(data.trial)
  [gfp{trli}, gfpPkLocs{trli}] = LocateGfpPeaks(data.trial{trli});
end
data.gfpPkLocs = gfpPkLocs;
data.gfp = gfp;


%% extract N microstate templates
cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
microstateTemplates = ExtractMicrostateTemplates(cfg);


% %% Plot Template Maps
% cfg = [];
% cfg.layout = '4D248.mat';
% lay = ft_prepare_layout(cfg);
% fh = PlotMicrostateTemplateSet(microstateTemplates{1}{1}, data.label, lay, scanLabel);

%% partition data into N second (non-)overlaping trials
data = ConcatenateTrials(data);
  
%% find microstate sequence in electroneurophys data
cfg = [];
cfg.microstateTemplates = microstateTemplates{1}{1};
data = AssignMicrostateLabels(cfg, data);

%% Plot color coded areas
microstateIndices = data.microstateIndices{1};
[~, tmplSwitchIdx] = find(diff(microstateIndices(pltSmpls)));
% include extra index to catch the final value
tmplSwitchIdx(end+1) = length(microstateIndices(pltSmpls));
tmplSwitchVal = microstateIndices(tmplSwitchIdx);

startIdx = pltSmpls(1);
tmplSwitchIdx = tmplSwitchIdx + (startIdx-1);
for j=2:length(tmplSwitchIdx)
  endIdx = tmplSwitchIdx(j);
  ah = area(time(startIdx:endIdx), limitLine(startIdx:endIdx), 'FaceColor', lineColors(tmplSwitchVal(j),:),'EdgeColor', lineColors(tmplSwitchVal(j),:), 'LineStyle', 'none', 'LineWidth', 0.0);
  uistack(ah,'bottom');
  set(ah,'BaseValue',ylim(1));
  startIdx = tmplSwitchIdx(j)+1;
end
hold off;



