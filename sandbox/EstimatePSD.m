% Estimate PSD of MEG data

fileName = GetLocalDataFile();

for chni=1:size(data.trial{1},1)
  [Pxx, F] = pwelch(data.trial{1}(1,:),[],[],[],data.fsample);
  
  % Compute the spacing of the frequency samples to have the
  % spacing of the logarithm of the frequency samples be uniform.
  L = 2^floor(log2(length(F))) ;
  delta = 10^((1 / (L - 1)) * (log10(F(end)) - log10(F(2)))) ;
  n = log10(F(2)) / log10(delta) ;
  n_vec = (n:(n + L - 1))' ;
  F_tilde = delta.^n_vec ;
  Pxx_tilde_mat_out = zeros(num_chan, num_intervals, length(F_tilde)) ;
  