#!/bin/bash -ex

# This script takes as input SRA run accession list
# and outputs sublist of files that are actually available 
# at de.nbi SRA mirror through minio client. 



SAMPLE="$1"
PREFIX="$(echo "$SAMPLE" | head -c 6)"
MC_PATH="ena/ftp.era.ebi.ac.uk/vol1/fastq/${PREFIX}"
if [[ "${#SAMPLE}" == "9" ]]; then
    MC_PATH="${MC_PATH}/${SAMPLE}/${SAMPLE}"
else
    SUFFIX="${SAMPLE: -1}"
    MC_PATH="${MC_PATH}/00${SUFFIX}/${SAMPLE}/${SAMPLE}"
fi

mc ls "${MC_PATH}_1.fastq.gz"
exit1=$?
mc ls "${MC_PATH}_2.fastq.gz"
exit2=$?

if [exit1 -ne 0] || [exit2 -ne 0] 
then
	echo $SAMPLE >> available_accessions.txt
fi