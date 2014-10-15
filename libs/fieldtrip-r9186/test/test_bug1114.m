function test_bug1114

% MEM 1500mb
% WALLTIME 00:10:00

% This function parses all fieldtrip main and module functions and determines
% whether there are any dependencies on fieldtrip/compat or any other
% compat directory. If so, the files are printed with an error.

fieldtripdir = fileparts(which('ft_defaults'));

% ensure that the compat directories are on the path
addpath(fullfile(fieldtripdir, 'compat'))
addpath(fullfile(fieldtripdir, 'fileio/compat'))
addpath(fullfile(fieldtripdir, 'forward/compat'))
addpath(fullfile(fieldtripdir, 'plotting/compat'))
addpath(fullfile(fieldtripdir, 'preproc/compat'))
addpath(fullfile(fieldtripdir, 'utilities/compat'))

dirlist = {
  fieldtripdir
  fullfile(fieldtripdir, 'fileio')
  fullfile(fieldtripdir, 'forward')
  fullfile(fieldtripdir, 'inverse')
  fullfile(fieldtripdir, 'plotting')
  fullfile(fieldtripdir, 'connectivity')
  fullfile(fieldtripdir, 'specest')
  fullfile(fieldtripdir, 'trialfun')
  fullfile(fieldtripdir, 'statfun')
  fullfile(fieldtripdir, 'utilities')
  fullfile(fieldtripdir, 'private')
  };

for dirindex=1:length(dirlist)
  functionlist = dir(fullfile(dirlist{dirindex}, '*.m'));
  functionlist = {functionlist.name};
  
  fprintf('==== processing directory %s ====\n', dirlist{dirindex});
  
  % find the dependencies
  [outlist, depmat] = mydepfun(functionlist);
  
  compat = false(size(outlist));
  for i=1:length(outlist)
    compat(i) = ~isempty(regexp(outlist{i}, '/compat', 'once'));
  end
  % switch to list indices
  compat = find(compat);
  
  if ~isempty(compat)
    % report on the problems
    fprintf('\nThe compat functions ...\n');
    disp(outlist(compat));
    fprintf('... are being used by\n');
    disp(functionlist(any(depmat(:,compat),2))');
    error('some of the FT functions depend on compat functions');
    % warning('some of the FT functions depend on compat functions');
  end
end % for dirlist

