#!/bin/bash -e

# Script is not more needed, because we decided not to keep the temp concatenated file, rather concatenate it just before metaeuk creation and then delete it.
#Another script does just awk renaming of contigs of a single given sample



# This script wisely concatenates EukRep contigs of all samples into one file

# Problem is that all contigs have names like k141_134158 and there could be contigs with identical names in diferent files. With simple concatenation that would produce a faulty fasta file. To overcome this, I add SRR identifier to each contig identifier before concatenation


output="$1"



shift  #this command pops the first argument $1 from the argument list 
#so next arguments shift one position back ( $2 $3 $4  -->  $1 $2 $3 )

#${@} cycles through all arguments. And we already got rid of first arg that was reserved for output filename so only variable number of SRR accessions should remain.

for f in "${@}"; 
do
    awk '/^>/ { match(FILENAME, /.RR[0-9]{6,9}/, a); sub(">", "&"a[0]"_"); print; next; } { print }' "$f" > "${f}_renamed"
done;

cat "${@/%/_renamed}" > "$output"
echo "${@/%/_renamed}"
