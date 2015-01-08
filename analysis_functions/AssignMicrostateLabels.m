%% Assign microstate labels
%  Given a Fieldtrip data structure and cfg.microsateTemplates
%  compute correlation with timecourse data at each sample point.
%  Generate a label (1..N) for each time point which corresponds to the
%  maximally correlated template.

%  Input data should not be changed, except for the addition of additional
%  structure components .templateCorrelations and .microstateIndices

% find microstate sequence in electroneurophys data
function data = AssignMicrostateLabels(cfg, data)


  % ensure that the required options are present
  cfg = ft_checkconfig(cfg, 'required', {'microstateTemplates'});

  % get the options
  microstateTemplateSet = ft_getopt(cfg, 'microstateTemplates');
 
  templateCorrelations = {};
  microstateIndices = {};
  for trli=1:length(data.trial)
    % Check data type and size of microstateTemplates.
    if isa(microstateTemplateSet,'double') % use a single template set for all trials
      microstateTemplates = microstateTemplateSet;
    elseif isa(microstateTemplateSet,'cell') && length(microstateTemplateSet) == 1 % use a single template set for all trials, but unpack it from the cell array first
      microstateTemplates = microstateTemplateSet{1};
    elseif isa(microstateTemplateSet,'cell') && length(microstateTemplateSet) == length(data.trial) % use a template set for each trials
      microstateTemplates = microstateTemplateSet{trli};
    else
      error('cfg.microstateTemplate parameter size mismatch.  Must be double matrix, 1x1 cell array, or 1xNumTrials cell array');
    end
    % Compute correlation between templates and original signal
    templateCorrelations{trli} = zeros(size(microstateTemplates,1),size(data.trial{trli},2));
    for tmpltj=1:size(microstateTemplates,1)
        template = microstateTemplates(tmpltj,:)';
        templateCorrelations{trli}(tmpltj,:) = abs(corr(template,data.trial{trli}(:,:)));
    end
    % select template index with maximum correlation to the data at each sample point
    [~, microstateIndices{trli}] = max(templateCorrelations{trli},[],1);
  end
  
  data.templateCorrelations = templateCorrelations;
  data.microstateIndices = microstateIndices;

end
