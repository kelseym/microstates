%FIXME - this is not any faster than standard PWelch...

% This program calculates the power spectral density for all channels of
% data at the interval specified by the function call. All the results are
% stored in a Matlab ".mat" file.

% FastPwelch splits the frequency domain into groups defined by fit-freq intervals
% Frequency spacing is constant within each sub-interval, but varies across groups

clear;
% if matlabpool('size') <= 1
%     matlabpool open
% end
%filename = 'D:\Projects\ECOG_Work\McDonnell\McD03_SWS_0113-0118.EDF'
filename = 'D:\Projects\ECOG_Work\McDonnell\McD03_wake_1726-173.edf'
%% Load ECoG data and pre-process
cfg = [];
cfg.dataset = filename;
cfg.continuous = 'yes';
% cfg.bsfilter = 'yes';
% cfg.bsfreq = [59 61; 119 121; 179 181];
%cfg.demean = 'yes';
%cfg.detrend = 'yes';
data = ft_preprocessing(cfg);
dat = data.trial{1};
fsample = data.fsample;

t_skip = 30;
t_interval = 30;
t_average = 30;

% start a stopwatch
pwelchTime = tic;

% Calculate the number of channels.
temp = size(dat) ;
num_chan = temp(1) ;

% Calculate parameters needed for the time intervals.
num_intervals = 0 ;
t_min = data.sampleinfo(1) / fsample ;
t_max = data.sampleinfo(2) / fsample ;
for t1 = t_min:t_skip:(t_max - t_interval)
   num_intervals = num_intervals + 1 ;
end

% This will be needed below to rereference the entire trace using an
% average reference.
a_avg = mean(double(dat(:,:))) ;


% Compute F_tilde one time using the first channel and time interval
t2 = t_min + t_interval ;
i1 = floor((t_min * fsample) + 1 + 0.5) ;
i2 = floor((t2 * fsample)     + 0.5) ;
a = double(dat(1,:));
a_3_interval = a(i1:i2);
% Compute the power spectral density via a pwelch call with default parameters.
[~, F] = pwelch(a_3_interval,[],[],[],fsample) ;
% Compute the spacing of the frequency samples to have the
% spacing of the logarithm of the frequency samples be uniform.
L = 2^floor(log2(length(F))) ;
delta = 10^((1 / (L - 1)) * (log10(F(end)) - log10(F(2)))) ;
n = log10(F(2)) / log10(delta) ;
n_vec = (n:(n + L - 1))' ;
F_tilde = delta.^n_vec ;

% Compute piecewise linear F_tilde_est - linear between freqEndpoints
[freqEndpoints, ~] = getFitFreq();
F_tilde_est = zeros(length(F_tilde),1);
% Accomidate values in F_tilde that are outside the bounds of freqEndpoints
fMin = min(F_tilde);
f0 = freqEndpoints(1);
indexSet = find((F_tilde >= fMin) & (F_tilde <= f0)) ;
F_tilde_est(indexSet) = linspace(fMin,f0,length(indexSet));
fMax = max(F_tilde);
fN = freqEndpoints(end);
indexSet = find((F_tilde >= fN) & (F_tilde <= fMax)) ;
F_tilde_est(indexSet) = linspace(fN,fMax,length(indexSet));
% Compute linear segments
for fi=1:length(freqEndpoints)-1
    f1 = freqEndpoints(fi);
    f2 = freqEndpoints(fi+1);
    indexSet = find((F_tilde >= f1) & (F_tilde <= f2)) ;
    linFreqSeg = linspace(f1,f2,length(indexSet));
    F_tilde_est(indexSet) = linFreqSeg(:);
end

disp(sprintf('Starting pwelch calculation on %i core(s).', matlabpool('size')));
parfor chan = 1:num_chan
    tic
   % Rereference the entire trace using an average reference.
   a = double(dat(chan,:)) ;
   a_2 = a - a_avg ;

   % Correct the baseline.

   [a_3, baseline_estimate] = correct_baseline(a_2, fsample, t_average) ;

   % Loop over the time intervals to process all the data (with the
   % possible exception of some data at the end.
   
   interval_num = 0 ;

   Pxx_tilde_mat_out = zeros(length(F_tilde), num_intervals, num_chan) ;
   for t1 = t_min:t_skip:(t_max - t_interval)
      interval_num = interval_num + 1 ;
      
      % Plot the scroll data for the indicated channel and indicated time
      % interval.

      t2 = t1 + t_interval ;
      i1 = floor((t1 * fsample) + 1 + 0.5) ;
      i2 = floor((t2 * fsample)     + 0.5) ;

      a_3_interval = a_3(i1:i2) - mean(a_3(i1:i2)) ;

%       % Compute the power spectral density via a pwelch call with default
%       % parameters.
% 
%       [Pxx, F] = pwelch(a_3_interval,[],[],[],fsample) ;
%        
%       if ((chan == 1) && (interval_num == 1))
%          F_vec_out   = F ;
%          Pxx_mat_out = zeros(length(F), num_intervals, num_chan) ;
%       end
%       Pxx_mat_out(:, interval_num, chan) = Pxx ;
%        
%       % Compute the power spectral density again, but this time instead of
%       % having the spacing of the frequency samples be uniform, have the
%       % spacing of the logarithm of the frequency samples be uniform.
% 
%       L = 2^floor(log2(length(F))) ;
%       delta = 10^((1 / (L - 1)) * (log10(F(end)) - log10(F(2)))) ;
%       n = log10(F(2)) / log10(delta) ;
%       n_vec = (n:(n + L - 1))' ;
%       F_tilde = delta.^n_vec ;

      % Compute pwelch over linear spaced segments in F_tilde_est
      % Segement endpoints are defined by freqEndpoints
      for fi=1:length(freqEndpoints)-1
        f1 = freqEndpoints(fi);
        f2 = freqEndpoints(fi+1);
        indexSet = find((F_tilde >= f1) & (F_tilde <= f2)) ;
        [Pxx_tilde_seg, F_tilde_seg] = pwelch(a_3_interval, [], [], [], fsample) ;
        Pxx_tilde_mat_out(indexSet, interval_num, chan) = Pxx_tilde_seg ;
      end
   end
   toc
   disp(fprintf('Done with channel %i',chan));
end

disp('Total computation time:');
toc(pwelchTime);

