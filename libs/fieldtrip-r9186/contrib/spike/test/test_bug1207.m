function test_bug1207

% MEM 1gb
% WALLTIME 00:05:00

% TT5.ntt in this directory
% TT5_1.t in this directory

spike1 = ft_read_spike('/contrib/spike/test/TT5.ntt');
spike2 = ft_read_spike('/contrib/spike/test/TT5_1.t');
