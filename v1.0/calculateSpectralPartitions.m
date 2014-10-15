% Compute min-squared-error spectral partition using N connected straight line segments
% Fit error and endpoint selection can be based on all timeInts & channels - this assigned identical endpoints to all timeInt and channel samples
% or can be calculated for each indivudulally using some neighborhood of timeInt and channels
% Report component line segment slopes and fit error
function ft_slopes = calculateSpectralPartitions(ft_pxx, cfg)

% the ft_preamble function works by calling a number of scripts from
% fieldtrip/utility/private that are able to modify the local workspace
ft_defaults                 % this ensures that the path is correct and that the ft_defaults global variable is available
ft_preamble init            % this will reset warning_once and show the function help if nargin==0 and return an error
ft_preamble provenance      % this records the time and memory usage at the beginning of the function
ft_preamble trackconfig     % this converts the cfg structure in a config object, which tracks the cfg options that are being used
ft_preamble debug           % this allows for displaying or saving the function name and input arguments upon an error
ft_preamble loadvar datain  % this reads the input data in case the user specified the cfg.inputfile option


% Check for necissary ft_pxx components
if ~any(strcmp('fitFreq',fieldnames(ft_pxx))); error('pxx missing fitFreq'); end
if ~any(strcmp('freqEndpoints',fieldnames(ft_pxx))); error('pxx missing freqEndpoints'); end
if ~any(strcmp('detailedSlopes',fieldnames(ft_pxx))); error('pxx missing detailedSlopes'); end
if ~any(strcmp('detailedSlopesDimOrder',fieldnames(ft_pxx))); error('pxx missing detailedSlopesDimOrder'); end
if ~any(strcmp('detailedSlopesStatDimOrder',fieldnames(ft_pxx))); error('pxx missing detailedSlopesStatDimOrder'); end


% Check for required input
% ensure that the required options are present
cfg = ft_checkconfig(cfg, 'required', {'numSegments'});
cfg = ft_checkconfig(cfg, 'required', {'numTimeIntNeighbors'});

% ensure that the options are valid
cfg = ft_checkopt(cfg, 'numSegments', 'double');
cfg = ft_checkopt(cfg, 'numTimeIntNeighbors', 'double');
cfg = ft_checkopt(cfg, 'channelNeighborhood', 'char', {'all', 'grid','individual'});

% get the options
channelNeighborhood = ft_getopt(cfg, 'channelNeighborhood', 'all');   % the default is 'all'
numTimeIntNeighbors = ft_getopt(cfg, 'numTimeIntNeighbors', 1);   % the default is 1
numSegments   = ft_getopt(cfg, 'numSegments', 1);     % the default is 1


[numTimeInts, numChannels, ~, ~] = size(ft_pxx.detailedSlopes);
% check that the number of time neighbors doesn't excEed the number available
if numTimeIntNeighbors>=numTimeInts
    error('numTimeIntNeighbors: %i exceeds available number of neighbors: %i',numTimeIntNeighbors,numTimeInts);
end

% % Define channel index sets according to requested neighborhoods
channelGroups = {};
if strcmp(channelNeighborhood,'all')
    % single group containing all channels
    channelGroups = {1:numChannels};
elseif strcmp(channelNeighborhood,'individual')
    % separate group for each channel
    channelGroups = num2cell(1:numChannels);
else
%FIXME: Implement 'grid' channel groups 
    error('%s channel neighborhood not supported.',channelNeighborhood);
end
numChannelGroups = length(channelGroups);

%% Compute all possible spectrum partitioning schemes, endpoints and corresponding indicies in fitFreq
%  Store in cell array of scheme structs
numFreqEndpoints = size(ft_pxx.freqEndpoints,2);
segmentEndpoints = find_segment_endpoints(numSegments, numFreqEndpoints, 1);
numEndpointSchemes = size(segmentEndpoints,1);
allSchemes = cell(numEndpointSchemes,1);
for schemeIndex=1:numEndpointSchemes
    partitionScheme.schemeIndex = schemeIndex;
    partitionScheme.endpointScheme = segmentEndpoints(schemeIndex,:);
    partitionScheme.fitFreqIndices = zeros(size(segmentEndpoints,2)-1,1);
    for endpointIndex=1:(size(segmentEndpoints,2)-1)
        startFreqIndex = partitionScheme.endpointScheme(endpointIndex);
        stopFreqIndex = partitionScheme.endpointScheme(endpointIndex+1);
        startFreq = ft_pxx.freqEndpoints(startFreqIndex);
        stopFreq = ft_pxx.freqEndpoints(stopFreqIndex);
        partitionScheme.fitFreqIndices(endpointIndex) = find(ft_pxx.fitFreq(:,1) == startFreq & ft_pxx.fitFreq(:,2) == stopFreq);
    end
    allSchemes{schemeIndex} = partitionScheme;
end

%% Find minimum error scheme for each time interval and channel
%  For each channel and time interval compute and store the partitioning scheme that results in the 
%  minimum N segment line fit error.  Optimal scheme endpoint selection can be based on
%  individual timeInt/channel or some set of temporal and spacial neighbors.  The default
%  is to use all channels and time intervals.

