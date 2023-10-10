# -*- coding: utf-8 -*-
"""
Created on Wed Sep 20 11:44:52 2023

@author: bibb04
"""

#%%
'''
to do: 
    
    -figure out whether i am going to do each of the block dataframes separately 
    (that may be easiest)
    then have them output into one data file. so 4 different input files, one output file. 
    put this code in the beginning of the task, and just run it for each of the 4 blocks?
    
    -I also need to fix teminology. what is a block?? remove the variable block from the enumerate function
    because that is going to get confusing


'''
#%%

#fill in the template dataframe for each new subject who does VWFA

#importing the modules that you are going to need in order to navigate the directories and fill in
#the dataframe 

import pandas as pd 
import os
import numpy as np 
import random

#directories are case-sensitive!

#this first line will ensure that your code adapts to whichever desktop you're on (desktop determines user)
home_dir = os.path.expanduser('~')
#define path to data
data_dir = os.path.join(home_dir, 'Desktop', 'vwfa_task', 'data')
#define path to the stimuli
input_dir = os.path.join(home_dir,'Desktop', 'vwfa_task', 'conditions')
os.chdir(input_dir)

#%%
#the below code is defining the way that the gui is going to ask for subject information. 
#gives you a lot more control over the data that you input and collect if you hard-code it in.

dlg = gui.Dlg(title = 'VWFA subject initialization')
#you can add as many fields as you want to collect as much input information as you want from this gui.
#here I just added one for order, but again, if you have more conditions feel free to add those in later.
dlg.addField('participant') #input 0
dlg.addField('subject_code') #input 1 
dlg.addField('seq_order', choices=[1,2,3,4,5,6]) #input 2


#if the program running successfully is dependent upon hardware like properties of the computer/a parallel (or other) hardware port, 
#this would be a good place to collect information on it to differentially execute lines of code depending on which physical location you're in. 
#ask sophie if you want details on this

user_input = dlg.show()

if dlg.OK == False:
    core.quit()  # user pressed cancel

#this is creating an object called subject ID that is a string adding onto the numbers that you input for each subject.
#change the letters after "sub" if you want to name the files for a specific study. ("sub-football001", etc)

#CHANGE THIS TO INCLUDE THE SUBJECT CODE INPUT !!!!! 9/21/2023
subID = 'sub-VWFA{0:0=3d}'.format(int(user_input[0]))

#this does the same, but creates objects for the other inputs that you put into the gui above
#make sure that if you add more fields that you come here and define them here too
seq_order_input = user_input[2]

#%%
#FOR TESTING IN PYTHON FILE:
    #defining these here so that you can test this here without having to open psychopy (the gui is only a thing in psychopy, so if you define them 
    #here you aren't reliant upon the gui inputs to define the variables)
subID = 'VWFA999'
seq_order_input = 3
#%%

#creating a dictionary, where the key is which of the 6 orders you select, and the value is the order of the conditions
#and the value is either 1, 2, or 3 (references the 3 conditions in your conditions file. we will come back to this)

stims_dict = {1:'word', 2:'scrword', 3:'line', 4:'face'}

seq_order = {1:[1,2,3,4],
             2:[2,3,4,1], 
             3:[3,4,1,2], 
             4:[4,1,2,3], 
             5:[1,4,3,2], 
             6:[3,2,4,1]}
#%%

# Generate a list of random numbers from 1 to 24 without duplicates
random_numbers = random.sample(range(1, 25), 24)

# Save the original list to a file (e.g., original_numbers.txt)
#with open('original_numbers.txt', 'w') as file:
#    for number in random_numbers:
#       file.write(f'{number}\n')

# Choose two random numbers from the list
#randomly select two indices positions) from random_numbers (variable above, with 24 numbers between 1 and 25)
random_indices = random.sample(range(len(random_numbers)), 2)
#for each of the indices, select the associated number from the random number list
chosen_numbers = [random_numbers[index] for index in random_indices]

# Insert another copy of the chosen numbers after their original positions
for number in chosen_numbers:
    #create a variable named index that is the actual number at one of the two chosen numbers to be duplicated
    index = random_numbers.index(number)
    #insert to the right of the random index that was selected (once for each of the random number)
    random_numbers.insert(index + 1, number)


#%% THIS WORKS 10/10/2023

#CREATE DATAFRAME:

#create list of day 1 phases
#create dataframe of stims (the one with the 6 columns of 24 animals or tools)
stims = pd.read_csv('all_conditions.csv')
stims = stims.sample(frac=1).reset_index(drop=True) #shuffle within columns

#read in the task template, and name it (using list comprehension)
df = pd.read_csv(f'../task_template/vwfa_template_block1.csv')

    #for each of the blocks:
for p, block in enumerate([1,2,3,4]):
    # Generate a list of random numbers from 1 to 24 without duplicates
    random_numbers = random.sample(range(1, 25), 24)

    # Save the original list to a file (e.g., original_numbers.txt)
    #with open('original_numbers.txt', 'w') as file:
    #    for number in random_numbers:
    #       file.write(f'{number}\n')

    # Choose two random numbers from the list
    #randomly select two indices positions) from random_numbers (variable above, with 24 numbers between 1 and 25)
    random_indices = random.sample(range(len(random_numbers)), 2)
    #for each of the indices, select the associated number from the random number list
    chosen_numbers = [random_numbers[index] for index in random_indices]

    # Insert another copy of the chosen numbers after their original positions
    for number in chosen_numbers:
        #create a variable named index that is the actual number at one of the two chosen numbers to be duplicated
        index = random_numbers.index(number)
        #insert to the right of the random index that was selected (once for each of the random number)
        random_numbers.insert(index + 1, number)
        
    #assign ransom_numbers to a column of the input file 
    df['random_numbers'] = pd.Series(random_numbers)
    #turn it into a set to eliminate existing repeats
    image_paths = set(stims[f'{stims_dict[block]}_{seq_order[seq_order_input][p]}'])   
    #turn it back into a list to make it iterable in a reliable way (not even sure if this is necessary lol)
    image_paths = list(image_paths)
    #generate a list with one file randomly duplicated
    image_stimuli = []
    for number in random_numbers:
        image_stimuli.append(image_paths[number-1])
    #insert list as a column into dataframe
    df['image_stimuli'] = image_stimuli 
    
 #%% figure this out 3:51 pm 10/10                                                                               
os.chdir(data_dir)
os.makedirs(f'data/{subID}',exist_ok=True)
for phase in day1_phases:
  ses = 1
  phase_str = phase.split('_')[0]
  day1_dfs[phase].reset_index().to_csv(f'../data/{subID}/{subID}_ses-{ses}_task-{phase_str}_events-input.csv',index=False)