function test_ft_selectdata

% MEM 1500mb
% WALLTIME 00:10:00

% TEST test_ft_selectdata
% TEST ft_selectdata ft_selectdata_old ft_selectdata_new ft_appendfreq

timelock1 = [];
timelock1.label = {'1' '2'};
timelock1.time  = 1:5;
timelock1.dimord = 'chan_time';
timelock1.avg = randn(2,5);

cfg = [];
cfg.channel = 1;
timelock1a = ft_selectdata(cfg, timelock1);
assert(isequal(size(timelock1a.avg), [1 5]));

cfg = [];
timelock2 = ft_appendtimelock(cfg, timelock1, timelock1, timelock1);

cfg = [];
cfg.channel = 1;
timelock2a = ft_selectdata(cfg, timelock2);
assert(isequal(size(timelock2a.trial), [3 1 5]));

cfg = [];
cfg.trials = [1 2];
timelock2b = ft_selectdata(cfg, timelock2);
assert(isequal(size(timelock2b.trial), [2 2 5]));

% The one that follows is a degenerate case. By selecting only one trial,
% the output is not really trial-based any more, but still contains one trial.
cfg = [];
cfg.trials = 1;
timelock2c = ft_selectdata(cfg, timelock2);
assert(isequal(size(timelock2c.trial), [1 2 5]));
% assert(isequal(size(timelock2c.trial), [2 5]));



%-------------------------------------
%generate data
data = [];
data.fsample = 1000;
data.cfg     = [];

nsmp  = 1000;
nchan = 80;
for k = 1:10
  data.trial{k} = randn(nchan,nsmp);
  data.time{k}  = ((1:nsmp)-1)./data.fsample;
end

% create grad-structure and add to data
grad.pnt  = randn(nchan,3);
grad.ori  = randn(nchan,3);
grad.tra  = eye(nchan);
for k = 1:nchan
  grad.label{k,1} = ['chan',num2str(k,'%03d')];
end
data.grad  = ft_datatype_sens(grad);
data.label = grad.label;
data.trialinfo = (1:10)';
data = ft_checkdata(data, 'hassampleinfo', 'yes');

%% this part of the script tests the functionality of ft_selectdata with respect
% to raw data.

compare_outputs(data, 'channel', data.label([5 8 12 38]));
% compare_outputs(data, 'channel', {}); % works neither with new nor old
compare_outputs(data, 'channel', 'all');
compare_outputs(data, 'trials',  [3 4 6 9]);
compare_outputs(data, 'trials',  []);
compare_outputs(data, 'trials',  'all');

% FIXME also test latency
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% this part of the script tests the functionality of ft_selectdata with respect
% to freqdata. it implements the (old) test_ft_selectdata_freqdata 
 
% do spectral analysis
cfg        = [];
cfg.method = 'mtmfft';
cfg.output = 'fourier';
cfg.foilim = [2 100];
cfg.pad    = 1;
cfg.tapsmofrq = 3;
freq       = ft_freqanalysis(cfg, data);
 
cfg.output = 'pow';
cfg.keeptrials = 'yes';
freqp      = ft_freqanalysis(cfg, data);
 
cfg.output = 'powandcsd';
cfg.channelcmb = ft_channelcombination([data.label(1) {'all'};data.label(2) {'all'}], data.label);
freqc      = ft_freqanalysis(cfg, data);
 
cfg        = [];
cfg.method = 'mtmconvol';
cfg.foi    = [10:10:100];
cfg.toi    = [0.4 0.5 0.6];
cfg.t_ftimwin = ones(1,numel(cfg.foi)).*0.2;
cfg.taper  = 'hanning';
cfg.output = 'pow';
cfg.keeptrials = 'yes';
freqtf     = ft_freqanalysis(cfg, data);
 
%% select channels, compare ft_selectdata_old with ft_selectdata_new and
% compare ft_selectdata_new with what would be expected
 
% make a selection of channels
[data_old, data_new] = compare_outputs(freq, 'channel', freq.label(5:10));
assert(isequal(data_old.fourierspctrm, freq.fourierspctrm(:,5:10,:)));
assert(isequal(data_new.fourierspctrm, freq.fourierspctrm(:,5:10,:)));

