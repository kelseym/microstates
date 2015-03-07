
chan = [1,3:8,10:14,16:21,23];
samples = 4832:6984;

filename = '/Users/Kelsey/Projects/EON/eon_microstates/local/FNST1_120120-15-NEO_parc.edf';
cfg=[];
cfg.datafile = filename;
cfg.channels = chan;
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [1.0 40.0];
data = ft_preprocessing(cfg);


dataMatrix = data.trial{1}(chan, samples);
data.trial{1} = dataMatrix;
data.label = data.label();

PlotTimeSeries(data, 0, 5, '');


[gfp, gfpPkLocs] = LocateGfpPeaks(dataMatrix);
startS = 0;
endS = 5;
pltSmpls = startS*data.fsample:endS*data.fsample;
pltSmpls = floor(pltSmpls)+1;
figure;
plot(data.time{1}(pltSmpls), gfp(pltSmpls),'b');
title(['Global Field Power']);
xlabel('Time (s)');
ylabel('GFP');
hold on;
pltPksIndx = gfpPkLocs(gfpPkLocs<(5*data.fsample));
plot(data.time{1}(pltPksIndx), gfp(pltPksIndx),'r.');

cfg = [];
cfg.numtemplates = 4;
cfg.datastructs = data;
cfg.clustertrainingstyle = 'global';
microstateTemplates = ExtractMicrostateTemplates(cfg);






