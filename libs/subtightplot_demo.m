% subtightplot is a merger of Pekka Kumpulainen's tight_subplot and Nikolay
% S.'s subplot_tight. It extends the former, which supports asymmetric
% subplots, to allow for variable margins in addition to gaps, as in the
% latter.
% 
% Existing scripts that currently call Matlab's builtin subplot can be
% adapted with minimal modification by issuing the following command
% upfront:
%   subplot = @(m,n,p) subtightplot(m,n,p,opt{:});
% where opt = {gap, width_h, width_w} describes the inner and outer
% spacings. The screenshot attached shows demo results for examples
% modified from the subplot documentation.
% 
% For axes ticks and labels and locations, see Matlab's axes properties
% documentation, or try Eran Ofek's subplot1 for a more guided approach.
% 
% If you prefer a post-processing solution, see Richard Crozier's tightfig
% or Aditya's spaceplots.
% 
% Alon Geva's subplotplus is interesting for making complicated subplot
% arrangements; apparently gaps and margins are fixed. Aslak Grinsted's
% subaxis is based on a richer, more expressive HTML jargon. Joris
% Kampman's subplot_grid is a colossal 3500+ line object-based
% implementation. These high-end alternatives are a departure from the
% built-in subplot's calling syntax, though.
% 
% For an overview, please see the Dec 21st, 2012 post on the File Exchange
% Pick of the Week Blog, titled "Figure margins, subplot spacings, and
% more…".
% 


make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~make_it_tight,  clear subplot;  end

%% Upper and Lower Subplots with Titles
income = [3.2,4.1,5.0,5.6];
outgo = [2.5,4.0,3.35,4.9];
subplot(2,1,1); plot(income)
title('Income')
subplot(2,1,2); plot(outgo)
title('Outgo')

%% Subplots in Quadrants
figure
subplot(2,2,1)
text(.5,.5,{'subplot(2,2,1)';'or subplot 221'},...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,2)
text(.5,.5,{'subplot(2,2,2)';'or subplot 222'},...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,3)
text(.5,.5,{'subplot(2,2,3)';'or subplot 223'},...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,4)
text(.5,.5,{'subplot(2,2,4)';'or subplot 224'},...
    'FontSize',14,'HorizontalAlignment','center')

%% Asymmetrical Subplots
figure
subplot(2,2,[1 3])
text(.5,.5,'subplot(2,2,[1 3])',...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,2)
text(.5,.5,'subplot(2,2,2)',...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,4)
text(.5,.5,'subplot(2,2,4)',...
    'FontSize',14,'HorizontalAlignment','center')

%%  
figure
subplot(2,2,1:2)
text(.5,.5,'subplot(2,2,1:2)',...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,3)
text(.5,.5,'subplot(2,2,3)',...
    'FontSize',14,'HorizontalAlignment','center')
subplot(2,2,4)
text(.5,.5,'subplot(2,2,4)',...
    'FontSize',14,'HorizontalAlignment','center')

%% Plotting Axes Over Subplots
figure
y = zeros(4,15);
for k = 1:4
    y(k,:) = rand(1,15);
    subplot(2, 2, k)
    plot(y(k,:));
end
hax = axes('Position', [.35, .35, .3, .3]);
bar(hax,y,'EdgeColor','none')
set(hax,'XTick',[])
