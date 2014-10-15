clear;

if matlabpool('size') <= 1
    matlabpool open
end

% import PSD matrix from .mat file
filename = 'D:\Projects\ECOG_Work\Already_Staged_ECoG\new_HBM_Slope_Results_30_sec\Slope_PSD_McD03_N2_0057-0102.set_interval_0030_sec_t_average_0_sec.mat';
load(filename,'-mat','Pxx_tilde_mat_out','F_tilde_vec_out');

% convert to fieldtrip friendly format
ft_pxx = pxxTildeToFtStruct(Pxx_tilde_mat_out, F_tilde_vec_out);

% cleanup unused variables
clear 'Pxx_tilde_mat_out' 'F_tilde_vec_out';

% calculate line slopes over all frequency divisions and endpoints (from Frontiers pub.)
cfg = [];
[cfg.freqEndpoints, cfg.fitFreq] = getFitFreq();
ft_pxx = calculateSegmentSlopes(ft_pxx, cfg);

% calculate N segment spectral partitions, report details of min error fit
cfg = [];
cfg.numSegments = 4;
cfg.numTimeIntNeighbors = 5;
cfg.channelNeighborhood = 'individual'; % 'all' 'grid' 'individual' 'local'
ft_slopes = calculateSpectralPartitions(ft_pxx, cfg);
