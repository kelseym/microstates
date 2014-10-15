% Compute GFP and peaks
%  Optionally, ignore peaks within N std dev of the mean within some window centered at each peak
%   Use windowLength of ~ or 0 to report all peaks
function [gfp, gfpPkLocs] = locateGfpPeaks(dataMatrix, windowLength, stdDevFactor)
  numChan = size(dataMatrix,2);
  dataSize = size(dataMatrix,2);

  %% GFP calculation
  gfp = sqrt(sum(dataMatrix.^2,1)/numChan);

  %% Find local maxima
  [gfpPks, gfpPkLocs] = findpeaks(gfp,'MINPEAKDISTANCE',3);
  if exist('windowLength', 'var') && windowLength > 0
    % Report only peaks greater than N std dev from the mean (in sliding window about peak under consideration)
    %  computed over a N second sliding window at M second intervals
    windowSize = windowLength*data.fsample;
    bigPksLoc = [];
    for pki=1:length(gfpPks)
      wndwStrtIdx = gfpPkLocs(pki)+1-round(windowSize/2);
      if wndwStrtIdx < 1
        wndwStrtIdx = 1;
      end
      wndwStpIdx = wndwStrtIdx + windowSize-1;
      if wndwStpIdx > dataSize
        wndwStpIdx  = dataSize;
      end
      mGfp = mean(gfp(int32(wndwStrtIdx):int32(wndwStpIdx)));
      stdGfp = std(gfp(int32(wndwStrtIdx):int32(wndwStpIdx)));
      if gfpPks(pki) > (mGfp+(stdGfp*stdDevFactor))
        bigPksLoc(end+1) = gfpPkLocs(pki);
      end
    end
    gfpPkLocs = bigPksLoc;
  end

end