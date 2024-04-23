#!/usr/bin/env python
# coding: utf-8

# ## Will Earley Script
# 
# Thank you for this opportunity. I really enjoyed putting together this assignment. I focused on explainability here so that is why some commands are a bit more explicit or redundant than I typically would implement. Thanks again!

# In[51]:


# import libraries and read in data
import pandas as pd

owners = pd.read_csv('/Users/williamearley/Broncos/owners.csv')
pets = pd.read_csv('/Users/williamearley/Broncos/pets.csv')
procedure_details = pd.read_csv('/Users/williamearley/Broncos/procedure_details.csv')
procedures = pd.read_csv('/Users/williamearley/Broncos/procedures.csv')


# In[2]:


# Exploring the data
owners.head(5)


# In[4]:


pets.head(5)


# In[6]:


procedure_details.head(5)


# In[7]:


procedures.head(5)


# In[9]:


owners.shape


# In[8]:


pets.shape


# In[10]:


procedure_details.shape


# In[11]:


procedures.shape


# # Problem 1: What is the name of the oldest dog in Southfield

# In[24]:


# Merge pet and owner dataframes

pets_owners = pd.merge(pets, owners, on="OwnerID", how="outer")


# In[26]:


southfield = pets_owners[pets_owners['City'] == 'Southfield']
southfield = southfield.sort_values(by='Age', ascending=False)


# In[27]:


pets_owners.shape


# In[28]:


southfield.head(5)


# Here we see, the oldest dog is Crockett, at 12 years old.  

# # Problem 2: What is the average (mean) number of pets per city?

# In[38]:


# Using previous dataframe pets_owners and groupby
mean_pets = pets_owners.groupby("City").size().mean()
mean_pets


# In[50]:


# Double checking a bit more basic way
cities_count = pets_owners["City"].unique()
pets_count = pets_owners["PetID"].unique()
mean_pets_doublecheck = len(pets_count) / len(cities_count)
mean_pets_doublecheck


# # Problem 3: Which owner spend the most on procedures for their pet(s)?

# In[65]:


# We need to do some merging here, all dataframes will be involved as they each hold a piece of the puzzle!

merged = pd.merge(pets, procedures, on="PetID", how='left')
merged = pd.merge(merged, owners, on="OwnerID", how='left')
merged = pd.merge(merged, procedure_details, on=['ProcedureType', "ProcedureSubCode"], how='left')

# Next we add up how much each owner spent on their pet
owner_total = merged.groupby(["OwnerID", 'Name_y', "Surname"])['Price'].sum().reset_index()

# Finally, we find the name of the person who spent the most on their pet(s)
highest_spender = owner_total.loc[owner_total['Price'].idxmax()]
highest_spender


# # Problem 4: How many owners spent 20 dollars or more on procedures for their pets?

# In[70]:


# Luckily we already have a data frame well designed to tackle this problem. We can easily just see how many owners
# spent 20 or more dollars on their pets.

big_spenders = (owner_total['Price'] >= 20).sum()
big_spenders


# # Problem 5: How many owners have at least two different kinds of pets (e.g. a dog and a cat)?

# In[80]:


# First we are going to group by OwnerID and Kind, only including unique values so we can see all the 
# owners that have different kinds of pets. 

owners_pet_counts = pets.groupby("OwnerID")["Kind"].nunique()


# In[82]:


# Now we just need to see how man of these are greater than or equal to 2

two_or_more = owners_pet_counts[owners_pet_counts >= 2]

len(two_or_more)


# # Problem 6: How many owners have pets where the first letter of their name (OwnerName) matches the first letter of their pet's name (PetName)? E.g. Cookie and Charles.

# In[89]:


# Here we just need to merge pets and owners and then use str to match the letters.

pet_owners = pd.merge(pets, owners, on="OwnerID", how="inner")
cookie_charles_df = pet_owners[pet_owners['Name_x'].str[0].str.lower() == pet_owners["Name_y"].str[0].str.lower()]
cookie_charles = cookie_charles_df['OwnerID'].nunique()
cookie_charles


# # Problem 7: What percentage of pets received a vaccination?

# In[118]:


# Here we find out how many unique pets had a vaccination, and then divide that by the total number of pets.

vaccinated = procedures[procedures['ProcedureType'].str.contains('VACCINATIONS', case=False)]
unique_vac = vaccinated['PetID'].nunique()
unique_pets = pets['PetID'].nunique()
percent_vac = (unique_vac / unique_pets) * 100
percent_vac


# # Problem 8: What percentage of cities have more male pets than female pets?

# In[124]:


# Here we just group the pet_owners df by city and count each gender in each city.
# We see how many times the city has more males, and then calculate the overall percentage

city_pet_counts = pet_owners.groupby('City')['Gender'].value_counts().unstack().fillna(0)
more_males = (city_pet_counts['male'] > city_pet_counts['female']).sum()
total_cities = len(city_pet_counts)
percent = (more_males / total_cities) * 100
percent


# # Problem 9: Which city's pet sample is made up of exactly 70% dogs? The answer is case sensitive, so please match the value for City exactly.
# 

# In[127]:


# To complete this final question, we just need to groupby the city and map where "Kind" is a dog. 
# Then we just see which city is equal to 70%

city_pet_percent = pet_owners.groupby('City')['Kind'].apply(lambda x: (x == 'Dog').mean() * 100)
seventy_city = city_pet_percent[city_pet_percent == 70].index.tolist()
seventy_city


# In[132]:


# Double checking visually because I REALLY hope this opportunity works out
# I love Denver and the Broncos organization, we see here, 7/10 pets in Grand Rapids are dogs

gr = pet_owners[pet_owners['City'] == 'Grand Rapids']
gr

