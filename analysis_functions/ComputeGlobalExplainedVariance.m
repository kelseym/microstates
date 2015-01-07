%% Compute global explained variance per microstate template specified in the NxS matrix microstateTemplates
%  where N is the number of microstate templates and S is the number of sensors

function gevk = ComputeGlobalExplainedVariance(microstateTemplates, dataMatrix)
  % Compute correlation between templates and original signal
  templateCorrelations = zeros(size(microstateTemplates,1),size(dataMatrix,2));
  for tmpltj=1:size(microstateTemplates,1)
      template = microstateTemplates(tmpltj,:)';
      templateCorrelations(tmpltj,:) = abs(corr(template,dataMatrix(:,:)));
  end
  [~, maxCorrTemplIdx] = max(templateCorrelations,[],1);

  % GEV per template
  [gfp, gfpPkLocs] = LocateGfpPeaks(dataMatrix);

  numMicrostates = size(microstateTemplates,1);
  gevk = zeros(numMicrostates,1);
  gfpPeakMask = zeros(size(maxCorrTemplIdx));
  gfpPeakMask(gfpPkLocs) = 1;
  maxCorrTemplIdx = gfpPeakMask.*maxCorrTemplIdx;
  for msi=1:numMicrostates
      templateMatchMask = maxCorrTemplIdx == msi;
      prod = gfp(templateMatchMask).*templateCorrelations(msi,templateMatchMask);
      numer = sumsqr(prod);
      denom = sumsqr(gfp(find(gfpPeakMask)));
      gevk(msi) = numer/denom;
  end
end

