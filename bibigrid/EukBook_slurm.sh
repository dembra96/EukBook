#!/bin/bash

#SBATCH --job-name=EukBook
#SBATCH --output="/home/ubuntu/EukBook_slurm-%A_%a.log"
#SBATCH --array=1-5

echo "SLURM_ARRAY_TASK_ID is:  ${SLURM_ARRAY_TASK_ID}"
source ~/.profile #to activate conda 

workdir="/mnt/samples/simple"
mkdir -p $workdir

cd ~/EukBook
./Snakemake --configfile sample_yamls/slurm_sets/set_${SLURM_ARRAY_TASK_ID}.yaml --config Quick_mode=True -k -n

# -k - keep going with independent jobs if a job fails. Useful for quick runs where quasts may fail.
