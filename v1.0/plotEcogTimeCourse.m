% plot ECoG timecourse
figure, hold on;
title('McD03 S1-S32 Wake');
trialData1 = trialData{1};
maxamp = max(max(trialData1));
minamp = min(min(trialData1));
yoffset = ((0:31)*(maxamp-minamp))';
for i=1:size(trialData1,1)
    offset = yoffset(i);
    tmcrs = trialData1(i,:)+offset;
    plot(1:size(trialData1,2), tmcrs,'k');
end
ylabel('');
xlabel('sample');

% gfp peak
tLocs = trialTime{1}(gfpPkLocs{1});
for i=1:length(tLocs)
    plot([tLocs(i) tLocs(i)], [minamp maxamp+max(yoffset)], 'g-','LineWidth',0.25);
end