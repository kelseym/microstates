%% Plot microstate topography set in subplot
%  Read from microstateTemplates matrix, where each row defines values for
%  a template
%  Reture figure handle

% Given a fieldtrip style layout structure, plot a topo map using a 1xN
% array of sensor values

% This function compares the order of labels in the input data to the order
% in the layout file.  This allows data from input sensor X to be plotted in the
% location defined for sensor X in the layout structure.
function fh = PlotMicrostateTemplateSet(microstateTemplates, inputSensorLabels, layout, figureTitle )

  [a,b] = match_str(layout.label, inputSensorLabels);
  fh = figure('name', figureTitle);
  hold on;
  numSubPlots = size(microstateTemplates,1);
  layout.label{end-1} = '';
  for ti=1:size(microstateTemplates,1)
    subplot(ceil(numSubPlots/2),floor(numSubPlots/2),ti);
    microstateTemplate = microstateTemplates(ti,:);
    ft_plot_lay(layout, 'box', 'off', 'label', 'no', 'point', 'no');
    ft_plot_topo(layout.pos(a,1),layout.pos(a,2),microstateTemplate(b),'gridscale',150,'outline',layout.outline,'mask',layout.mask,'interpmethod','nearest');
%    axis([-0.6 0.6 -0.6 0.6]);
    axis off;
    abc = caxis;
    caxis([-1 1]*abc(2));
  end
  %title(figureTitle,'Interpreter','none');

end

