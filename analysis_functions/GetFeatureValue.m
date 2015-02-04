function value = GetFeatureValue(data, featureLabel)

  % find feature label indices
  f1Indx = [];
  for i=1:length(data.featurelabels)
    if strcmp(data.featurelabels{i}, featureLabel)
      f1Indx=i;
    end
  end
  
  % Check to be sure data contains values for requested features
  if isempty(f1Indx)  || f1Indx>length(data.featurevalues) 
    error('Requested feature label not available in data.');
  end
  
  value = data.featurevalues{f1Indx};
  