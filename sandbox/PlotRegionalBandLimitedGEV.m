%% plot GEV metrics generated using RegionalBandLimitedGEV.m

colors = lines(10);

% load and plot regions
cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);
load('4D248_labelROI.mat');
ft_plot_lay(lay);
ft_plot_topo(lay.pos(:,1),lay.pos(:,2),labelROI(:),'gridscale',150,'outline',lay.outline,'mask',lay.mask,'interpmethod','nearest');
axis off;
abc = caxis;
caxis([-1 1]*abc(2));

% plot gev curve set (all bands) for each region
for rgni=1:size(gev,2)-1
  figure;
  hold on;
  for bndi=1:size(gev,1)
    ph = plot(squeeze( gev(bndi,rgni+1,:) ), '-', 'Color', colors(bndi,:));
    if strfind(bandLabels{bndi},'Gamma')
      set(ph,'LineStyle','--');
    end
    if strfind(bandLabels{bndi},'Env')
      set(ph,'Marker','*');
    end
  end
  title(sprintf('Region %i GEV',rgni));
  xlabel('Number of Microstates');
  ylabel('GEV');
  set(gca,'XLim',[2 maxNumMicroStates]);
  set(gca,'YLim',[0 0.8]);
  legend(bandLabels,'Location','southeast');
  hold off;
end

% plot gev curve set (all regions) for each band
for bndi=1:size(gev,1)
  figure;
  hold on;
  for rgni=1:size(gev,2)-1
    ph = plot(squeeze( gev(bndi,rgni+1,:) ), '-', 'Color', colors(rgni,:));
    if rgni > 3
      set(ph,'Marker','o');
    end
    if rgni > 6
      set(ph,'Marker','*');
    end
  end
  title(sprintf('%s Band GEV',bandLabels{bndi}));
  xlabel('Number of Microstates');
  ylabel('GEV');
  set(gca,'XLim',[2 maxNumMicroStates]);
  set(gca,'YLim',[0 0.8]);
  legend({'R1','R2','R3','R4','R5','R6','R7','R8','R9'},'Location','southeast');
  hold off;
end


% plot gevArea dim:bndi_rgni (grouped by band)
figure;
bh = bar(gevArea(:,2:10));
title('GEV AUC - Grouped by Band')
set(gca,'XTickLabel',bandLabels);
legend(bh,{'R1','R2','R3','R4','R5','R6','R7','R8','R9'});

% plot gevArea dim:bndi_rgni (grouped by region)
figure;
bh = bar(gevArea(:,2:10)');
title('GEV AUC - Grouped by Region')
set(gca,'XTickLabel',{'R1','R2','R3','R4','R5','R6','R7','R8','R9'});
legend(bh,bandLabels);


% plot maxExVar dim:bndi_rgni (grouped by band)
figure;
bh = bar(maxExVar(:,2:10));
title('Maximum Explained Variance - Grouped by Band')
set(gca,'XTickLabel',bandLabels);
legend(bh,{'R1','R2','R3','R4','R5','R6','R7','R8','R9'});

% plot maxExVar dim:bndi_rgni (grouped by region)
figure;
bh = bar(maxExVar(:,2:10)');
title('Maximum Explained Variance - Grouped by Region')
set(gca,'XTickLabel',{'R1','R2','R3','R4','R5','R6','R7','R8','R9'});
legend(bh,bandLabels);