[data_old, data_new] = compare_outputs(freqp, 'channel', freq.label(5:10));
assert(isequal(data_old.powspctrm, freqp.powspctrm(:,5:10,:)));
assert(isequal(data_new.powspctrm, freqp.powspctrm(:,5:10,:)));

try
  [data_old, data_new] = compare_outputs(freqc, 'channel', freq.label(5:10));
  assert(isequal(data_old.powspctrm, freqc.powspctrm(:,5:10,:)));
  assert(isequal(data_new.powspctrm, freqc.powspctrm(:,5:10,:)));
catch
  fprintf('selecting channels with csd in input does not work');
end

[data_old, data_new] = compare_outputs(freqtf, 'channel', freq.label(5:10));
assert(isequal(data_old.powspctrm, freqtf.powspctrm(:,5:10,:,:)));
assert(isequal(data_new.powspctrm, freqtf.powspctrm(:,5:10,:,:)));

% make a selection of all channels
[data_old, data_new] = compare_outputs(freq, 'channel', 'all');
assert(isequal(data_old.fourierspctrm, freq.fourierspctrm));
assert(isequal(data_new.fourierspctrm, freq.fourierspctrm));

[data_old, data_new] = compare_outputs(freqp, 'channel', 'all');
assert(isequal(data_old.powspctrm, freqp.powspctrm));
assert(isequal(data_new.powspctrm, freqp.powspctrm));

try
  [data_old, data_new] = compare_outputs(freqc, 'channel', 'all');
  assert(isequal(data_old.powspctrm, freqc.powspctrm));
  assert(isequal(data_new.powspctrm, freqc.powspctrm));
catch
  fprintf('selecting channels with csd in input does not work');
end

[data_old, data_new] = compare_outputs(freqtf, 'channel', 'all');
assert(isequal(data_old.powspctrm, freqtf.powspctrm));
assert(isequal(data_new.powspctrm, freqtf.powspctrm));

% make a selection of no channels
[data_old, data_new] = compare_outputs(freq, 'channel', {});
assert(isequal(data_old.label,{}));
assert(isequal(data_new.label,{}));

[data_old, data_new] = compare_outputs(freqp, 'channel', {});
assert(isequal(data_old.label,{}));
assert(isequal(data_new.label,{}));

try
  [data_old, data_new] = compare_outputs(freqc, 'channel', {});
  assert(isequal(data_old.label,{}));
  assert(isequal(data_new.label,{}));
catch
  fprintf('selecting channels with csd in input does not work');
end

[data_old, data_new] = compare_outputs(freqtf, 'channel', {});
assert(isequal(data_old.label,{}));
assert(isequal(data_new.label,{}));

%% select frequencies

[data_old, data_new] = compare_outputs(freq, 'frequency', freq.freq([9 39]));
assert(isequal(data_old.fourierspctrm, freq.fourierspctrm(:,:,9:39)));
assert(isequal(data_new.fourierspctrm, freq.fourierspctrm(:,:,9:39)));

[data_old, data_new] = compare_outputs(freqp, 'frequency', freqp.freq([9 39]));
assert(isequal(data_old.powspctrm, freqp.powspctrm(:,:,9:39)));
assert(isequal(data_new.powspctrm, freqp.powspctrm(:,:,9:39)));

try
  [data_old, data_new] = compare_outputs(freqc, 'frequency', freqc.freq([9 39]));
  assert(isequal(data_old.powspctrm, freqp.powspctrm(:,5:10,:)));
  assert(isequal(data_new.powspctrm, freqp.powspctrm(:,5:10,:)));
catch
  fprintf('selecting channels with csd in input does not work');
end

[data_old, data_new] = compare_outputs(freqtf, 'frequency', freqtf.freq([1 4]));
assert(isequal(data_old.powspctrm, freqtf.powspctrm(:,:,1:4,:)));
assert(isequal(data_new.powspctrm, freqtf.powspctrm(:,:,1:4,:)));

% make a selection of all channels
[data_old, data_new] = compare_outputs(freq, 'frequency', 'all');
assert(isequal(data_old.fourierspctrm, freq.fourierspctrm));
assert(isequal(data_new.fourierspctrm, freq.fourierspctrm));

[data_old, data_new] = compare_outputs(freqp, 'frequency', 'all');
assert(isequal(data_old.powspctrm, freqp.powspctrm));
assert(isequal(data_new.powspctrm, freqp.powspctrm));

