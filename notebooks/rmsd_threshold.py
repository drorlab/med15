#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


# In[2]:


recs = ['ABD1', 'KIX']
names = ['Pdr1AD', 'Gal4', 'Ppr1', 'Pip2']


# In[6]:


for rec in recs:
    for name in names:
        cluster_path = '../' + rec + '/' + name + '/analysis/top500'
        all_path = '../' + rec + '/' + name + '/analysis/all'
        cluster_results = pd.read_csv(cluster_path, delimiter=' ')
        all_results = pd.read_csv(all_path, delimiter=' ')
        rmsd_thresh = max(all_results.sort_values('reweighted_sc').iloc[1:10].mean()['rms'], 2.0)
        print(f'Suggested clustering rmsd threshold for {rec:5} {name:8}: {rmsd_thresh:5.1f}')


# In[ ]:




