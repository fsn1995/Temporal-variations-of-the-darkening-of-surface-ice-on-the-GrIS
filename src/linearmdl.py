#%% import libraries
import numpy as np
import matplotlib.pyplot as plt
import vaex as vx
import seaborn as sns
from scipy import stats
sns.set_theme(style="whitegrid", font="Arial", font_scale=2)
# %%
# Load data
df1 = vx.from_csv("/data/shunan/data/albedospatial/HSA_data.csv")
slope, intercept, r_value, p_value, std_err = stats.linregress(df1.bare_duration.values, df1.albedo_avg.values)

#%% Plot
fig, ax = plt.subplots(figsize=(8,7))
plt.plot(np.array([0,92]), slope * np.array([0,92]) + intercept, color='red') # ols regression etm+ vs oli
df1.viz.heatmap(df1.bare_duration, df1.albedo_avg, what = np.log(vx.stat.count()), colormap="viridis")
# ax.set_aspect('equal', 'box')
ax.set(xlabel='bare ice duration (days)', ylabel='albedo')
fig.savefig("/data/shunan/github/Temporal-variations-of-the-darkening-of-surface-ice-on-the-GrIS/print/HSA_linear.png", dpi=300)
# %%
# df = vx.from_csv("/data/shunan/data/albedospatial/S3_data.csv")
# #%%
# slope, intercept, r_value, p_value, std_err = stats.linregress(df.bare_duration.values, df.albedo_avg.values)
# df.viz.heatmap(df.bare_duration, df.albedo_avg, what = np.log(vx.stat.count()), colormap="viridis")
# plt.plot(np.array([0,92]), slope * np.array([0,92]) + intercept, color='red') # ols regression etm+ vs oli
# # %%
