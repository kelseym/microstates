% calc_psd_all.m
%
% This program calculates the power spectral density for all channels of
% data at the interval specified by the function call. All the results are
% stored in a Matlab ".mat" file.
clear;
if matlabpool('size') <= 1
    matlabpool open
end
%filename = 'D:\Projects\McDonnell\McD03_SWS_0113-0118.EDF'
filename = 'D:\Projects\McDonnell\McD03_wake_1726-173.edf'
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
Pxx_tilde_mat_out = zeros(num_chan, num_intervals, length(F_tilde)) ;

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
   Pxx_int_freq = zeros(num_chan, num_intervals, length(F_tilde)) ;
   for t1 = t_min:t_skip:(t_max - t_interval)
      interval_num = interval_num + 1 ;
      
      t2 = t1 + t_interval ;
      i1 = floor((t1 * fsample) + 1 + 0.5) ;
      i2 = floor((t2 * fsample)     + 0.5) ;

      a_3_interval = a_3(i1:i2) - mean(a_3(i1:i2)) ;

      [Pxx_tilde, F_tilde2] = pwelch(a_3_interval, [], [], F_tilde, fsample) ;
       
      Pxx_tilde_mat_out(chan, interval_num, :) = Pxx_tilde ;
       
   end
   toc
end

disp('Total computation time:');
toc(pwelchTime);

