%% Topo image generator
%   Show topographic heat map on grid image
%   Input: background image, ft layout, microstate topo(s)

backgroundImage = '/Users/Kelsey/Projects/McDonnell/MCD12_release/MCD12_release/McD12_grid_image.png';
layout = '/Users/Kelsey/Projects/McDonnell/MCD12_release/MCD12_release/McD12_grid_image_lay.mat';

% function topoImageGenerator(microstateTemplates, backgroundImage, layout)


% %% Prepare and display microstate templates
% cfg = [];
% cfg.image = backgroundImage;
% lay = ft_prepare_layout(cfg);
% cfg = [];
% cfg.image = backgroundImage;
% cfg.layout = lay;
% ft_layoutplot(cfg);


load(layout)
bckgrndI = imread(backgroundImage);
% Setup colormap to span from min to max values in the topo maps
minTopoValue = min(min(microstateTemplates));
maxTopoValue = max(max(microstateTemplates));
% setup red/blue color pallete
colorPalette = zeros(64,3);
colorPalette(:,1) = ((0:1:63)/63)';
colorPalette(:,3) = ((63:-1:0)/63)';

% Plot a figure for each template in microstateTemplates
numTemplates = size(microstateTemplates,1);
numSensors = size(microstateTemplates, 2);
for tmplti=1:numTemplates
  figure;
  bgh = imagesc(bckgrndI);
  for snsri=1:numSensors
    yLmts = get(gca,'ylim');
    yFlip = yLmts(2)-yLmts(1);
    hold on
    x= lay.pos(snsri,1);
    y= lay.pos(snsri,2);
    % compute colorPallete index based on topo value
    normValue = (microstateTemplates(tmplti, snsri)-minTopoValue)/(maxTopoValue-minTopoValue);
    colorIndex = ceil(normValue*63)+1;
    plot([x x],[yFlip-y yFlip-y],'o','MarkerSize',20,...
      'MarkerFaceColor',colorPalette(colorIndex,:),'MarkerEdgeColor',colorPalette(colorIndex,:));
  end
end

