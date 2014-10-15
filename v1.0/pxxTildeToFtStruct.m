% convert Pxx_tilde_mat_out to fieldtrip friendly data stucture, as seen in ouput to ft_freqanalysis.m

function freq = pxxTildeToFtStruct(Pxx_tilde_mat_out, F_tilde_vec_out, timeIntervals)

freq = [];
freq.label = [];
freq.dimord = 'chan_freq_time';
freq.freq   = F_tilde_vec_out;
% Pxx_tilde_mat_out dimension ordering is freq_time_chan, switch to chan_freq_time
freq.powspctrm = permute(Pxx_tilde_mat_out,[3, 1, 2]);
