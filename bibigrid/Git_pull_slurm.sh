#!/bin/bash

#SBATCH --job-name=EukBook_launch
#SBATCH --array=1-25

cd ~/EukBook
#if some old files cause git clash:
#git checkout snakefiles/Snakefile_simple_metaeuk_joined
git pull
sleep 15

