%% runPerSubjectMicrostateAnalysis.m
clear;
%function runPerSubjectMicrostateAnalysis()

% if matlabpool('size') <= 1
%     matlabpool open
% end

showNSecPlots = 0;
lineColors = lines;close;

% filenames = {'C:\Projects\EON\R21Dev\McD03_wake_1726-173.edf',...
%             'C:\Projects\EON\R21Dev\McD03_SWS_0113-0118.EDF',...
%             'C:\Projects\EON\R21Dev\McD03_N2_0057-0102.EDF'};
% subjectLabel = 'McD03';
% trialLabels = {'Wake',...
%               'SWS',...
%               'N2'};
% sensorList = 1:32;
subjects = getMcDFileNamesNew();

perSubjectFeatureValues = {};
perSubjectClassLabels = {};
for subi=1:length(subjects)
    subject = subjects{subi};
    filenames = subject.filenames;
    subjectLabel = subject.subjectLabel;
    trialLabels = subject.trialLabels;
    sensorList = subject.sensorList;

    
    %% Extract features from trial data
    for i=1:length(trialLabels)
        %% Open and preprocess data files
        filename = filenames{i};
        trialLabel = trialLabels{i};
        [trialData, trialSize, trialFreq, numChan] = openAndPreprocess(filename, sensorList);

%         %% Optionally replace real data with white noise
%         trialData = generateWhiteNoise(trialData, [1.0 40.0], trialFreq);

        %% Extract GFP and template correlation stream
        [~, gfpPkLocs, templateCorrelations] = extractTemplateCorrelationStream(trialData, trialSize, trialFreq, numChan);

        %% Extract features from GFP peaks and template stream
        [cMMDmean{i}, cMMDstdDev{i}, gfpMMDmean{i}, gfpMMDstdDev{i}, gfpPeaksPerSecond{i}, stdDevPeakRate{i}, stateDom{i}, stdDevTemplateCoverage{i}] = ...
            extractMicrostateFeatures(trialSize, trialFreq, gfpPkLocs, templateCorrelations);

    end

    %% Feature analysis
    classes = {};
    for i=1:length(trialLabels)
        features = [];
        featureLabels = {};
        features(end+1,:) = cMMDmean{i}(1,:);
        featureLabels{end+1} = 'cMMDmean';
        features(end+1,:) = cMMDstdDev{i}(1,:);
        featureLabels{end+1} = 'cMMDstdDev';
        features(end+1,:) = gfpMMDmean{i}(1,:);
        featureLabels{end+1} = 'gfpMMDmean';
        features(end+1,:) = gfpMMDstdDev{i}(1,:);
        featureLabels{end+1} = 'gfpMMDstdDev';
        features(end+1,:) = gfpPeaksPerSecond{i}(1,:);
        featureLabels{end+1} = 'gfpPeaksPerSecond';
        features(end+1,:) = stdDevPeakRate{i}(1,:);
        featureLabels{end+1} = 'stdDevPeakRate';
        features(end+1,:) = stdDevTemplateCoverage{i}(1,:);
        featureLabels{end+1} = 'stdDevTemplateCoverage';
        features(end+1,:) = stateDom{i}(1,:);
        featureLabels{end+1} = 'stateDom';
        class.features = features;
        class.featureLabels = featureLabels;
        classes{end+1} = class;
    end
    
    % setup data for analysis
    meas = [];
    labels = {};
    for i=1:length(trialLabels)
        meas = cat(1, meas, classes{i}.features');
        for li=(size(labels,2)+1):size(meas,1)
            labels{li} = trialLabels{i};
        end
    end
    % test using a quadratic classifier
%     quadclass = ClassificationDiscriminant.fit(meas,labels, 'discrimType','quadratic');
%     for i=1:size(meas,1)
%         testSample = meas(i,:);
%         predictedLabels{i} = predict(quadclass,testSample);
%     end
    % Cross validataion classifier
    quadclass = ClassificationDiscriminant.fit(meas,labels, 'discrimType','quadratic','KFold',30);
    predictedLabels = kfoldPredict(quadclass);
    
    perSubjectFeatureValues{end+1} = meas;
    perSubjectClassLabels{end+1} = labels;
    
    % Test performance
    disp(sprintf('%s Classifier Performance', subjectLabel));
    totalTested = 0;
    totalCorrect = 0;
    for i=1:length(trialLabels)
        trainingLabel = trialLabels{i};
        nTested = 0;
        nCorrect = 0;
        for tli=1:length(labels)
            if strcmp(trainingLabel, labels{tli})
                nTested = 1+ nTested;
                if strcmp(trainingLabel, predictedLabels{tli})
                    nCorrect = 1 + nCorrect;
                end
            end
        end
        disp(sprintf('%s - %2.1f%% Correct -- %i Tested, %i Correct', trainingLabel, nCorrect/nTested*100, nTested, nCorrect));
        totalTested = totalTested + nTested;
        totalCorrect = totalCorrect + nCorrect;
    end
    disp(sprintf('Overall - %2.1f%% Correct -- %i Tested, %i Correct', totalCorrect/totalTested*100, totalTested, totalCorrect));
    overallPerformance(subi) = totalCorrect/totalTested;
    
%     %% Plot feature pairs
%     figure, hold on;
%     for i=1:length(trialLabels)
%         plot(gfpPeaksPerSecond{i}(1,:), stdDevPeakRate{i}(1,:), '.', 'Color', lineColors(i,:));
%     end
%     title([subjectLabel ' - GFP Peak Rate']);
%     xlabel('GFP Peaks per Second');
%     ylabel('StdDev of Peak Rate');
%     legend(trialLabels);
% 
%     figure, hold on;
%     for i=1:length(trialLabels)
%         plot(cMMDmean{i}(1,:), cMMDstdDev{i}(1,:), '.', 'Color', lineColors(i,:));
%     end
%     title([subjectLabel ' - Microstate Duration']);
%     xlabel('Mean Duration');
%     ylabel('StdDev Duration');
%     legend(trialLabels);
% 
%     figure, hold on;
%     for i=1:length(trialLabels)
%         plot(gfpMMDmean{i}(1,:), gfpMMDstdDev{i}(1,:), '.', 'Color', lineColors(i,:));
%     end
%     title([subjectLabel ' - GFP Peak Duration']);
%     xlabel('Mean GFP Peak Duration');
%     ylabel('StdDev GFP Peak Duration');
%     legend(trialLabels);
% 
%     figure, hold on;
%     for i=1:length(trialLabels)
%         plot(cMMDmean{i}(1,:), stateDom{i}(1,:), '.', 'Color', lineColors(i,:));
%     end
%     title([subjectLabel ' - Microstate Dominance']);
%     xlabel('Mean Duration');
%     ylabel('State Dominance');
%     legend(trialLabels);
%     
%     
%     close all

end


disp(sprintf('\nOverall Performance- %2.1f%% Correct', mean(overallPerformance)*100));




