#!/bin/bash -ex
#download_fastq.sh
#This script is downloading two fastq.gz files for a given accession into two target file names from SRA mirror on denbi cloud storage, and subsets them to small fraction of reads for pipeline testing.
#Example run:
#./download_fastq.sh SRR5917220 reads_1.fastq.gz reads_2.fastq.gz


SAMPLE="$1"
PREFIX="$(echo "$SAMPLE" | head -c 6)"
MC_PATH="ena/ftp.era.ebi.ac.uk/vol1/fastq/${PREFIX}"
if [[ "${#SAMPLE}" == "9" ]]; then
    MC_PATH="${MC_PATH}/${SAMPLE}/${SAMPLE}"
else
    SUFFIX="${SAMPLE: -1}"
    MC_PATH="${MC_PATH}/00${SUFFIX}/${SAMPLE}/${SAMPLE}"
fi
mc cp "${MC_PATH}_1.fastq.gz" "$2"
mc cp "${MC_PATH}_2.fastq.gz" "$3"

# The next lines of code are temporary and are only needed to subset the first 50K
# reads of the sample at the pipeline testing stage. Each read takes 4 lines in fastq file.
gunzip -c "$2" | head -n 200000 > "$2"_tempfile
gzip "$2"_tempfile
mv -f "$2"_tempfile.gz "$2"

gunzip -c "$3" | head -n 200000 > "$3"_tempfile
gzip "$3"_tempfile
mv -f "$3"_tempfile.gz "$3"
