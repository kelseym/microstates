%% Given a set of microstate templates, cluster templates to find close relatives and outliers

clear;
outputDir = GetLocalOutputDirectory();
load([outputDir '/dataStructs.mat']);

cfg = [];
cfg.layout = '4D248.mat';
lay = ft_prepare_layout(cfg);

% Compare all template maps to each other
Find sensors that exist in all scans
labelIntersection = dataStructs{1}.label;
for scni=2:length(dataStructs)
  labelIntersection = intersect(labelIntersection, dataStructs{scni}.label);
end

% Combine all microstateTemplates for the purpose of template clustering
microstateTemplates = [];
for scni=1:1%length(dataStructs)
  %[labelIds,~] = match_str(dataStructs{scni}.label, labelIntersection);
  microstateTemplates = cat(1, microstateTemplates, dataStructs{scni}.microstateTemplates{1});
end
% calculate correlation distance between templates
corrDist = pdist(microstateTemplates, 'correlation');
clustTree = linkage(corrDist, 'average');
cophenet(clustTree,corrDist);

%% Plot dendogram and topographys
figure;
subplot(3,6,1:12)
[h,nodes,outperm] = dendrogram(clustTree,0);
for i=1:size(microstateTemplates,1)
  subplot(3,6,12+i);
  tmplti = outperm(i);
  PlotMicrostateTemplate(microstateTemplates(tmplti,:), dataStructs{1}.label, lay);
end

