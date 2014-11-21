%% Plot 

function fh = PlotFeatureXY(data, f1Name, f2Name, plotTitle)
  
  % find feature label indices
  f1Indx = [];
  f2Indx = [];
  for i=1:length(data.featurelabels)
    if strcmp(data.featurelabels{i}, f1Name)
      f1Indx=i;
    elseif strcmp(data.featurelabels{i}, f2Name)
      f2Indx=i;
    end
  end
  
  % Check to be sure data contains values for requested features
  if isempty(f1Indx) || isempty(f2Indx) || f1Indx>length(data.featurevalues) || f2Indx>length(data.featurevalues)
    error('Requested feature label not available in data.');
  end
  
  f1Data = data.featurevalues{f1Indx};
  f2Data = data.featurevalues{f2Indx};
  
  fh = figure;
  plot(f1Data, f2Data,'.k');
  xlabel(f1Name);
  ylabel(f2Name);
  title(plotTitle);
  
end

