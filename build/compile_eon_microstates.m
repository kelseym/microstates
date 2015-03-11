function compile_eon_microstates(full_fieldtriproot, full_eon_microstates_root)

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

if nargin<1 || isempty(full_fieldtriproot)
    full_fieldtriproot = fileparts(which('ft_defaults'));
end

if nargin<2 || isempty(full_eon_microstates_root)
    % this script is in eon_microstates_root/build
    full_eon_microstates_root = fileparts(which(mfilename));
    full_eon_microstates_root = fileparts(full_eon_microstates_root);
end

origdir  = pwd;
builddir = fullfile(full_eon_microstates_root, 'build');
bindir   = fullfile(full_eon_microstates_root, 'bin');

cd(builddir);

% create a file with the timestamp of the compilation
fid = fopen('buildtimestamp.m', 'wt');
fprintf(fid, 'function s = buildtimestamp\n');
fprintf(fid, 's = ''%s'';\n', datestr(now));
fclose(fid);

cd(bindir);

fprintf('Using fieldtrip     from "%s"\n', full_fieldtriproot);
fprintf('Using eon_microstates from "%s"\n', full_eon_microstates_root);

% clean the path
restoredefaultpath;

%--------------------------------
% FIELDTRIP RELATED PATH SETTINGS

% add the path to fieldtrip
addpath(full_fieldtriproot);

% ensure that the path to the default modules is specified
clear ft_defaults;
ft_defaults;

% do not use my personal defaults, but rather FieldTrip standard defaults
global ft_default
ft_default = [];

% do not use my personal defaults, but rather EON standard defaults
global eon_default
eon_default = [];

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
    'eeprobe'
    };
extd = dir([full_fieldtriproot,'/external']);
extd = setdiff({extd([extd.isdir]).name}, exclude);
for k = 1:numel(extd)
    addpath(fullfile(full_fieldtriproot,'external',extd{k}));
end

%--------------------------
% RELATED PATH SETTINGS

addpath(full_eon_microstates_root);
addpath(fullfile(full_eon_microstates_root, 'analysis_functions'));
addpath(fullfile(full_eon_microstates_root, 'experiments'));
addpath(fullfile(full_eon_microstates_root, 'pipeline_scripts'));

%-------------------
% DO THE COMPILATION

cmd = ['mcc -R -singleCompThread -N -o ' fname ' -m ' fname ...
    ' -a ' full_fieldtriproot '/*.m' ...
    ' -a ' full_fieldtriproot '/utilities/*.m' ...
    ' -a ' full_fieldtriproot '/fileio/*.m' ...
    ' -a ' full_fieldtriproot '/forward/*.m' ...
    ' -a ' full_fieldtriproot '/inverse/*.m' ...
    ' -a ' full_fieldtriproot '/plotting/*.m' ...
    ' -a ' full_fieldtriproot '/statfun/*.m' ...
    ' -a ' full_fieldtriproot '/trialfun/*.m' ...
    ' -a ' full_fieldtriproot '/preproc/*.m' ...
    ' -a ' full_fieldtriproot '/qsub/*.m' ...
    ' -a ' full_fieldtriproot '/engine/*.m' ...
    ' -a ' full_eon_microstates_root       '/libs/*.m' ...
    ' -a ' full_eon_microstates_root       '/build/buildtimestamp.m' ...
    ' -a ' full_eon_microstates_root       '/build/eon_microstates.m' ...
    ' -a ' full_eon_microstates_root       '/analysis_functions/*.m' ...
    ' -a ' full_eon_microstates_root       '/experiments/*.m' ...
    ' -a ' full_eon_microstates_root       '/plotting/*.m' ...
    ' -a ' full_eon_microstates_root       '/local/*.m' ...
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
