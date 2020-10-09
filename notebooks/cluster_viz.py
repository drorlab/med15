#!/usr/bin/env python
# coding: utf-8

# In[1]:


import glob
import os

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


# In[23]:


root_dir = '/Users/raphael/Dropbox/med15'

# rec = 'ABD1'
# rec = 'ABD1-fixedlen'
# rec = 'KIX'
# rec = 'KIX_9mers'
rec = 'KIX_mutants'

# Get AD names based on subfolders with analysis folder.
names = [os.path.basename(os.path.dirname(x)) 
         for x in glob.glob(root_dir + '/' + rec + '/*/analysis')]


# In[19]:


def load_results(rec, name):
    # Dynamic RMSD cutoff
    dynamic = False
    
    if dynamic:
        cluster_path = root_dir + '/' + rec + '/' + name + '/analysis-dynamic/top500'
        all_path = root_dir + '/' + rec + '/' + name + '/analysis-dynamic/all'
        output_path = root_dir + '/' + rec + '/' + name + '/viz-dynamic'
    else:
        cluster_path = root_dir + '/' + rec + '/' + name + '/analysis/top500'
        all_path = root_dir + '/' + rec + '/' + name + '/analysis/all'
        output_path = root_dir + '/' + rec + '/' + name + '/viz'
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    print('loading ' + cluster_path)
    cluster_results = pd.read_csv(cluster_path, delimiter=' ')
    all_results = pd.read_csv(all_path, delimiter=' ')
    return output_path, cluster_results, all_results


# In[20]:


def cluster_fig(cluster_results, name, output_path):
    best_clusters = cluster_results.groupby('cluster').apply(lambda x: x['reweighted_sc'].min()).sort_values().index.values
    LABEL_COLOR_MAP = {
        best_clusters[0]: 'r',
        best_clusters[1]: 'm',
        best_clusters[3]: 'b',
        best_clusters[4]: 'g',
        best_clusters[5]: 'y',
     #   6: 'c',
    }

    cluster_results['color'] = cluster_results['cluster'].apply(lambda x: LABEL_COLOR_MAP[x] if x in LABEL_COLOR_MAP else 'k')
    tmp = cluster_results[cluster_results['color'] != 'k']
    plt.figure(figsize=(8, 8))
    plt.scatter(tmp['reweighted_sc'], tmp['rms'], c=tmp['color'])
    plt.ylabel('rms')
    plt.xlabel('Rosetta score')
    plt.title(name)
    if output_path is not None:
        plt.savefig(output_path + '/cluster_viz_{:}.png'.format(name), dpi=300)


# In[21]:


def all_fig(all_results, name, output_path):
    plt.figure(figsize=(8, 8))
    plt.scatter(all_results['rms'], all_results['reweighted_sc'], s=2)
    plt.xlabel('rms')
    plt.ylabel('Rosetta score')
    plt.ylim(all_results['reweighted_sc'].min() - 5, np.percentile(all_results['reweighted_sc'],99))
    plt.title(name)
    if output_path is not None:
        plt.savefig(output_path + '/all_viz_{:}.png'.format(name), dpi=300)


# In[24]:


for name in names:
    print(name)
    output_path, cluster_results, all_results = load_results(rec, name)
    cluster_fig(cluster_results, name, output_path)
    all_fig(all_results, name, output_path)
    plt.close('all')


# In[27]:


rec = 'KIX'
name = 'Pdr1ADrep'
_, cluster_results, all_results = load_results(rec, name)


# In[28]:


cluster_fig(cluster_results, name, None)
plt.show()
all_fig(all_results, name, None)
plt.show()


# In[29]:


cluster_results.sort_values('reweighted_sc')


# In[19]:


cluster_results['cluster'].value_counts()


# In[22]:


name


# In[ ]:




