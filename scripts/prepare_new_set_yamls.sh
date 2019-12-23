#!/bin/bash

# This script takes as input a file with the list of sample accessions ought 
# to be processed by the Snakemake pipeline and does the following:
#  - compares the new list to what has already been processed before and is 
#    saved to minio container, keeps only unprocessed reads
#  - splits new accessions in batches of 10 and saves new .yaml files with a 
#    proper set number, that follows the ones already saved to container

##  TODO: 
#   - checks the accessability of all samples at de.nbi SRA mirror and leaves only the accessible ones.



# Download and concatenate all accessions from minio container
mc cp --recursive eukupload/eukcontainer/batch1/accessions/ temp/
cat temp/set_*_samples.txt > temp/set_all_samples.txt

# compare given file with the concatenated file of processed accessions
comm -23 <(sort $1) <(sort temp/set_all_samples.txt) > temp/unprocessed_accessions.txt
# comm is a very handy function here
rm temp/set_*_samples.txt

# Get the number of the last saved set:
last_n=$(mc ls eukupload/eukcontainer/batch1 |
	awk '{print $5}' |
	awk '/[[:digit:]]+.tar.gz/{print}' |
	awk '{gsub(/[^0-9]/,"")}1' |
	sort -r -h | head -n 1 
	)
# get the list of files at mc container
# take only the file names
# take only the big archives like set_13.tar.gz
# extract the numbers
# sort and take the biggest


## Split list in yaml files with 10 accessions each

# First simply split in 10-line files:
split -l 10 temp/unprocessed_accessions.txt temp/set_

# Second create the yaml sets from those:
let n=$last_n+1
for file in temp/set_*
do
	newfile=set_"$n".yaml
	echo "#This is automaticlly generated yaml from" $1 "on" `date '+%d/%m/%Y_%H:%M:%S'` > $newfile
	echo >> $newfile
	echo "SAMPLESET:" >> $newfile
	echo "   - set"$n >> $newfile
	echo "SAMPLE:" >> $newfile
	
	while IFS= read -r line
	do
		echo "   - $line" >> $newfile
	done < $file
	
	let n=$n+1
done

# rm -r temp/
