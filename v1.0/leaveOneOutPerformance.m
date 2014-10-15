%% Leave one out cross validation
%   Perform subject-wise cross validation on microstate feature set


perSubjectClassLabels;
perSubjectFeatureValues;
subjects;

overallCorrect = 0;
overallTested = 0
for testSubi=1:length(subjects)
    % Subject to test
    subjectLabel = subjects{testSubi}.subjectLabel;
    
    % setup training data for analysis
    meas = [];
    labels = {};
    for trainSubi=1:length(subjects)
        if trainSubi ~= testSubi
            meas = cat(1, meas, perSubjectFeatureValues{trainSubi});
            labels = cat(2, labels, perSubjectClassLabels{trainSubi});
        end
    end
    
    % train a quadratic classifier
    quadclass = ClassificationDiscriminant.fit(meas,labels, 'discrimType','quadratic');
   
    % test performance
    testMeas = perSubjectFeatureValues{testSubi};
    predictedLabels = cell(size(testMeas,1),1);
    for testi=1:size(testMeas,1)
        testSample = testMeas(testi,:);
        predictedLabels{testi} = predict(quadclass,testSample);
    end
    
    totalTested = 0;
    totalCorrect = 0;
    testLabels = perSubjectClassLabels{testSubi};
    for tli=1:length(testLabels)
        totalTested = 1+ totalTested;
        if strcmp(testLabels{tli}, predictedLabels{tli})
            totalCorrect = 1 + totalCorrect;
        end
    end
    disp(sprintf('%i Class LOO %s - %2.1f%% Correct -- %i Tested, %i Correct', length(unique(testLabels)), subjectLabel, totalCorrect/totalTested*100, totalTested, totalCorrect));
    overallTested = overallTested + totalTested;
    overallCorrect = overallCorrect + totalCorrect;
end

disp(sprintf('%i Class LOO - %2.1f%% Correct -- %i Tested, %i Correct', length(unique(testLabels)), overallCorrect/overallTested*100, overallTested, overallCorrect));
