function templateCorrelations = microstateGetTemplateCorrelations(trialData, compressedSlidingWindowTemplates, templateStartIndices)

numMicrostates = size(compressedSlidingWindowTemplates,3);

templateCorrelations = zeros(numMicrostates,size(trialData,2));
templateStartIndices(end+1) = size(trialData,2);
for j=1:numMicrostates
%     tic;
%     templates = expandedSlidingWindowTemplates(:,:,j)';
%     for k=1:size(trialData,2)
%         templateCorrelations(j,k) = corr(templates(:,k),trialData(:,k));
%     end
%     toc;
%     tic;
    templates = compressedSlidingWindowTemplates(:,:,j)';
    for k=1:(length(templateStartIndices)-1)
        template = templates(:,k);
        templateCorrelations(j,templateStartIndices(k):templateStartIndices(k+1)) = corr(template,trialData(:,templateStartIndices(k):templateStartIndices(k+1)));
    end
%     toc;
end
