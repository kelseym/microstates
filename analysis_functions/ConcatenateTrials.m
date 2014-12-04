% Concatenate trials in fieldtrip data structure end-to-end

function data = ConcatenateTrials(data)
  trialData{1} = data.trial{1};
  for trli=2:length(data.trial)
      trialData{1} = cat(2,trialData{1}, data.trial{trli});
  end
  data.sampleinfo = [0,size(trialData{1},2)];
  data.trial = trialData;
  data.time{1} = (data.sampleinfo(1):data.sampleinfo(2))/data.fsample;
  if isfield(data, 'microstateIndices') && length(data.microstateIndices) > 1
    concatMicrostateIndices = data.microstateIndices{1};
    for i=2:length(data.microstateIndices)
      concatMicrostateIndices = cat(2, concatMicrostateIndices, data.microstateIndices{i});
    end
    data.microstateIndices = {concatMicrostateIndices};
  end
end

