function freqBands = GetFrequencyBands()

  freqBands.bands =       [1,50;  1,100;  1,4;    4,8;    8,15;   15,26;     26,35;     35,50;     50,76;      76,120];
  freqBands.bandLabels = {'1-50','1-100','Delta','Theta','Alpha','BetaLow', 'BetaHigh','GammaLow','GammaMid', 'GammaHigh'};

  if size(freqBands.bands,1) ~= length(freqBands.bandLabels)
    error('Frequency bands and labels do not match');
  end
end