% Store minErrorSchemeFitDetails in TxC cell array
allMinErrorSchemeFitDetails = cell(numChannelGroups, numTimeInts);
parfor curTimeInt = 1:numTimeInts
    for curChanGroup = 1:numChannelGroups
        % Define temporal neighbors - use current plus "numTimeIntNeighbors" previous intervals
        timeNeighborhoodOffsets = [0 -1:-1:-numTimeIntNeighbors]; 
        timeNeighborhoodIndices = fliplr(curTimeInt+timeNeighborhoodOffsets);
        %  if there are not enough pre-intervals, use post-intervals
        if min(timeNeighborhoodIndices) < 1
            timeNeighborhoodIndices = timeNeighborhoodIndices+1-min(timeNeighborhoodIndices);
        end

        % Select channel neighborhood to be used in endpoint calculation
        channelNeighborhoodIndices = channelGroups{curChanGroup};

        % Compute segment line slopes and average fit error per scheme.
        allLocalSchemeFitDetails = struct;
        allLocalSchemeFitError = zeros(length(allSchemes),1);
        for schemeIndex=1:length(allSchemes);
            partitionScheme = allSchemes{schemeIndex};
            endpointScheme = partitionScheme.endpointScheme;
            fitFreqIndices = partitionScheme.fitFreqIndices;
            %
            % Compute mean average of scheme segments across channels and intervals
            %
            segSlopeAvgs = zeros(size(fitFreqIndices,1),1);
            avgDeltaErrors = zeros(size(fitFreqIndices,1),1);
            for freqIndex=1:size(fitFreqIndices,1)
               slopeSum = 0;
               deltaSum = 0;
               for c=channelNeighborhoodIndices
                   for t=timeNeighborhoodIndices
                       slopeSum = slopeSum + ft_pxx.detailedSlopes(t,c,fitFreqIndices(freqIndex),1); % 1 is the index of slope within details
                       deltaSum = deltaSum + abs(ft_pxx.detailedSlopes(t,c,fitFreqIndices(freqIndex),3)); % 3 is the index of delta within details
                   end
               end
                slopeAvg = slopeSum/(length(timeNeighborhoodIndices)*length(channelNeighborhoodIndices));
                segSlopeAvgs(freqIndex) = slopeAvg;
               % compute mean delta error
               avgDeltaErrors(freqIndex) = deltaSum/(length(timeNeighborhoodIndices)*length(channelNeighborhoodIndices));
            end
            allLocalSchemeFitDetails(schemeIndex).segSlopeAvgs = segSlopeAvgs;
            %
            % Compute weighted sum of polyfit delta error across segments in each scheme
            %
            polyfitDeltaError = 0;
            for endpointIndex=1:size(endpointScheme,2)-1
                % weight error based on interval
                intervalLength = abs(endpointScheme(endpointIndex+1)-endpointScheme(endpointIndex));
                segmentWeight = intervalLength/(numFreqEndpoints-1);
                polyfitDeltaError = polyfitDeltaError + avgDeltaErrors(endpointIndex)*segmentWeight;
            end
            allLocalSchemeFitDetails(schemeIndex).fitError = polyfitDeltaError;
            allLocalSchemeFitError(schemeIndex) = polyfitDeltaError;
        end
        %
        % Find and store min error scheme details
        %
        [~, minFitErrorSchemeIndex] = min(allLocalSchemeFitError);
        minErrorSchemeFitDetails = allLocalSchemeFitDetails(minFitErrorSchemeIndex);
        minDeltaErrorFreqEndpoints = [];
        for endpoint=segmentEndpoints(minFitErrorSchemeIndex,:)
           minDeltaErrorFreqEndpoints = [minDeltaErrorFreqEndpoints ft_pxx.freqEndpoints(endpoint)];
        end
        minErrorSchemeFitDetails.minDeltaErrorFreqEndpoints = minDeltaErrorFreqEndpoints;
        allMinErrorSchemeFitDetails{curChanGroup,curTimeInt} = minErrorSchemeFitDetails;
    end
end

ft_slopes.allMinErrorSchemeFitDetails = allMinErrorSchemeFitDetails;
ft_slopes.channelNeighborhood = channelNeighborhood;
ft_slopes.channelGroups = channelGroups;
ft_slopes.numTimeIntNeighbors = numTimeIntNeighbors;
ft_slopes.numSegments = numSegments;

% do the general cleanup and bookkeeping at the end of the function

% the ft_postamble function works by calling a number of scripts from
% fieldtrip/utility/private that are able to modify the local workspace

ft_postamble debug            % this clears the onCleanup function used for debugging in case of an error
ft_postamble trackconfig      % this converts the config object back into a struct and can report on the unused fields
ft_postamble provenance       % this records the time and memory at the end of the function, prints them on screen and adds this information together with the function name and matlab version etc. to the output cfg
ft_postamble previous datain  % this copies the datain.cfg structure into the cfg.previous field. You can also use it for multiple inputs, or for "varargin"
ft_postamble history dataout  % this adds the local cfg structure to the output data structure, i.e. dataout.cfg = cfg
ft_postamble savevar dataout  % this saves the output data structure to disk in case the user specified the cfg.outputfile option

    