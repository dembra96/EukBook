#!/bin/bash

#SBATCH --job-name=EukBook_cleanup_old_reports
#SBATCH --array=1-5

rm ~/EukBook_slurm-* ~/slurm-*
sleep 5
