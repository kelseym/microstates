% Concatenate trials in fieldtrip data structure end-to-end

function data = ConcatenateTrials(data)
  trialData{1} = data.trial{1};
  for trli=2:length(data.trial)
      trialData{1} = cat(2,trialData{1}, data.trial{trli});
  end
  data.sampleinfo = [0,size(trialData{1},2)];
  data.trial = trialData;
  data.time{1} = (data.sampleinfo(1):data.sampleinfo(2))/data.fsample;
end

