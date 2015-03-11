%% load, analyze and plot GEV metrics generated using RegionalBandLimitedGEV.m
clear;

dataDir = GetLocalOutputDirectory();

bands =       [1,35;       1,120;    4,10;        35,50;     50,76;      76,120];
bandLabels = {'Broadband','Fullband','ThetaAlpha','GammaLow','GammaMid', 'GammaHigh'};

trialLength = 240;

experimentid = '105923_MEG_3-Restin';

colors = lines(10);

orderedBandLabels={};
orderedGev = [];
orderedGevArea = [];
orderedMaxExVar = [];

% load matching data files
for bndi=1:length(bandLabels)  
  matDataFile = dir([dataDir sprintf('*%s*RegionalBandLimitedGEV*%s*%iSecTrial*.mat',experimentid,bandLabels{bndi},trialLength)]);
  if length(matDataFile) >1
    error('Mutiple matches found for *%s*RegionalBandLimitedGEV*%s*%iSecTrial*.mat in %s\nExiting early.',experimentid,bandLabels{bndi},trialLength,dataDir);
  elseif isempty(matDataFile)
    fprintf('No file found matching *%s*RegionalBandLimitedGEV*%s*%iSecTrial*.mat in %s',experimentid,bandLabels{bndi},trialLength,dataDir);
  else
    load([dataDir matDataFile.name])
    orderedBandLabels{end+1} = bandLabels{bndi};
    orderedGev(end+1,:,:) = gev;
    orderedGevArea(end+1,:) = gevArea;
    orderedMaxExVar(end+1,:) = maxExVar;
    clear 'gev' 'gevArea' 'maxExVar';
  end
end


% load 9 region sensor map
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
load('4D248_labelROI.mat');
regionLabels = {'R1','R2','R3','R4','R5','R6','R7','R8','R9'};

% plot gev statistics 

% plot gevArea dim:bndi_rgni (grouped by region)
figure;
bh = bar(orderedGevArea(:,:)');
title('GEV AUC - Grouped by Region')
set(gca,'XTickLabel',regionLabels);
legend(bh,orderedBandLabels);

% plot maxExVar dim:bndi_rgni (grouped by region)
figure;
bh = bar(orderedMaxExVar(:,:)');
title('Maximum Explained Variance - Grouped by Region')
set(gca,'XTickLabel',regionLabels);
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

