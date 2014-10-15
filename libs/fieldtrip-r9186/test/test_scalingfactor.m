function test_scalingfactor

% MEM 1500mb
% WALLTIME 00:10:00

% TEST test_scalingfactor
% TEST scalingfactor ft_convert_units

p = fileparts(which('ft_defaults'));
cd(fullfile(p, 'utilities', 'private'));

assert(scalingfactor('m', 'mm') == 1000);
assert(scalingfactor('mm', 'm') == 0.001);
assert(scalingfactor('T/cm', 'fT/m') == 1e17);

