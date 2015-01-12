
% Find sensors that exist in all scans
function sensorLabelIntersection = GetSensorLabelIntersection(dataStructs)

sensorLabelIntersection = dataStructs{1}.label;
for scni=2:length(dataStructs)
  sensorLabelIntersection = intersect(sensorLabelIntersection, dataStructs{scni}.label);
end
