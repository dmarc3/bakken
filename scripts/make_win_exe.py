#!/usr/bin/env python

"""
Script to create Windows Executable for LOVE2D game.

Usage:

    1. 
    
"""

import os
import shutil
from pathlib import Path
from subprocess import check_output
import glob
import ipdb

# Change directory two folders up
p = Path(__file__).parents[2]
os.chdir(p)

# Create zip file
shutil.make_archive('kiddo-fighter', 'zip', 'kiddo-fighter')

# Rename zip file to *.love file
os.rename('kiddo-fighter.zip', 'kiddo-fighter.love')

# Move *.love file into working folder
Path(os.path.join('kiddo-fighter', 'executable')).mkdir(parents=True, exist_ok=True)
shutil.move(os.path.join('kiddo-fighter.love'), os.path.join('kiddo-fighter', 'executable', 'fighter.love'))

# Move into game directory
os.chdir(os.path.join('kiddo-fighter', 'executable'))

# LOVE2D install directory
love_path = '"' + os.path.join('C:', os.path.sep, 'Program Files', 'LOVE', 'love.exe') + '"'
print(love_path)

# Run executable creation command
os.system('copy /b '+love_path+'+fighter.love fighter.exe')
# os.remove('fighter.love')

# Copy relevant DLLs
DLLs = glob.glob(os.path.join('C:', os.path.sep, 'Program Files', 'LOVE', '*.dll'))
for DLL in DLLs:
    print(DLL)
    shutil.copyfile(DLL, os.path.basename(DLL))