
from psychopy import visual, core
import random
import pandas as pd 
import os 


home_dir = os.path.expanduser('~')
stims_dir = os.path.join(home_dir, 'Desktop', 'vwfa_task')
os.chdir(stims_dir)
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

# write the updated list to a text file (e.g., updated_numbers.txt)
with open('updated_numbers.txt', 'w') as file:
    for number in random_numbers:
        file.write(f'{number}\n')
        
#%%
# Read the random_numbers list from a text file
with open('updated_numbers.txt', 'r') as file:
    random_numbers = [int(line.strip()) for line in file.readlines()]

# Read image file paths from a text file
with open(os.path.join(stims_dir, 'word_images.txt'), 'r') as file:
    image_paths = [line.strip().split('. ')[1] for line in file.readlines()]

# Initialize PsychoPy window
win = visual.Window(size=(800, 600), fullscr=False, units='pix')

# Prepare image stimuli
#this is the line of code that actually puts the list together
#creates a list called image stimuli
#[number - 1] is indexing out the filepath at a given index in random_numbers (-1 to account for the way it counts from 0)
image_stimuli = [visual.ImageStim(win=win, image=image_paths[number - 1]) for number in random_numbers]

# Presentation durations
image_duration = 0.5  # in seconds
interstimulus_duration = 0.1923  # in seconds

# Present images sequentially
for image_stimulus in image_stimuli:
    # Choose a random RGB color for the background
    background_color = [random.random(), random.random(), random.random()]  # Random RGB values
    # Set the window background color
    win.color = background_color
    # Draw the image stimulus on the colored background
    image_stimulus.draw()
    win.flip()
    core.wait(image_duration)    
    # Clear the window during the interstimulus interval
    win.flip()
    core.wait(interstimulus_duration)  # wait for the interstimulus interval

# Close the PsychoPy window
win.close()
core.quit()

#%%

