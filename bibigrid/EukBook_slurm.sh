#!/bin/bash

#SBATCH --job-name=EukBook
#SBATCH --output="/home/ubuntu/EukBook_slurm-%A_%a.log"
#SBATCH --array=1-100

echo "SLURM_ARRAY_TASK_ID is:  ${SLURM_ARRAY_TASK_ID}"
source ~/.profile #to activate conda 

workdir="/mnt/samples/simple"
mkdir -p $workdir
#sample_yaml_dir="sample_yamls/slurm_sets"
sample_yaml_dir="/home/ubuntu/vol/spool/new_accession_yamls"

cd ~/EukBook
./Snakemake --configfile ${sample_yaml_dir}/set_${SLURM_ARRAY_TASK_ID}.yaml --config Quick_mode=False 

# -k - keep going with independent jobs if a job fails. Useful for quick runs where quasts may fail.
