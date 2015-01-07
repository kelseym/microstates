%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();
load(fileName);
cfg = [];
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg, data);
data = ConcatenateTrials(data);
dataMatrix = data.trial{1};

%% compute microstate templates and gfp
[gfp, gfpPkLocs] = LocateGfpPeaks(dataMatrix);

numMicrostates=2;

cfg = [];
cfg.numtemplates = numMicrostates;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
globalMicrostateTemplates = ExtractMicrostateTemplates(cfg);

microstateTemplates = globalMicrostateTemplates{1}{1};

% Compute correlation between templates and original signal
templateCorrelations = zeros(size(microstateTemplates,1),size(dataMatrix,2));
for tmpltj=1:size(microstateTemplates,1)
    template = microstateTemplates(tmpltj,:)';
    templateCorrelations(tmpltj,:) = abs(corr(template,dataMatrix(:,:)));
end

% GEV per template
gevk = zeros(numMicrostates,1);
for msi=1:numMicrostates
    tmpltMtchMsk = maxCorrTemplIdx{trli} == msi;
    prod = gfp{trli}(tmpltMtchMsk).*templateCorrelations{trli}(msi,tmpltMtchMsk);
    numer = sumsqr(prod);
    denom = sumsqr(gfp{trli}(tmpltMtchMsk));
    gevk(msi) = numer/denom;
end
globalExVarK{trli, numMicrostates} = gevk;








  