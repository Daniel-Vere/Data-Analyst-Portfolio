#!/usr/bin/env python
# coding: utf-8

# In[202]:


from bs4 import BeautifulSoup
import requests


# In[193]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_cities'

page = requests.get(url)

soup = BeautifulSoup(page.text, 'html')


# In[194]:


table = soup.find('table', class_ = 'static-row-numbers plainrowheaders vertical-align-top sticky-header sortable wikitable')


# In[195]:


column_titles = table.find_all('th', scope = 'col')


# In[196]:


column_titles_stripped = [titles.text.strip() for titles in column_titles]


# In[197]:


column_titles_fixed = column_titles_stripped[0:3] + column_titles_stripped[6:16]
column_titles_fixed2 = [column_titles.split('[',1)[0] for column_titles in column_titles_fixed]


# In[198]:


import pandas as pd

df = pd.DataFrame(columns = column_titles_fixed2)


# In[199]:


rows_names = table.find_all('tr')
rows_stripped = [ rows.text.strip() for rows in rows_names]
rows_split = [ rows.split('\n', 1)[0]  for rows in rows_stripped]
rows_fixed = rows_split[3:]


# In[200]:


i=0
for row in rows_names:
        rows_data = row.find_all('td')
        rows_data_stripped = [data.text.strip() for data in rows_data]
        individual_row_data = [data.split('[', 1)[0] for data in rows_data_stripped]
        length = len(df)
        if individual_row_data != []:
            individual_row_data.insert(0,rows_fixed[i])
            df.loc[length] = individual_row_data
            i += 1
df


# In[201]:


#df.to_csv(r'D:\User\Desktop\LargestCities.csv', index = False)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




