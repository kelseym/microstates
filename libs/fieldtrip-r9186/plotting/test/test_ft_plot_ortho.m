function test_ft_plot_ortho

% MEM 1gb
% WALLTIME 0:03:00

% TEST test_ft_plot_ortho
% TEST ft_plot_ortho

dat = randn(64, 64, 64);

figure
ft_plot_ortho(dat);
