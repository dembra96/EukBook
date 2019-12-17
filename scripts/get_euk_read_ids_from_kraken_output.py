# This script is used to subset reads from kraken output file to exclude all certainly non-euk reads from further assembly step. 
# The script only produces a list of read identifiers to be extracted from initial fastq file by 'seqtk subseq' tool.

### How it works ###
# First, whole kraken output tab-delimited file is uploaded in python pandas dataframe.
# Second, script saves only read names that were either remained unclassified by kraken or whose classified taxids do not belong to non-euk taxa,
# thus filtering out all non-euks.
# Taxids of non-euk organisms are stored in 'ArchBactVir_TaxIDs.txt' file made by efetch/esearch command from ncbi's Entrez utility.
# The command itself (requires entrez utility):
# esearch -db taxonomy -query "Bacteria[orgn]" | efetch -db taxonomy -format docsum | xtract -pattern DocumentSummary -element Id >> ArchBactVir_TaxIDs.txt
# ... and two similar ones for "Archaea[orgn]" and "Vira[orgn]"
# Finally, remainig filtered bandas dataframe (only read name column) is stored in 'Euk_reads.txt' file.

import sys
import pandas as pd

non_Euk_taxids = set(int(line.strip()) for line in open('/home/ubuntu/EukBook/ArchBactVir_TaxIDs.txt'))

#df = pd.read_csv('kraken_db_prot_euk_k15_l12_output', sep='\t', usecols=[0,1,2], header=None)
# we need only first three columns of the output file
df = pd.read_csv(sys.argv[1], sep='\t', usecols=[0,1,2], header=None)

df2 = df[(df[0]=='U') | (~df[2].isin(non_Euk_taxids))]
# Subsetting here in pandas works similar to R: you pass a list of boolean values of the same length as the dataframe, and all rows that have 'True'
# corresponding values are subsetted, 'False' - ommited from resulting df.
# Two conditions (resulting boolean vectors) are joined by bit-wise OR operator '|'. 
# Tilda '~' sign is inverting each boolean element of the boolean vector string ('bit-wise NOT operator') that is a result here of '.isin' method
df2 = df2[1]
#here we just take the second column, containing read ids.

df2.to_csv(sys.argv[2], sep='\t', index=False, header=False)
