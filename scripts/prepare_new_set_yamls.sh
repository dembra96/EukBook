#!/bin/bash -e

# This script takes as input a file with the list of sample accessions ought 
# to be processed by the Snakemake pipeline and does the following:
#  - compares the new list to what has already been processed before and is 
#    saved to minio container, keeps only unprocessed reads
#  - splits new accessions in batches of 10 and saves new .yaml files with a 
#    proper set number, that follows the ones already saved to container

##  TODO: 
#   - checks the accessability of all samples at de.nbi SRA mirror and leaves only the accessible ones.


### Exampe usage:
# ./prepare_new_set_yamls.sh accessions_to_process.txt

# This will create folders and files in current working dir.
# Main result: folder new_accession_yamls with set_*.yaml files.
# Those files should be submitted to the sbatch array command.




# Metaeuk remote container path:
Metaeuk_dir="eukupload/eukcontainer/contigs/megahit_v1.2.9/EukRep_v0.6.6_lenient/MetaEuk_alpha/metaeuk_ref_profiles_more_than1_MMETSP_zenodo_3247846_profiles/" 
samplefile_regex="set_[[:digit:]]*_samples.txt"
tmp="temp_mc_samples"

query_file=$1





# Download and concatenate all accessions from minio container
mkdir -p ${tmp}/old
mc cp $(mc find ${Metaeuk_dir} --regex "${samplefile_regex}") ${tmp}/old
cat ${tmp}/old/* > all_procesed_accessions.txt


# Generate a list of unprocessed accessions
awk 'NR == FNR { f[$1] = 1; next; } !($1 in f) { print; }' all_procesed_accessions.txt ${query_file} > unprocessed_accessions.txt
 

# Get the number of the last saved set:
last_n=$(mc ls ${Metaeuk_dir} |
	awk '{print $5}' |
	awk -v var="${samplefile_regex}" '$0 ~ var {print}' |
	awk '{gsub(/[^0-9]/,"")}1' |
	sort -r -h | head -n 1 
	)
# get the list of files at mc container
# take only the file names
# take only the set_*_sample.txt files
# extract the numbers
# sort and take the biggest


## Split list in yaml files with 10 accessions each

# First simply split in 10-line temporary files:
mkdir -p ${tmp}/split_accessions
split -l 10 unprocessed_accessions.txt ${tmp}/split_accessions/set_

# Second create the yaml sets from those:
mkdir -p new_accession_yamls
let n=$last_n+1
for file in ${tmp}/split_accessions/set_*
do
	newfile=new_accession_yamls/set_"$n".yaml
	echo "#This is automaticlly generated yaml from" $1 "on" `date '+%d/%m/%Y_%H:%M:%S'` > $newfile
	echo >> $newfile
	echo "SAMPLESET:" >> $newfile
	echo "   - set_"$n >> $newfile
	echo "SAMPLE:" >> $newfile
	
	while IFS= read -r line
	do
		echo "   - $line" >> $newfile
	done < $file
	
	let n=$n+1
done

#rm -r ${tmp}
