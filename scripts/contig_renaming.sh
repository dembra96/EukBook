#!/bin/bash -e

# This script renames contigs to include also sample name.
# This is needed for later step that wisely concatenates EukRep contigs of all samples into one file prior to metauek run on this concatenated file.

# Problem is that all contigs have names like k141_134158 and there could be contigs with identical names in diferent files. With simple concatenation that would produce a faulty fasta file. To overcome this, I add SRR identifier to each contig identifier before concatenation



input="$1"
output="$2"


awk '/>/{sub(">","&"FILENAME"_");sub(/\/[^\.]*[^_]*/,x)}1' "$1" > "$2"

