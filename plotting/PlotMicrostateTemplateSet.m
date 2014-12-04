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
  numRows = 1;
  if numSubPlots > 4
    numRows = ceil(numSubPlots/4);
  end
  layout.label{end-1} = '';
  for ti=1:size(microstateTemplates,1)
    subplot(numRows,min(4,numSubPlots),ti);
    microstateTemplate = microstateTemplates(ti,:);
    PlotMicrostateTemplate(microstateTemplate, inputSensorLabels, layout);
  end
  %title(figureTitle,'Interpreter','none');
  hold off;
end

