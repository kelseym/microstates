function eon_microstates(varargin)

% This is the entry function of the compiled "eon_microstates.exe"
% application that includes fieldtrip and the eon_microstates experiment scripts.
% The compiled application can be used to execute the scripts that are found
% in eon_microstates/experiments.
%
% This function can be started on the MATLAB command line as
%   eon_microstates  scriptname.m
% or after compilation on the Linux command line as
%   eon_microstates.sh <MATLABROOT>
%   eon_microstates.sh <MATLABROOT>  scriptname.m
%
% It is possible to pass additional options on the MATLAB command line like
% this on the MATLAB command line
%   eon_microstates --option value scriptname.m
% or on the Linux command line
%   eon_microstates.sh <MATLABROOT> --option value scriptname.m
% The options and their values are automaticallly made available as local
% variables in the script execution environment.
%
%

% this function uses assignin/evalin. The alternative is to use assign/eval
% but then the script execution might collide with local variables inside this
% eon_microstates function
workspace = 'caller';

% separate the --options from the filenames
[options, varargin] = getopt(varargin{:});

if any(strcmp(options(1:2:end), 'version'))
  varargin = {};
end

for i=1:length(varargin)
  fname = varargin{i};
  
  
  [p, f, ext] = fileparts(fname);
  
  switch ext
    case '.m'
      if ~exist(fname, 'file')
        error('The script %s cannot be found\n',fname);
      end
      
      fid = fopen(fname);
      if fid == -1, error('Cannot open %s',fname); end
      S = fscanf(fid,'%c');
      fclose(fid);
      
      % capture all screen output in a diary file
      diary off
      diaryfile = tempname;
      diary(diaryfile);
      
      try
        % ensure that subsequent scripts do not interfere with each other
        % keep the eon_default global variable
        global eon_default
        localcopy = eon_default;
        evalin(workspace,'clear all');
        eon_default = localcopy;
        
        % make the options available as local variables
        for j=1:2:length(options)
          key = options{j};
          val = options{j+1};
          
          if ismember(val(1), {'[', '{'})
            % the value is a string that represents an array
            evalin(workspace, sprintf('%s = %s;', key, val));
          elseif ismember(val(1), {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '+'}) && all(ismember(cellstr(val(:)), {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '+', '.', 'e'}))
            % the value is a string that represents a number
            evalin(workspace, sprintf('%s = %s;', key, val));
          else
            assignin(workspace, key, val);
          end
        end
                
        % evaluate this script
        evalin(workspace,S);
                
      catch err        
        fprintf('Execution failed: %s\n', fname);
        rethrow(err);
      end
      
    otherwise
      error('Unknown input format for %s, should be *.m \n',fname);
  end % switch type of input argument
  
  % force close all figures that were created
  close all
  
  diary off
  fid = fopen(diaryfile);
  if fid == -1, error('Cannot open %s',diaryfile); end
  S = fscanf(fid,'%c');
  fclose(fid);
  delete(diaryfile);
    
end % for each of the input arguments


