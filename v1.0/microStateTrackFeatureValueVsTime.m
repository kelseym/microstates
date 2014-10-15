% Plot Microstate Features vs. Time

%     numChan{i} = length(data.label);
%     trialData{i} = data.trial{1};
%     trialTime{i} = data.time{1};
%     trialFreq{i} = data.fsample;
%     trialSize{i} = size(trialData{i},2);
%     trialSampleInfo{i} = data.sampleinfo;

% trialIndex cell array should contain an integer, for each trial, identifying the dominate sleep
% state in that segment. 0=wake, 2=N2, 3=SWS, 4=REM, -1=transition or unknown
function microStateTrackFeatureValueVsTime(trialData, trialSize, trialFreq, templateCorrelations, trialStageIndex)

    
%% Continuous MMD
windowLength = 10;
stepLength = 5;
for i=1:length(trialData)
    [cMMDmean{i}, cMMDstdDev{i}] = continuousMMD(trialSize{i}, trialFreq{i}, templateCorrelations{i}, windowLength, stepLength);
end



figure, hold on;
for i=1:length(trialData)
    plot(cMMDmean{i}*1000, cMMDstdDev{i}, '.', 'Color', lineColors(i,:));
end
title('Continuous MMD');
xlabel('Mean MMD (ms)');
ylabel('StdDev MMD');
legend(trialStageIndex);

end