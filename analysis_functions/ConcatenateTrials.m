% Concatenate trials in fieldtrip data structure end-to-end

function dataout = ConcatenateTrials(datain)
  trialData{1} = datain.trial{1};
  for trli=2:length(datain.trial)
      trialData{1} = cat(2,trialData{1}, datain.trial{trli});
  end
  dataout = datain;
  dataout.sampleinfo = [0,size(trialData{1},2)];
  dataout.trial = trialData;
  dataout.time{1} = (dataout.sampleinfo(1):dataout.sampleinfo(2))/dataout.fsample;
  if isfield(datain, 'microstateIndices') && length(datain.microstateIndices) > 1
    concatMicrostateIndices = datain.microstateIndices{1};
    for i=2:length(datain.microstateIndices)
      concatMicrostateIndices = cat(2, concatMicrostateIndices, datain.microstateIndices{i});
    end
    dataout.microstateIndices = {concatMicrostateIndices};
  end
end

