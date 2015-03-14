%% load, analyze and plot GEV metrics generated using RegionalBandLimitedGEV.m
clear;

dataDir = GetLocalOutputDirectory();

bands = [];
for bandEnd=5:5:120;
  bands(end+1,:) = [1, bandEnd];
end
bandLabels = {};
for bndi=1:size(bands,1)
  band = bands(bndi,:);
  bandLabels{end+1}=sprintf('%i-%iHz',band(1),band(2));
end

trialLength = 240;


experimentids = {'105923_MEG_3-Restin', ...
'106521_MEG_3-Restin', ...
'109123_MEG_3-Restin', ...
'114823_MEG_3-Restin', ...
'153732_MEG_3-Restin', ...
'166438_MEG_3-Restin', ...
'172029_MEG_3-Restin', ...
'185442_MEG_3-Restin', ...
'189349_MEG_3-Restin', ...
'205119_MEG_3-Restin', ...
'255639_MEG_3-Restin', ...
'287248_MEG_3-Restin', ...
'559053_MEG_3-Restin', ...
'568963_MEG_3-Restin', ...
'601127_MEG_3-Restin', ...
'660951_MEG_3-Restin', ...
'665254_MEG_3-Restin', ...
'715950_MEG_3-Restin', ...
'820745_MEG_3-Restin', ...
'912447_MEG_3-Restin'};

colors = lines(10);

% average statistics across all subjects
avgOrderedGev = [];
avgOrderedGevArea = [];
avgOrderedMaxExVar = [];


for exprmntdi=1:length(experimentids)
  experimentid = experimentids{exprmntdi};
  
  orderedBandLabels={};
  orderedGev = [];
  orderedGevArea = [];
  orderedMaxExVar = [];

  % load matching data files
  for bndi=1:length(bandLabels)  
    matDataFile = dir([dataDir sprintf('*%s*_BandLimitedGEV*%s*%iSecTrial*.mat',experimentid,bandLabels{bndi},trialLength)]);
    if length(matDataFile) >1
      error('Mutiple matches found for *%s*_BandLimitedGEV*%s*%iSecTrial*.mat in %s\nExiting early.',experimentid,bandLabels{bndi},trialLength,dataDir);
    elseif isempty(matDataFile)
      fprintf('No file found matching *%s*_BandLimitedGEV*%s*%iSecTrial*.mat in %s',experimentid,bandLabels{bndi},trialLength,dataDir);
      continue;
    else
      load([dataDir matDataFile.name])
      orderedBandLabels{end+1} = bandLabels{bndi};
      orderedGev(end+1,:) = mean(gev,3);
      orderedGevArea(end+1) = mean(gevArea,2);
      orderedMaxExVar(end+1) = mean(maxExVar,2);
      clear 'gev' 'gevArea' 'maxExVar';
    end
  end
  
  if exprmntdi == 1
    avgOrderedGev = orderedGev; 
    avgOrderedGevArea = orderedGevArea;
    avgOrderedMaxExVar = orderedMaxExVar;
  else
    avgOrderedGev = avgOrderedGev + orderedGev; 
    avgOrderedGevArea = avgOrderedGevArea + orderedGevArea;
    avgOrderedMaxExVar = avgOrderedMaxExVar + orderedMaxExVar;
  end

  
  % plot gev statistics 

  % plot gevArea dim:bndi_rgni (grouped by region)
  figure;
  bh = bar(orderedGevArea(:,:)');
  title(sprintf('GEV AUC - %i sec trial',trialLength));
  set(gca,'XTick',1:length(bandLabels));
  set(gca,'XTickLabel',bandLabels);
  legend(bh,orderedBandLabels);

  % plot maxExVar dim:bndi_rgni (grouped by region)
  figure;
  bh = bar(orderedMaxExVar(:,:)');
  title(sprintf('Maximum Explained Variance - %i sec trial',trialLength));
  set(gca,'XTickLabel',bandLabels);
  set(gca,'XTickLabel',bandLabels);
  legend(bh,orderedBandLabels);

end

avgOrderedGev = avgOrderedGev/length(bandLabels); 
avgOrderedGevArea = avgOrderedGevArea/length(bandLabels);
avgOrderedMaxExVar = avgOrderedMaxExVar/length(bandLabels);


% plot gevArea dim:bndi_rgni (grouped by region)
figure;
bh = bar(orderedGevArea(:,:)');
title(sprintf('Population GEV AUC - Grouped by Region - %i sec trial',trialLength));
set(gca,'XTickLabel',bandLabels);
set(gca,'XTickLabel',bandLabels);
legend(bh,orderedBandLabels);

% plot maxExVar dim:bndi_rgni (grouped by region)
figure;
bh = bar(orderedMaxExVar(:,:)');
title(sprintf('Population Maximum Explained Variance - Grouped by Region - %i sec trial',trialLength));
set(gca,'XTickLabel',bandLabels);
set(gca,'XTickLabel',bandLabels);
legend(bh,orderedBandLabels);








% 
% % plot gevArea dim:bndi_rgni (grouped by band)
% figure;
% bh = bar(gevArea(:,2:10));
% title('GEV AUC - Grouped by Band')
% set(gca,'XTickLabel',bandLabels);
% legend(bh,{'R1','R2','R3','R4','R5','R6','R7','R8','R9'});

% 
% 
% % plot maxExVar dim:bndi_rgni (grouped by band)
% figure;
% bh = bar(maxExVar(:,2:10));
% title('Maximum Explained Variance - Grouped by Band')
% set(gca,'XTickLabel',bandLabels);
% legend(bh,{'R1','R2','R3','R4','R5','R6','R7','R8','R9'});




% 
% % plot gev curve set (all bands) for each region
% for rgni=1:size(gev,2)-1
%   figure;
%   hold on;
%   for bndi=1:size(gev,1)
%     ph = plot(squeeze( gev(bndi,rgni+1,:) ), '-', 'Color', colors(bndi,:));
%     if strfind(bandLabels{bndi},'Gamma')
%       set(ph,'LineStyle','--');
%     end
%     if strfind(bandLabels{bndi},'Env')
%       set(ph,'Marker','*');
%     end
%   end
%   title(sprintf('Region %i GEV',rgni));
%   xlabel('Number of Microstates');
%   ylabel('GEV');
%   set(gca,'XLim',[2 maxNumMicroStates]);
%   set(gca,'YLim',[0 0.8]);
%   legend(bandLabels,'Location','southeast');
%   hold off;
% end
% 
% % plot gev curve set (all regions) for each band
% for bndi=1:size(gev,1)
%   figure;
%   hold on;
%   for rgni=1:size(gev,2)-1
%     ph = plot(squeeze( gev(bndi,rgni+1,:) ), '-', 'Color', colors(rgni,:));
%     if rgni > 3
%       set(ph,'Marker','o');
%     end
%     if rgni > 6
%       set(ph,'Marker','*');
%     end
%   end
%   title(sprintf('%s Band GEV',bandLabels{bndi}));
%   xlabel('Number of Microstates');
%   ylabel('GEV');
%   set(gca,'XLim',[2 maxNumMicroStates]);
%   set(gca,'YLim',[0 0.8]);
%   legend({'R1','R2','R3','R4','R5','R6','R7','R8','R9'},'Location','southeast');
%   hold off;
% end

