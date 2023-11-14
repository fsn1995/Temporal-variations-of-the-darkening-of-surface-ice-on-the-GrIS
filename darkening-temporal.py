#%%
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_theme(style="darkgrid", font="Arial", font_scale=2)
# %%
dfaws = pd.read_excel("promice\icestats.xlsx", sheet_name="statPROMICE")
dfhsa = pd.read_excel("promice\icestats.xlsx", sheet_name="statHSA")
# %%
fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
# sns.regplot(data=dfaws, x="duration_bareice", y="albedo", label="bare ice")
sns.regplot(data=dfaws, x="duration_darkice", y="albedo", label="dark ice")
ax.set(xlabel="duration (days)", ylabel="albedo")
fig.savefig("print\darkening-temporal.png", dpi=300, bbox_inches="tight")
fig.savefig("print\darkening-temporal.pdf", dpi=300, bbox_inches="tight")
# fig.legend()
# slope, intercept, r_value, p_value, std_err = stats.linregress(dfaws.duration_bareice.values, dfaws.albedo.values)
# print('bare ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))
slope, intercept, r_value, p_value, std_err = stats.linregress(dfaws.duration_darkice.values, dfaws.albedo.values)
print('dark ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))

fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
# sns.regplot(data=dfhsa, x="duration_bareice", y="albedo", label="bare ice")
sns.regplot(data=dfhsa, x="duration_darkice", y="albedo", label="dark ice")
ax.set(xlabel="duration (days)", ylabel="albedo")
# fig.legend()
# slope, intercept, r_value, p_value, std_err = stats.linregress(dfhsa.duration_bareice.values, dfhsa.albedo.values)
# print('bare ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))
slope, intercept, r_value, p_value, std_err = stats.linregress(dfhsa.duration_darkice.values, dfhsa.albedo.values)
print('dark ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))
# %%
fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
sns.regplot(data=dfaws, x="dbratio", y="albedo", label="PROMICE", order=2)
sns.regplot(data=dfhsa, x="dbratio", y="albedo", label="HSA", order=2)
ax.set(xlabel="dbratio)", ylabel="albedo")
fig.legend()


# %%
dfaws = pd.read_excel("promice\icestats20092017.xlsx", sheet_name="statPROMICE")
index = (dfaws["aws"]== "kan_l") | (dfaws["aws"]== "kan_m") | (dfaws["aws"]== "kan_u") | (dfaws["aws"]== "mit") | (dfaws["aws"]=="nuk_k") | (dfaws["aws"]== "nuk_l") | (dfaws["aws"]== "nuk_n") | (dfaws["aws"]== "nuk_u") | (dfaws["aws"]== "qas_a") | (dfaws["aws"]== "qas_l") | (dfaws["aws"]== "qas_m") | (dfaws["aws"]== "qas_u") | (dfaws["aws"]== "nuk_l") | (dfaws["aws"]== "tas_a") | (dfaws["aws"]== "tas_l") | (dfaws["aws"]== "tas_u")
dfaws = dfaws[index]
# dfhsa = pd.read_excel("promice\icestats.xlsx", sheet_name="statHSA")
# %%
fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
sns.regplot(data=dfaws, x="duration_bareice", y="albedo")
# sns.regplot(data=dfaws, x="duration_darkice", y="albedo", label="dark ice")
ax.set(xlabel="duration (days)", ylabel="albedo")
# fig.legend()
slope, intercept, r_value, p_value, std_err = stats.linregress(dfaws.duration_bareice.values, dfaws.albedo.values)
print('bare ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))
# slope, intercept, r_value, p_value, std_err = stats.linregress(dfaws.duration_darkice.values, dfaws.albedo.values)
# print('dark ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))

# fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
# sns.regplot(data=dfhsa, x="duration_bareice", y="albedo", label="bare ice")
# sns.regplot(data=dfhsa, x="duration_darkice", y="albedo", label="dark ice")
# ax.set(xlabel="duration (days)", ylabel="albedo")
# fig.legend()
# slope, intercept, r_value, p_value, std_err = stats.linregress(dfhsa.duration_bareice.values, dfhsa.albedo.values)
# print('bare ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))
# slope, intercept, r_value, p_value, std_err = stats.linregress(dfhsa.duration_darkice.values, dfhsa.albedo.values)
# print('dark ice duration: \ny={0:.4f}x+{1:.4f}\nOLS_r:{2:.2f}, p:{3:.3f}'.format(slope,intercept,r_value,p_value))
# %%
fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
sns.regplot(data=dfaws, x="dbratio", y="albedo", label="PROMICE", order=2)
sns.regplot(data=dfhsa, x="dbratio", y="albedo", label="HSA", order=2)
ax.set(xlabel="dbratio)", ylabel="albedo")
fig.legend()

# %%
