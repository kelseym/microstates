function compile_eon_microstates(fieldtriproot, eon_microstates_root)

% COMPILE_MEGCONNECTOME compiles eon_microstates fieldtrip functions along with
% the "eon_microstates" entry function into a stand-alone compiled executable.
%
% The compiled executable includes
%  - all main fieldtrip m-files
%  - all main fieldtrip's m-files dependencies for as long as these
%    dependencies are in the fieldtrip modules on the path, matlab
%    built-in, or toolbox/(stats/images/signal) functions
%  - the eon_microstates functions and its subdirectories
%

% clear all variables, globals, functions and MEX links
% clear all; % don't do this because it clears the input arguments
clear global;
clear fun;
clear mex;

fname = 'eon_microstates';

v = ver('MATLAB');
if ~strcmp(v.Version, '8.0')
    error('the eon_microstates application should be compiled with MATLAB 2012b (8.0)');
end

if nargin<1 || isempty(fieldtriproot)
    fieldtriproot = fileparts(which('ft_defaults'));
end

if nargin<2 || isempty(eon_microstates_root)
    % this script is in eon_microstates_root/build
    eon_microstates_root = fileparts(which(mfilename));
    eon_microstates_root = fileparts(eon_microstates_root);
end

origdir  = pwd;
builddir = fullfile(eon_microstates_root, 'build');
bindir   = fullfile(eon_microstates_root, 'bin');

cd(builddir);

% create a file with the timestamp of the compilation
fid = fopen('buildtimestamp.m', 'wt');
fprintf(fid, 'function s = buildtimestamp\n');
fprintf(fid, 's = ''%s'';\n', datestr(now));
fclose(fid);

cd(bindir);

fprintf('Using fieldtrip     from "%s"\n', fieldtriproot);
fprintf('Using eon_microstates from "%s"\n', eon_microstates_root);

% clean the path
restoredefaultpath;

%--------------------------------
% FIELDTRIP RELATED PATH SETTINGS

% add the path to fieldtrip
addpath(fieldtriproot);

% ensure that the path to the default modules is specified
clear ft_defaults;
ft_defaults;

% do not use my personal defaults, but rather FieldTrip standard defaults
global ft_default
ft_default = [];

% do not use my personal defaults, but rather HCP standard defaults
global hcp_default
hcp_default = [];

% ensure that these special modules are also added
ft_hastoolbox('qsub', 1);
ft_hastoolbox('engine', 1);

% ensure that all external toolboxes are added to the path
% excluding spm2 (leading to more than one spm on the path -> confusion in FT)
exclude = {
    '.'
    '..'
    '.svn'
    '.git'
    'dipoli'
    'dmlt'
    'iso2mesh'
    'simbio'
    'spm2'
    'sqdproject'
    'yokogawa'
    };
extd = dir([fieldtriproot,'/external']);
extd = setdiff({extd([extd.isdir]).name}, exclude);
for k = 1:numel(extd)
    addpath(fullfile(fieldtriproot,'external',extd{k}));
end

%--------------------------
% RELATED PATH SETTINGS

addpath(eon_microstates_root);
%addpath(fullfile(eon_microstates_root, 'external'));
addpath(fullfile(eon_microstates_root, 'analysis_functions'));
addpath(fullfile(eon_microstates_root, 'experiments'));
addpath(fullfile(eon_microstates_root, 'pipeline_scripts'));

%-------------------
% DO THE COMPILATION

cmd = ['mcc -R -singleCompThread -N -o ' fname ' -m ' fname ...
    ' -a ' fieldtriproot '/*.m' ...
    ' -a ' fieldtriproot '/utilities/*.m' ...
    ' -a ' fieldtriproot '/fileio/*.m' ...
    ' -a ' fieldtriproot '/forward/*.m' ...
    ' -a ' fieldtriproot '/inverse/*.m' ...
    ' -a ' fieldtriproot '/plotting/*.m' ...
    ' -a ' fieldtriproot '/statfun/*.m' ...
    ' -a ' fieldtriproot '/trialfun/*.m' ...
    ' -a ' fieldtriproot '/preproc/*.m' ...
    ' -a ' fieldtriproot '/qsub/*.m' ...
    ' -a ' fieldtriproot '/engine/*.m' ...
    ' -a ' fieldtriproot '/external/plot2svg/*.m' ...
    ' -a ' eon_microstates_root       '/libs/*.m' ...
    ' -a ' eon_microstates_root       '/build/buildtimestamp.m' ...
    ' -a ' eon_microstates_root       '/build/eon_microstates.m' ...
%     ' -a ' eon_microstates_root       '/external/*.m' ...
%     ' -a ' eon_microstates_root       '/external/*.mex*' ...
    ' -a ' eon_microstates_root       '/analysis_functions/*.m' ...
    ' -a ' eon_microstates_root       'experiments/*.m' ...
    ' -a ' eon_microstates_root       '/plotting/*.m' ...
    ' -p ' matlabroot    '/toolbox/signal' ...
    ' -p ' matlabroot    '/toolbox/images' ...
    ' -p ' matlabroot    '/toolbox/stats' ...
    ' -p ' matlabroot    '/toolbox/optim' ...
    ' -p ' matlabroot    '/toolbox/curvefit' ...
    ];
eval(cmd);

% somehow I don't manage to get this going with more than one directory to be added when calling mcc directly:
% mcc('-N', '-a', '/home/common/matlab/fieldtrip/*.m', '-o', fname, '-m', fname, '-p', [matlabroot,'/toolbox/signal:', matlabroot,'/toolbox/images:', matlabroot,'/toolbox/stats']);

% remove the additional files that were created during compilation
%delete mccExcludedFiles.log
%delete readme.txt
%delete run_eon_microstates.sh

fprintf('Finished compilation\n');
cd(origdir);
