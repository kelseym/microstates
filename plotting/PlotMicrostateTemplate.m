%% Plot microstate topography using defined layout

% Given a fieldtrip style layout structure, plot a topo map using a 1xN
% array of sensor values

% This function compares the order of labels in the input data to the order
% in the layout file.  This allows data from input sensor X to be plotted in the
% location defined for sensor X in the layout structure.
function PlotMicrostateTemplate(microstateTemplate, inputSensorLabels, layout)

  [a,b] = match_str(layout.label, inputSensorLabels);
  layout.label{end-1} = '';
  ft_plot_lay(layout, 'box', 'off', 'label', 'no', 'point', 'no');
  ft_plot_topo(layout.pos(a,1),layout.pos(a,2),microstateTemplate(b),'gridscale',150,'outline',layout.outline,'mask',layout.mask,'interpmethod','nearest');
  axis off;
  abc = caxis;
  caxis([-1 1]*abc(2));

end

