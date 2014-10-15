function test_bug1150

% MEM 2000mb
% WALLTIME 00:10:00

% TEST test_bug1150
% TEST ft_sourcestatistics

load /home/common/matlab/fieldtrip/data/test/bug1150.mat

% the following failed
% stat = ft_sourcestatistics(cfg, temp);
% which could be tracked down to the dimord being incorrect after
% ft_checkdata

sourcenew = ft_checkdata(temp, 'sourcerepresentation', 'new');
if ~strcmp(sourcenew.powdimord, 'pos_rpt')
  error('incorrect posdimord');
end



