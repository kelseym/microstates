%% Plot per subject duration in ms

perSubjectClassLabels;
perSubjectFeatureValues;
subjects;

% plot colors
wakeColor = [0 0 1];
swsColor = [0 0.5 0];
n2Color = [1 0 0];
noiseColor = [0 0 0];

figure;
hold on;
ii = 0;
subjectLabels = {};
subjectLabelTickLoc = [];
for testSubi=1:length(subjects)
    % Subject to plot
    subjectLabels{end+1} = subjects{testSubi}.subjectLabel;
    % setup training data for analysis
    meas = [];
    labels = {};
    for trainSubi=1:length(subjects)
        if trainSubi == testSubi
            meas = cat(1, meas, perSubjectFeatureValues{trainSubi});
            labels = cat(2, labels, perSubjectClassLabels{trainSubi});
        end
    end
    % Grab first column of meas (this is microstate duration in seconds)
    duration = meas(:,1);
    subjectLabelTickLoc(end+1) = i/2 + ii;
    for i=1:length(labels)
      switch labels{i}
        case 'Wake'
          plot(i+ii,duration(i)*1000,' .','Color', wakeColor);
        case 'SWS'
          plot(i+ii,duration(i)*1000,' .','Color', swsColor);
        case 'N2'
          plot(i+ii,duration(i)*1000,' .','Color', n2Color);
        case 'Noise'
          plot(i+ii,duration(i)*1000,' .','Color', noiseColor);
        otherwise
          continue;
      end
      ll = length(labels) + ii;
      lh = plot([ll ll], [10 200],'k');
    end
    ii = length(labels) + ii;
end
xlim([0 ii]);
title('Microstate Duration');
ylabel('Microstate Duration (ms)');
set(gca, 'XTick', subjectLabelTickLoc);
set(gca, 'XTickLabel', subjectLabels);

