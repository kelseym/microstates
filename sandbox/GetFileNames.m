%% GetFileNames
%   Edit this file to specify a set of scans to load into main processing functions


function files = GetFileNames()

  baseDirectory = GetLocalDataDirectory();

  files = {};
  % McD03 Wake Grid info
  file.channelList = [1:32] ;
  file.badChannels = [] ;
  file.fileName = [baseDirectory 'McD03 anon EDF/McD03_wake_1726-173.edf'];
  file.name = 'McD03 Wake';
  files{end+1} = file;
  
  % McD03 SWS Grid info
  file.channelList = [1:32] ;
  file.badChannels = [] ;
  file.fileName = [baseDirectory 'McD03 anon EDF/McD03_SWS_0113-0118.EDF'];
  file.name = 'McD03 SWS';
  files{end+1} = file;
  
end
