#! python3
# mouseNow.py - Displays the mouse cursor's current position.
import pyautogui
pyautogui.size()
print('Press Ctrl-C to quit.')
#TODO: Get and print the mouse coordinates.
try:
    while True: 
        x,y=pyautogui.position()
        positionStr = 'X: ' + str(x).rjust(4) + ' Y: ' + str(y).rjust(4)
except KeyboardInterrupt:
	print('\nDone.')
print(positionStr, end='')
print('\b' * len(positionStr), end='', flush=True)


#%%
import pyautogui
pyautogui.size()
x,y = pyautogui.position()
print(x)
print(y)

#%%
import pyautogui
pyautogui.PAUSE = 0.25
pyautogui.FAILSAFE = True # if things go wrong, move the mouse cursor to the top left corner of the screen
# laptop screen size: Size(width=1920, height=1080)
# set file explorer window is on the left half of the screen
# set adobe acrobat on the right half of the screen
# make sure adobe acrobat has the export pdf window open 
# make sure I have tried to get to the excel setting once


load_time = 5 # if this is not long enough, things can go wrong
default_duration = 0.25
num_files = 9 #12
# When file explorer window is on the left, first file in list
startx = 448
#starty = 265
starty = 275
pyautogui.moveTo(startx, starty, duration=default_duration)

#BEGIN LOOP
i = 1
for x in range(num_files):
    # double click to open file 
    pyautogui.doubleClick()
    # change export from word to excel
    pyautogui.moveTo(1767, 555, duration=load_time)
    pyautogui.click()
    pyautogui.moveTo(1741, 708, duration=default_duration)
    pyautogui.click()
    # convert 
    pyautogui.moveTo(1768, 726, duration=default_duration)
    pyautogui.click()
    # move cursor to next file 
 #    pyautogui.moveTo(startx, starty, duration=default_duration)
    move = i * 28
    pyautogui.moveTo(startx, starty + move, duration=default_duration)
    # increase index for next time
    i = i + 1
#END LOOP

# move cursor to download all zip file 
pyautogui.moveTo(1768, 726, duration=default_duration)
