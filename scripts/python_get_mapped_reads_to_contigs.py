import sys
import pandas as pd

df = pd.read_csv(sys.argv[1], sep='\t', usecols=[0,2], header=None)
Euk_contig_IDs = set(line.strip() for line in open(sys.argv[2]))

df2 = df[ (df[2].isin(Euk_contig_IDs)) ]
df2 = df2[0]
df2 = set(df2)
df2 = pd.DataFrame.from_dict(df2)
df2.to_csv('mapped_reads_'+sys.argv[1]+'.txt', sep='\t', index=False, header=False)
