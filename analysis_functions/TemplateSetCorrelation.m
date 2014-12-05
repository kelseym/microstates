
function similarityMatrix = TemplateSetCorrelation(sortedMasterMicrostateTemplates, microstateTemplatesToMatch)
  for mstrIndx=1:size(sortedMasterMicrostateTemplates,1)
    for tmtchIndx=1:size(microstateTemplatesToMatch)
      similarityMatrix(mstrIndx,tmtchIndx) = corr(sortedMasterMicrostateTemplates(mstrIndx,:)', microstateTemplatesToMatch(tmtchIndx,:)');
    end
  end
end


