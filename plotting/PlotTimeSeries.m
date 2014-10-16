%% Plot time series data from startS seconds to endS seconds
%  Return figure handle

function fh = PlotTimeSeries(data, startS, endS, plotTitle)

  pltSmpls = startS*data.fsample:endS*data.fsample;
  pltSmpls = floor(pltSmpls)+1;
  fh = figure;
  title(plotTitle);
  xlabel('Seconds');
  ylabel('Sensor Potential');
  set(gca, 'YTickLabel', '');
  hold on;
  dataRaw = data.trial{1}(:,pltSmpls);
  mx = max(max(dataRaw));
  mn = min(min(dataRaw));
  dataRaw = dataRaw-mn;
  dataRaw = dataRaw/(mx-mn)*1.3;
  for j=1:size(dataRaw,1)
      plot(data.time{1}(pltSmpls), dataRaw(j,:)+j, 'k');
  end

end