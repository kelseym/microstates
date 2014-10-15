%% OpenAndPreprocess
%   Use the standard Fieldtrip mechinism to open and preprocesses files
%   Returns a cell array of structures

function data = OpenAndPreprocess(files)

  data = {};
  if iscell(files)
    for i=1:length(files)
      data{end+1} = OpenAndPreprocessOnce(files{i});
    end
  elseif isstruct(files)
    data{end+1} = OpenAndPreprocessOnce(files);
  else
    error('File structure passed with invalid fileName element');
  end

end



function dataout = OpenAndPreprocessOnce(file)
  if isstruct(file) && isfield(file, 'fileName')
    % open
    cfg = [];
    cfg.datafile = file.fileName;
    cfg.continuous = 'yes';
    dataout = ft_preprocessing(cfg);

    % select grid channels and remove bad channels
    if isfield(file, 'channelList')
      cfg = [];
      cfg.channel = file.channelList;
      if isfield(file, 'badChannels')
        cfg.channel(file.badChannels) = [];
      end
      dataout = ft_selectdata(cfg, dataout);
    end
    
    % store name (scan label)
    if isfield(file, 'name')
      dataout.name = file.name;
    end

    % band filter preprocess
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [59 61; 119 121; 179 181];
    cfg.demean = 'yes';
    cfg.detrend = 'yes';
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [1.0 40.0];
    dataout = ft_preprocessing(cfg, dataout);
  else
    error('File structure passed with invalid fileName element');
  end
end
