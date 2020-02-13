#!/bin/bash

#SBATCH --job-name=EukBook_launch
#SBATCH --output="/home/ubuntu/EukBook_slurm-%A_%a.log"
#SBATCH --array=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=dembra96@gmail.com

echo "SLURM_ARRAY_TASK_ID is:  ${SLURM_ARRAY_TASK_ID}"
source ~/.profile #to activate conda 
#conda activate sm
sudo chown ubuntu /mnt

workdir="/mnt/samples/simple"
mkdir -p $workdir

cd ~/EukBook
source MinIO_secret.sh

time snakemake -p -j --use-conda --configfile ~/EukBook/sample_yamls/slurm_sets/set_${SLURM_ARRAY_TASK_ID}.yaml --config Quick_mode=True -n
# -k - keep going with independent jobs if a job fails. Useful for quick runs where quasts may fail.
