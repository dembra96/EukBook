#This python script is assessing Kraken classification perfoemance comparing it to assembled EukRep contigs.
# current variant of script produces three tables instead of one


# Script is calculating the table of four values - how many reads mapped to Euk / non-Euk contigs (identified by EukRep), and how many of those reads were classified by Kraken as bacterial or Euk reads. This way we can track how many true and false positives Kraken gives us.

#Output is a table of four values.


import pandas as pd
import sys
import tabulate

# command is called like:
# python scriptpath sample.sam Euk_contig_ids.txt Euk_reads.txt
# so first argument (in python index [0]) is actually a script name itself.
sample = sys.argv[1]
Euk_contig_ids_filename = sys.argv[2]
Euk_reads_from_kraken_full_filename = sys.argv[3]
Euk_reads_from_kraken_nr_filename = sys.argv[4]
Euk_reads_from_kraken_nt_filename = sys.argv[5]
out_file_name = sys.argv[6]
sample_ID = sys.argv[7]

f = open(out_file_name, 'w')
print('Sample: ' + sample_ID, file=f)

# Reading the original .sam mapping file, but only colums with readID and contigID where read mapped 
df = pd.read_csv(sample, sep='\t', usecols=[0,2], header=None)
# Removing the header (all lines that start with @)
df = df[~df[0].str.contains('@')] 

reads_all = set(df[0])
df_mapped = df[ ~(df[2]=='*')]
reads_mapped=set(df_mapped[0])
perc_mapped = len(reads_mapped) / len(reads_all) * 100
print('Reads mapped: ' + str(perc_mapped) + '%')
print('Reads mapped: ' + str(perc_mapped) + '%\n', file=f)

#reading the list of Euk contig Ids
Euk_contig_IDs = set(line.strip() for line in open(Euk_contig_ids_filename))
 
#calculating reads mapped to EukRep euk contigs
df_mapped_to_Euk = df_mapped[ (df_mapped[2].isin(Euk_contig_IDs)) ]
reads_mapped_to_euk = set(df_mapped_to_Euk[0])


# 1 reading the list of ids that kraken considered Eukariotic
# kraken full
i=1
for kraken_out in [Euk_reads_from_kraken_full_filename,
                   Euk_reads_from_kraken_nr_filename,
                   Euk_reads_from_kraken_nt_filename]:
    print(kraken_out, file=f)

    Euk_reads_from_kraken = set(line.strip() for line in open(kraken_out))
    #calculating the mapping numbers
    A = len(reads_mapped_to_euk.intersection(Euk_reads_from_kraken))
    B = len(reads_mapped_to_euk.difference(Euk_reads_from_kraken))

    df_mapped_to_non_Euk = df_mapped[ ~(df_mapped[2].isin(Euk_contig_IDs)) ]
    reads_mapped_to_non_euk = set(df_mapped_to_non_Euk[0])
    C = len(reads_mapped_to_non_euk.intersection(Euk_reads_from_kraken))
    D = len(reads_mapped_to_non_euk.difference(Euk_reads_from_kraken))

    result_df = pd.DataFrame({'Kraken:Euk': [A,C], 'Kraken:non-Euk': [B,D]})
    result_df_perc = round( (result_df / len(reads_mapped) * 100) , 2)

    result_df.loc[:,'Total'] = result_df.sum(axis=1) #rowsums
    result_df.loc['Total',:]= result_df.sum(axis=0) #colsums

    result_df_perc.loc[:,'Total'] = round(result_df_perc.sum(axis=1), 2) #rowsums
    result_df_perc.loc['Total',:] = round(result_df_perc.sum(axis=0), 2) #colsums


    result_df = pd.concat([result_df, result_df_perc])
    result_df.index = ['EucRep:Euk', 'EukRep:n-Euk', 'Total_reads', 'EucRep:Euk_%', 'EukRep:n-Euk_%', 'Total_reads_%']

    #saving the results
    #result_df.to_csv('mapped_reads_percentages_table.tsv', sep='\t')
    print(result_df, '\n', file=f)

f.close()

