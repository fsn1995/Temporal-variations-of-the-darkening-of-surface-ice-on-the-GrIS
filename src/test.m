% close all
% dfaws = readtable("..\stat\icestats.xlsx", "Sheet", "AWS");
% % dfaws = dfaws(dfaws.year>2018,:);
% dfhsa = readtable("..\stat\icestats.xlsx", "Sheet", "HSA");
% scatter(dfhsa.hsa, dfaws.albedo, [], dfhsa.num, "filled");
% % plot(mdl);
% xlim([0.15 0.7])
% ylim([0.15 0.7])
% pbaspect([1 1 1])
% r1 = refline(1, 0);
df = readtable("..\stat\icestats.xlsx", "Sheet", "ablation");
df(df.slope>0, :) = [];
df.darkspeed = daysact(df.bare_1stday, df.dark_1stday);
df(df.slope<-0.3, :) = [];
%% ablation
figure;
gscatter(df.bare_n, df.slope, df.awsgroup);
% figure;
% gscatter(dfaws.duration_bareice, dfaws.ablation, dfaws.awsgroup);
% hold on
% mdl = fitlm(dfaws.duration_bareice, dfaws.ablation);
% disp(mdl)
% 
% figure;
% gscatter(dfaws.duration_darkice, dfaws.ablation, dfaws.awsgroup);
% hold on
% mdl = fitlm(dfaws.duration_darkice, dfaws.ablation);
% disp(mdl)
% % refline
%% how fast ice became dark
% figure;
% dfaws.darkspeed = daysact(dfaws.bare_1stday, dfaws.dark_1stday);
% % figure;
% % h = heatmap(dfaws, "aws", "year", "ColorVariable", "darkspeed");
% figure;
% boxchart(categorical(dfaws.awsgroup), dfaws.darkspeed, "Notch", "on");
% hold on
% swarmchart(categorical(dfaws.awsgroup), dfaws.darkspeed);
% figure;
% boxchart(categorical(dfaws.awsgroup), dfaws.duration_darkice, "Notch", "on");
% figure;
% boxchart(categorical(dfaws.awsgroup), dfaws.darkspeed)
% sortx(h, )
% dfhsa.duration_bareice = daysact(dfhsa.bare_1stday, dfhsa.bare_lastday);
% dfhsa.duration_darkice = daysact(dfhsa.dark_1stday, dfhsa.dark_lastday);
% dfhsa.duration_bareice_corrected = dfhsa.duration_bareice./(dfhsa.num/92);
% dfhsa.duration_darkice_corrected = dfhsa.duration_darkice./(dfhsa.num/92);
% figure
% mdl = fitlm(dfhsa.duration_bareice, dfaws.duration_bareice)
% % mdl = fitlm(dfhsa.duration_bareice_corrected, dfaws.duration_bareice)
% plot(mdl);
% % 
% figure
% mdl = fitlm(dfhsa.duration_darkice, dfaws.duration_darkice)
% % mdl = fitlm(dfhsa.duration_darkice_corrected, dfaws.duration_darkice)
% plot(mdl);
% % scatter(dfaws.duration_darkice, dfhsa.duration_darkice_corrected);
% % refline
% figure
% % mdl = fitlm(dfhsa.hsa, dfaws.albedo)
