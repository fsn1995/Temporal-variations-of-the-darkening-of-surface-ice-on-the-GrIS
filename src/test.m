df = readtable("..\data\AWS_reprocessed.csv");
[df.y, df.m, df.d] = ymd(df.time);

%%
figure;
histogram(df.y)
figure;
histogram(df.m);

%%
load("C:\Users\au686295\GitHub\PhD\Temporal-variations-of-the-darkening-of-surface-ice-on-the-GrIS\data\barefruequncy.mat");


f1 = figure;
f1.Position = [3003 371 563 703];
greenland('k');
hold on
mapshow(bare_frequency, Rmask, 'DisplayType', 'surface');
colormap(cmocean('-curl', 'pivot', 10));
% colormap(ax8, crameri('-vik', 'pivot', 10));
clim([1, 22]);
axis off;
scalebarpsn('location','se');
c8 = colorbar("eastoutside");
c8.Label.String = "bare ice frequency (years)";
ax8_1 = axes(f1, 'Position', [gca().Position(1)+gca().Position(3)/1.9 ...
gca().Position(2)+gca().Position(4)/3 ...
gca().Position(3)/6 gca().Position(4)/3]);
boxchart(ax8_1, bare_frequency(:), ...
'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
set(ax8_1, 'XTickLabel', [], 'Color', 'None', 'FontSize', 8);
fontsize( 16, "points");

exportgraphics(f1, "..\print\barefrequency.pdf", "Resolution", 300);