#%%
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_theme(style="darkgrid", font="Arial", font_scale=2)
# %%
df = pd.read_excel("promice\icestats.xlsx", sheet_name="stat")
# %%
fig, ax = plt.subplots(figsize=(5,5)) #figsize=(8,7)
sns.regplot(data=df, x="duration_bareice", y="albedo", label="bare ice")
sns.regplot(data=df, x="duration_darkice", y="albedo", label="dark ice")
ax.set(xlabel="duration (days)", ylabel="albedo")
fig.legend()
# %%

# %%
