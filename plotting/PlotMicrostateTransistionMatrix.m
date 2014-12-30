%% Plot microstate topography set with corresponding transistion matrix


function fh = PlotMicrostateTransistionMatrix(microstateTemplates, inputSensorLabels, layout, transistionMatrix)

  numTemplates = size(microstateTemplates,1);
  fh = figure;
  
  % plot microstate topography set along edges
  for msi=1:numTemplates
    subplot(numTemplates+1, numTemplates+1,msi+1);
    PlotMicrostateTemplate(microstateTemplates(msi,:), inputSensorLabels, layout);
    subplot(numTemplates+1, numTemplates+1,(msi*(numTemplates+1))+1);
    PlotMicrostateTemplate(microstateTemplates(msi,:), inputSensorLabels, layout);
  end
  
  % plot transistion matrix
  axisIndices=[];
  for msi=1:numTemplates
    axisIndices = [axisIndices, [(msi*(numTemplates+1))+2:((msi+1)*(numTemplates+1))]];
  end
  subplot(numTemplates+1, numTemplates+1,axisIndices);
  normTransistionMatrix = transistionMatrix/max(max(transistionMatrix));
  imagesc(normTransistionMatrix);
  axis off;
end

