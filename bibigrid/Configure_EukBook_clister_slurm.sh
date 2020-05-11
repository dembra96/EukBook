#!/bin/bash -e 

#SBATCH --job-name=Conf_EukBook
#SBATCH --output="/home/ubuntu/EukBook_configure-%A_%a.log"
#SBATCH --array=1-25

# Before running this script upload the MinIO Eukcontainer secret to the master node.
# scp MinIO_secret.sh de:~/


echo -e "\n[[ INSTALL MINIO CLIENT ]]\n"

scp ${SLURM_SUBMIT_HOST}:~/MinIO_secret.sh .
source MinIO_secret.sh
while true; do wget --timeout=10 -c https://dl.min.io/client/mc/release/linux-amd64/mc && break; done
chmod +x mc
PATH=$PATH:${HOME}
mc config host add ena https://openstack.cebitec.uni-bielefeld.de:8080 "" ""
mc config host add eukupload https://openstack.cebitec.uni-bielefeld.de:8080 ${MINIO_ID} ${MINIO_SECRET}
sudo chown ubuntu /mnt


echo -e "\n\n[[ GIT CLONE EUKBOOK ]]\n"

if [[ -d "EukBook" ]]; then sudo rm -r EukBook; fi
while ! timeout 10s git clone https://github.com/dembra96/EukBook.git; do sleep 3; done
mv MinIO_secret.sh EukBook/


echo -e "\n\n[[ INSTALL MINICONDA ]]\n"

if [[ ! -f "successfully_installed_conda" ]]; then
	while true; do wget --timeout=10 -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && break; done
	if [[ -d "${HOME}/miniconda3" ]]; then rm -r ${HOME}/miniconda3; fi
	bash Miniconda3-latest-Linux-x86_64.sh -b
	source ${HOME}/miniconda3/etc/profile.d/conda.sh
	conda init
	conda activate
	echo Installing Snakemake
	conda env update -n base --file EukBook/yaml/snakemake.yaml
	touch "successfully_installed_conda"
	echo New conda successfully installed and configured for Snakemake.
else
	echo Conda is already installed and configured, skipping.
	source ${HOME}/miniconda3/etc/profile.d/conda.sh
	conda init
	conda activate
fi


echo -e "\n\n[[ INSTALL EUKREP ]]\n"

pip install EukRep


echo -e "\n\n[[ PREDOWNLOAD SNAKEMAKE CONDA PACKAGES FOR EUKBOOK PIPELINE ]]\n"

cd EukBook
if [[ -d /mnt/samples/simple/.snakemake/locks ]]; then ./Snakemake --configfile sample_yamls/samples_small.yaml --unlock; fi
./Snakemake --configfile sample_yamls/samples_small.yaml --create-envs-only
if [[ -d /mnt/samples/simple/.snakemake/locks ]]; then ./Snakemake --configfile sample_yamls/samples_small.yaml --unlock; fi
cd

echo -e "\n\n[[ CLEAN CONDA PACKAGES ]]\n"
conda clean -a -y
#rm -f -r -v snakemake_logs/


echo -e "\n\n[[ INSTALL METAEUK ]]\n"

if [[ ! -f "successfully_installed_metaeuk" ]]; then
	while true; do wget --timeout=10 -c https://mmseqs.com/archive/d49cd731e4241abfae11004b0d6da5cf3c515297/metaeuk-linux-avx2.tar.gz && break; done
	tar xzvf metaeuk-linux-avx2.tar.gz
	PATH=$PATH:${HOME}/metaeuk/bin/
	metaeuk
	touch "successfully_installed_metaeuk"
	echo MetaEuk successfully installed.
else
	PATH=$PATH:${HOME}/metaeuk/bin/
	echo Metaeuk is already installed, skipping.
fi

echo -e "\n\n[[ INSTALL MAILUTILIS ]]\n"
sudo debconf-set-selections <<< "postfix postfix/mailname string $(hostname).openstack.bielefeld"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt install mailutils -y




echo -e "\n\nAll programs installed!\n"



# Deleting unccecessary installation archives
rm -f -v Miniconda3-latest-Linux-x86_64.sh metaeuk-linux-avx2.tar.gz
echo "Installation archives deleted"

# Final export of all used paths to .profile:
EXPORTCMD="export PATH=$PATH"
if [[ ! $(tail -n 1 "${HOME}/.profile") == ${EXPORTCMD} ]]; then
	echo "export PATH=$PATH" >> ${HOME}/.profile
	echo "Path updated successfully."
else
	echo "Path already up to date"
fi


# Exporting a success stamp to master node:
STAMPFILE="STAMP_$(hostname)_config_success"
touch ${STAMPFILE}
scp ${STAMPFILE} ${SLURM_SUBMIT_HOST}:~/

echo "Stamp successfully exported"

echo -e "\n\nSleep 15s ...\n"
sleep 15

echo -e "\n\nINSTALLATION FINISHED SUCCESSFULLY!"