try
  [data_old, data_new] = compare_outputs(freqp, 'frequency', 'all');
  assert(isequal(data_old.powspctrm, freqp.powspctrm));
  assert(isequal(data_new.powspctrm, freqp.powspctrm));
catch
  fprintf('selecting channels with csd in input does not work');
end

[data_old, data_new] = compare_outputs(freqtf, 'frequency', 'all');
assert(isequal(data_old.powspctrm, freqtf.powspctrm));
assert(isequal(data_new.powspctrm, freqtf.powspctrm));

% make a selection of no channels
compare_outputs(freq, 'frequency', []);
compare_outputs(freqp, 'frequency', []);
try
  compare_outputs(freqp, 'frequency', []);
catch
  fprintf('selecting channels with csd in input does not work');
end
compare_outputs(freqtf, 'frequency', []);

%% select time
 
% subselection
[data_old, data_new] = compare_outputs(freqtf, 'latency', [0.5 0.6]);
assert(isequal(data_old.powspctrm, freqtf.powspctrm(:,:,:,[2 3])));
assert(isequal(data_new.powspctrm, freqtf.powspctrm(:,:,:,[2 3])));% 

compare_outputs(freqtf, 'latency', 'all'); % all
compare_outputs(freqtf, 'latency', []); % nothing
 
%% select trials
 
% do a subselection
compare_outputs(freq,   'trials', 3:5);
compare_outputs(freqp,  'trials', 3:5);
try
  compare_outputs(freqc,  'trials', 3:5);
catch
  warning('assertion failed, because ft_selectdata_new cannot deal with crsspctrm in input yet');
end
compare_outputs(freqtf, 'trials', 3:5);
 
% do an empty selection
compare_outputs(freq,   'trials', []);
compare_outputs(freqp,  'trials', []);
try
  compare_outputs(freqc,  'trials', []);
catch
  warning('assertion failed, because ft_selectdata_new cannot deal with crsspctrm in input yet');
end
compare_outputs(freqtf, 'trials', []);

% select all
compare_outputs(freq,   'trials', 'all');
compare_outputs(freqp,  'trials', 'all');
try
  compare_outputs(freqc,  'trials', 'all');
catch
  warning('assertion failed, because ft_selectdata_new cannot deal with crsspctrm in input yet');
end
compare_outputs(freqtf, 'trials', 'all');

%% avgover channels
% Old snippet: not needed anymore
% fx4  = ft_selectdata(freq,   'avgoverchan', 'yes');
% fp4  = ft_selectdata(freqp,  'avgoverchan', 'yes');
% fc4  = ft_selectdata(freqc,  'avgoverchan', 'yes');
% ftf4 = ft_selectdata(freqtf, 'avgoverchan', 'yes');
% 
% % assessing label after averaging: see bug 2191 -> this seems OK
% cfg             = [];
% cfg.avgoverchan = 'yes';
% fx42  = ft_selectdata(cfg,freq);
% fp42  = ft_selectdata(cfg,freqp);
% fc42  = ft_selectdata(cfg,freqc);
% ftf42 = ft_selectdata(cfg,freqtf);
% 
% if ~strcmp(fx4.label{:},fx42.label{:});error('mismatch on label field');end
% if ~strcmp(fp4.label{:},fp42.label{:});error('mismatch on label field');end
% if ~strcmp(fc4.label{:},fc42.label{:});error('mismatch on label field');end
% if ~strcmp(ftf4.label{:},ftf42.label{:});error('mismatch on label field');end

compare_outputs(freq,   'avgoverchan');
compare_outputs(freqp,  'avgoverchan');
try
  compare_outputs(freqc,  'avgoverchan');
catch
end
compare_outputs(freqtf, 'avgoverchan');

%% avgover frequencies
compare_outputs(freq,  'avgoverfreq');
compare_outputs(freqp, 'avgoverfreq');
try
  compare_outputs(freqc, 'avgoverfreq');
catch
end
compare_outputs(freqtf, 'avgoverfreq');

%% avgover trials
compare_outputs(freq,  'avgoverrpt');
compare_outputs(freqp, 'avgoverrpt');
try
  compare_outputs(freqc, 'avgoverrpt');
catch
end
compare_outputs(freqtf, 'avgoverrpt');

