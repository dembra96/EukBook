#!/bin/bash

#SBATCH --job-name=Euk_Fix
#SBATCH --output="/home/ubuntu/EukBook_slurm-%A_%a.log"
#SBATCH --array=11,67
#SBATCH --nodelist=bibigrid-worker1-23-nxscftyhrss47ez
echo "SLURM_ARRAY_TASK_ID is:  ${SLURM_ARRAY_TASK_ID}"
echo "This is a continuation after errors of 150 sets and wrong raw QUASTS. Current set had an error."
source ~/.profile #to activate conda 

workdir="/mnt/samples/simple"
mkdir -p $workdir
#sample_yaml_dir="sample_yamls/slurm_sets"
sample_yaml_dir="/home/ubuntu/vol/spool/new_accession_yamls"

cd ~/EukBook
./Snakemake --configfile ${sample_yaml_dir}/set_${SLURM_ARRAY_TASK_ID}.yaml --config Quick_mode=False Megahit_parallel_mode=False -k 

# -k - keep going with independent jobs if a job fails. Useful for quick runs where quasts may fail.
