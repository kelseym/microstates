% This program calculates the power spectral density for all channels of
% data at the interval specified by the function call. 

clear;
filename = 'D:\Projects\ECOG_Work\McDonnell\McD03_wake_1726-173.edf';
%% Load ECoG data and pre-process
cfg = [];
cfg.dataset = filename;
cfg.continuous = 'yes';
% cfg.bsfilter = 'yes';
% cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.demean = 'yes';
cfg.detrend = 'yes';
data = ft_preprocessing(cfg);

t_skip = 10;
t_interval = 30;

% Calculate the number of channels.
num_chan = length(data.label);

% Calculate parameters needed for the time intervals.
num_intervals = 0 ;
t_min = 0 ;
t_max = data.sampleinfo(2) / data.fsample ;
for t1 = t_min:t_skip:(t_max - t_interval)
   num_intervals = num_intervals + 1 ;
end
tic;

linSpacedF = linspace(0.2,200,2^nextpow2(t_skip*data.fsample));
L = 2^floor(log2(length(linSpacedF))) ;
delta = 10^((1 / (L - 1)) * (log10(linSpacedF(end)) - log10(linSpacedF(2)))) ;
n = log10(linSpacedF(2)) / log10(delta) ;
n_vec = (n:(n + L - 1))' ;
F_tilde = gpuArray(delta.^n_vec);

for chan = 1:num_chan

   a_3 = gpuArray(double(data.trial{1}(chan,:)));

   % Loop over the time intervals to process all the data (with the
   % possible exception of some data at the end.
   
   interval_num = 0 ;


   for t1 = t_min:t_skip:(t_max - t_interval)
      
      interval_num = interval_num + 1 ;
      
      % Give progress report.
      
      disp_string = ['Channel ' num2str(chan) ...
         ' out of ' num2str(num_chan) ', Time interval ' ...
         num2str(interval_num) ' out of ' num2str(num_intervals) ', ' ...
         datestr(now) '.'] ;
      disp(disp_string) ;

      % Plot the scroll data for the indicated channel and indicated time
      % interval.

      t2 = t1 + t_interval ;
      i1 = floor((t1 * data.fsample) + 1 + 0.5) ;
      i2 = floor((t2 * data.fsample)     + 0.5) ;

      a_3_interval = a_3(i1:i2) - mean(a_3(i1:i2)) ;

      
      % Compute the power spectral density, but this time instead of
      % having the spacing of the frequency samples be uniform, have the
      % spacing of the logarithm of the frequency samples be uniform.

      tic;
      [Pxx_tilde, F_tilde] = pwelch(a_3_interval, [], [], F_tilde, data.fsample) ;
      toc;
      if ((chan == 1) && (interval_num == 1))
         F_tilde_vec_out   = F_tilde ;
         Pxx_tilde_mat_out = zeros(length(F_tilde), num_intervals, num_chan) ;
      end
      Pxx_tilde_mat_out(:, interval_num, chan) = Pxx_tilde ;
       
   end

end
toc
% Clean up the workspace.

clear EEG F F_tilde L Pxx Pxx_tilde a a_2 a_3 a_3_interval a_avg
clear baseline_estimate chan delta disp_string file_name_in_set
clear i1 i2 interval_num n n_vec t t1 t2 temp
 

