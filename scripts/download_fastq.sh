#!/bin/bash -ex
#download_fastq.sh
#This script is downloading two fastq.gz files for a given accession into two target file names from SRA mirror on denbi cloud storage.
#Example run:
#./download_fastq.sh SRR5917220 reads_1.fastq.gz reads_2.fastq.gz

function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=3
  local delay=5
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

SAMPLE="$1"
PREFIX="$(echo "$SAMPLE" | head -c 6)"
MC_PATH="ena/ftp.era.ebi.ac.uk/vol1/fastq/${PREFIX}"
if [[ "${#SAMPLE}" == "9" ]]; then
    MC_PATH="${MC_PATH}/${SAMPLE}/${SAMPLE}"
else
    SUFFIX="${SAMPLE: -1}"
    MC_PATH="${MC_PATH}/00${SUFFIX}/${SAMPLE}/${SAMPLE}"
fi
retry mc cp -q "${MC_PATH}_1.fastq.gz" "$2"
retry mc cp -q "${MC_PATH}_2.fastq.gz" "$3"

# The next lines of code are temporary and are only needed to subset the first 10K
# reads of the sample at the development stage
#gunzip -c "$2" | head -n 4000000 > tempfile
#gzip tempfile
#mv -f tempfile.gz "$2"

#gunzip -c "$3" | head -n 4000000 > tempfile
#gzip tempfile
#mv -f tempfile.gz "$3"
