%% compute global explained variance of a microstate template set
clear;
% load data
fileName = GetLocalDataFile();
outputDir = GetLocalOutputDirectory();
[~, experientId, ~] = fileparts(fileName);

maxNumMicroStates = 10;
bands =       [1,35];
bandLabels = {'Broadband'};
colors = lines();

load(fileName);
data = ConcatenateTrials(data);
gev = zeros(size(bands,1),maxNumMicroStates);
for bndi=1:size(bands,1)
  band = bands(bndi,:);

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


  %% compute microstate templates

  for numMicrostates=1:maxNumMicroStates
    cfg = [];
    cfg.numtemplates = numMicrostates;
    cfg.datastructs = dataBL;
    cfg.clustertrainingstyle = 'trial';
    trialMicrostateTemplates = ExtractMicrostateTemplates(cfg);
    

    for trli=1:length(data.trial)
      microstateTemplates = trialMicrostateTemplates{1}{trli};
      gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataBL.trial{trli});
      gev(bndi,numMicrostates,trli) = sum(gevk);
      
      % Plot Template Maps
      cfg = [];
      cfg.layout = '4D248.mat';
      lay = ft_prepare_layout(cfg);
      fh1 = PlotMicrostateTemplateSet(microstateTemplates, data.label, lay, [bandLabels{bndi} sprintf('N=%i',numMicrostates)]);
      colormap(jet);
      saveas(fh1, [outputDir sprintf('%s_%s_Trial-%i_NumMicrostates-%i',experientId,bandLabels{bndi},trli,numMicrostates)], 'fig');
      saveas(fh1, [outputDir sprintf('%s_%s_Trial-%i_NumMicrostates-%i',experientId,bandLabels{bndi},trli,numMicrostates)], 'png');
      close(fh1);
    end
  end
  clear 'dataBL';
end

%% Plot GEV
for trli=1:length(data.trial)
  figure, hold on;
  title('Template Quantity Selection');
  ylabel('GEV');
  xlabel('Number of Microstate Templates');
  hold on;
  for bndi=1:size(gev,1)
    ah = area(gev(bndi,:,trli), 'FaceColor', [0.5 0.5 0.5]);
    ph = plot(gev(bndi,:,trli),'o-', 'MarkerSize', 16, 'MarkerEdge', 'r', 'LineWidth', 2, 'Color', colors(bndi,:));
  end
  grid off;
  set(gca, 'XGrid', 'on');
  xlim([1 maxNumMicroStates]);
  set(gca,'XTick',1:maxNumMicroStates);
  %legend(bandLabels);
end