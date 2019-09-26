import pandas as pd
import numpy as np
'''df = pd.read_csv("EntrezID.csv")
print df'''

#reading the data from the file into a dataframe using pandas, this will only look at one file
data = pd.read_csv('NGSTwistTrial2_10_136818_NA12892_F_TwistExome_Pan2835_S10.markdup.realigned.chanjo_txt', header = None)

#Trying to insert a coulmn header
data.columns = ['Twisty']

#Splitting data 
data_split = data['Twisty'].str.split(expand= True)

#Putting split data into seperate columns in the dataframe
data_split[['Gene','Above 20','Average']] = data['Twisty'].str.split(expand= True)

'''#inserting patient ID to the left, need to automate this for each file
data_split.insert(0, 'Patient ID', 136818)

data_less = data_split.drop([1,2,3])

print data_less'''

'''print data'''

print data_split['Gene']