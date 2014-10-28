%% Microstate template similarity measure
%   Measure similarity between N-dimensional templates.
%   Optionally, compare templates to a zero array. i.e. distance to origin
%   Metric can be euclidean distance or correlation between templates.
%   Default behaviour ignores polarity, options to disable this.

%   Input:
%   microstateTemplates = NxS matrix where each row defines microstates template over S sensors
%   cfg.compareto = 'eachother' (default), 'zero'
%   cfg.similaritymetric = 'euclidean' (default), 'correlation'
%   cfg.ignorepolarity = 'yes' (default), 'no'

function similarityMatrix = TemplateSimilarity(microstateTemplates, cfg)

  % get the options
  compareTo = ft_getopt(cfg, 'compareto', 'eachother');
  similarityMetric = ft_getopt(cfg, 'similaritymetric','euclidean');
  ignorePolarity = ft_getopt(cfg, 'ignorepolarity', 'yes');

  if strcmp(compareTo, 'zero')
    cmpA = zeros(1, size(microstateTemplates,2));
    cmpB = microstateTemplates;
  elseif strcmp(compareTo, 'eachother')
    cmpA = microstateTemplates;
    cmpB = microstateTemplates;
  else
    error('Unknown compareto option');
  end
  
  similarityMatrix = zeros(size(cmpA,1), size(cmpB,1));
  if strcmp(similarityMetric, 'euclidean')
    for i=1:size(cmpA,1)
      for j=1:size(cmpB,1)
        similarityMatrix(i,j) = norm(cmpA(i)-cmpB(j));
      end
    end
  elseif strcmp(similarityMetric, 'correlation')
    similarityMatrix = corr(microstateTemplates');
  else
    error('Unknown similaritymetric option');
  end
  
  % If comparing to zero array, 
  
end