%% leaveoneout
% FIXME: to be looked into
% % fx7 = ft_selectdata(freq,  'jackknife', 'yes'); %FAILS due to 'rpttap'
% fp7 = ft_selectdata(freqp, 'jackknife', 'yes');
% fc7 = ft_selectdata(freqc, 'jackknife', 'yes');
% ftf7 = ft_selectdata(freqtf, 'jackknife', 'yes');

%% this part tests the functionality of ft_appendfreq

whos
clear freq*

% make some dummy frequency structures
freq1.label = {'1' '2'};
freq1.freq  = 1:10;
freq1.time  = 1:5;
freq1.dimord = 'chan_freq_time';
freq1.powspctrm = randn(2,10,5);
freq1.cfg   = [];

cfg = [];
cfg.parameter = 'powspctrm';
freq2  = ft_appendfreq(cfg, freq1, freq1);
freq2  = rmfield(freq2, 'cfg');
freq2a = ft_selectdata(freq1, freq1, 'param', 'powspctrm'); % this should append the power spectrum
assert(isequal(freq2, freq2a));

freq4a = ft_selectdata(freq2, freq2, 'param', 'powspctrm');
assert(isequal(size(freq4a.powspctrm), [4 2 10 5]));

clear freq*

freq3.label = {'1' '2'};
freq3.freq  = 1:10;
freq3.dimord = 'chan_freq';
freq3.powspctrm = randn(2,10);

cfg = [];
cfg.parameter = 'powspctrm';
freq4  = ft_appendfreq(cfg, freq3, freq3);
freq4  = rmfield(freq4, 'cfg');
freq4a = ft_selectdata(freq3, freq3, 'param', 'powspctrm');  % this should append the power spectrum
assert(isequal(freq4, freq4a));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% this part of the function tests the functionality of ft_selectdata with respect to timelock data

% create timelocked data
cfg = [];
cfg.keeptrials = 'yes';
tlck = ft_timelockanalysis(cfg, data);
cfg.covariance = 'yes';
tlckc = ft_timelockanalysis(cfg, data);
cfg.keeptrials = 'no';
tlckcavg = ft_timelockanalysis(cfg, data);
cfg.covariance = 'no';
tlckavg = ft_timelockanalysis(cfg, data);

%% select trials
compare_outputs(tlck,  'trials', [4 5 6]);
compare_outputs(tlckc, 'trials', [4 5 6]);
compare_outputs(tlck,  'trials', []);
compare_outputs(tlckc, 'trials', []);
compare_outputs(tlck,  'trials', 'all');
compare_outputs(tlckc, 'trials', 'all');

%% select latency
compare_outputs(tlck,      'latency', [-0.1 0.1]);
compare_outputs(tlckc,     'latency', [-0.1 0.1]);
compare_outputs(tlckavg,   'latency', [-0.1 0.1]);
compare_outputs(tlckcavg,  'latency', [-0.1 0.1]);
compare_outputs(tlck,      'latency', []);
compare_outputs(tlckc,     'latency', []);
compare_outputs(tlckavg,   'latency', []);
compare_outputs(tlckcavg,  'latency', []);
compare_outputs(tlck,      'latency', 'all');
compare_outputs(tlckc,     'latency', 'all');
compare_outputs(tlckavg,   'latency', 'all');
compare_outputs(tlckcavg,  'latency', 'all');

%% select channels
compare_outputs(tlck,      'channel', tlck.label(11:20));
compare_outputs(tlckc,     'channel', tlckc.label(11:20));
compare_outputs(tlckavg,   'channel', tlckavg.label(11:20));
% compare_outputs(tlckcavg,  'channel', tlckcavg.label(11:20));% this one
%fails because ft_selectdata correctly selects channels from cov and
%ft_selectdata does not
compare_outputs(tlck,      'channel', []);
compare_outputs(tlckc,     'channel', []);
compare_outputs(tlckavg,   'channel', []);
% compare_outputs(tlckcavg,  'channel', []);% this one
%fails because ft_selectdata correctly selects channels from cov and
%ft_selectdata does not
compare_outputs(tlck,      'channel', 'all');
compare_outputs(tlckc,     'channel', 'all');
compare_outputs(tlckavg,   'channel', 'all');
compare_outputs(tlckcavg,  'channel', 'all');

%% avgoverrpt
compare_outputs(tlck,  'avgoverrpt');
compare_outputs(tlckc, 'avgoverrpt');

