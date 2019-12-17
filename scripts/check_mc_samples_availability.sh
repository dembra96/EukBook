#!/bin/bash 
# -x option outputs all commands executed with all variables' values. Handy for debugging.
# -e option is not specified because we need to catch the errors and proceed

# This script takes as input SRA run accession list
# and outputs sublist of files that are actually available 
# at de.nbi SRA mirror through minio client. 


while read p
do (
	SAMPLE=$p
	PREFIX="$(echo "$SAMPLE" | head -c 6)"
	MC_PATH="ena/ftp.era.ebi.ac.uk/vol1/fastq/${PREFIX}"
	if [[ "${#SAMPLE}" == "9" ]]; then
		MC_PATH="${MC_PATH}/${SAMPLE}/${SAMPLE}"
	else
		SUFFIX="${SAMPLE: -1}"
		MC_PATH="${MC_PATH}/00${SUFFIX}/${SAMPLE}/${SAMPLE}"
	fi
	
	mc ls "${MC_PATH}_1.fastq.gz" > /dev/null 2>&1
	exitcode1=$?
	if [ "$exitcode1" -eq '0' ]
	then
		mc ls "${MC_PATH}_2.fastq.gz" > /dev/null 2>&1
		exitcode2=$?
		if [ "$exitcode1" -eq '0' ]
		then
			echo $SAMPLE >> accessions_available_at_denbi.txt
		else
			echo $SAMPLE >> accessions2_unavailable_at_denbi.txt
		fi
	else
		echo $SAMPLE >> accessions_unavailable_at_denbi.txt
	fi ) &
done <$1
wait

## Explanations

# The "do ( ... ) & done wait" thingi here is implemented to run all runs of the loop semi in parallel. Each launch of the loop wil be put into the background and next will start without awaiting respons of mc server. This saves a lot of time. Many mc inquiries are launched in parralel.

# The "command > /dev/null 2>&1" does following:
#  1. command > /dev/null: redirects the output of command(stdout) to /dev/null, 
#     so nothing will be outputed to terminal. For some reason that saves a lot
#     of runtime.
#  2. 2>&1: redirects stderr to stdout, so errors (if any) also goes to /dev/null