%% avgoverchan
compare_outputs(tlck,  'avgoverchan');
compare_outputs(tlckc, 'avgoverchan');
compare_outputs(tlckavg,  'avgoverchan');
compare_outputs(tlckcavg, 'avgoverchan');

%% avgovertime
% FIXME: ft_selectdata_new removes time altogether, ft_selectdata_new does
% not: discuss what is expected behavior

%compare_outputs(tlck,  'avgovertime');
%compare_outputs(tlckc, 'avgovertime');
%compare_outputs(tlckavg,  'avgovertime');
%compare_outputs(tlckcavg, 'avgovertime');



function [data_old, data_new] = compare_outputs(data, key, value)

switch key
  case 'trials'
    keyold = 'rpt';
  case 'frequency'
    keyold = 'foilim';
  case 'latency'
    keyold = 'toilim';
  otherwise
    keyold = key;
end

if nargin>2
  % there has been a key and a value
  cfg       = [];
  cfg.(key) = value;
  data_new  = ft_selectdata(cfg,  data);
  data_old  = ft_selectdata(data, keyold, value);
  
  % don't include the cfg
  data_new  = rmfield(data_new, 'cfg');
  data_old  = rmfield(data_old, 'cfg');
  if isfield(data_new, 'cov') && ~isfield(data_old, 'cov')
    % skip the comparison of the cov, because ft_selectdata_old could not
    % deal with this correctly: this is not something to be asserted here
    data_new = rmfield(data_new, 'cov')
  end
  assert(isequal(data_old, data_new));
  
  % check whether the output is the same as the input
  if ischar(value) && strcmp(value, 'all')
    dataorig = data;
    try, if isfield(dataorig, 'trial'), data = rmfield(dataorig, {'avg', 'var', 'dof'}); end ; end% only remove when trial
    try, if isfield(data, 'cov') && ~isfield(data_old, 'cov'), data = rmfield(data, 'cov'); end; end
    data = rmfield(data, 'cfg');
    assert(isequal(data, data_old));
    
    data = dataorig;
    try, if isfield(dataorig, 'trial'), data = rmfield(dataorig, {'avg', 'var', 'dof'}); end ; end% only remove when trial
    try, if isfield(data, 'cov') && ~isfield(data_new, 'cov'), data = rmfield(data, 'cov'); end; end
    data = rmfield(data, 'cfg');
    assert(isequal(data, data_new));
  end
else
  % assume the avgoverXXX is tested
  cfg       = [];
  cfg.(key) = 'yes';
  data_new  = ft_selectdata(cfg,  data);
  data_old  = ft_selectdata(data, keyold, 'yes');
  
  % don't include the cfg
  data_new  = rmfield(data_new, 'cfg');
  data_old  = rmfield(data_old, 'cfg');
  
  if strcmp(key, 'avgoverfreq') | strcmp(key, 'avgoverrpt')
    % apparently something may be wrong with the data_old.dimord
    % don't spend time on fixing this here
    data_old.dimord = data_new.dimord;
  end
  
  if strcmp(key, 'avgoverrpt')
    % ft_selectdata_old does something inconsistent, don't bother to fix it
    if isfield(data_old, 'cumtapcnt'), data_old = rmfield(data_old, 'cumtapcnt'); end
    if isfield(data_old, 'cumsumcnt'), data_old = rmfield(data_old, 'cumsumcnt'); end
    if isfield(data_old, 'trialinfo'), data_old = rmfield(data_old, 'trialinfo'); end
  
    % ft_selectdata_new tries to keep the cov, but ft_selectdata doesn't,
    % don't bother to fix ft_selectdata_old
    if isfield(data_new, 'cov'), data_new = rmfield(data_new, 'cov'); end
  end  
  
  if strcmp(key, 'avgoverchan')
    % ft_selectdata_old sometimes keeps the cov (without averaging), don't
    % bother to fix it
    if isfield(data_old, 'cov'), data_old = rmfield(data_old, 'cov'); end 
    
    % ft_selectdata_new tries to keep the cov, but ft_selectdata doesn't,
    % don't bother to fix ft_selectdata_old
    if isfield(data_new, 'cov'), data_new = rmfield(data_new, 'cov'); end
  end
  
  assert(isequal(data_old, data_new));
end
