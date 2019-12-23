# General: This script converts list of input strings from file into a single big string,
# separated by " OR". 
# Particular: Used to construct big queries with many accesion for esearch tool.
# This is mainly needed to get list of all SRA accessions listed of desired BioProjects

#This scripts converts a list of accessions (SRR or PRJNA) from file
#into a single big string of type "SRR123 OR SRR234 OR SRR987" and saves it into a new file.
#String is used as query for esearch and efetch commands. 
#(see script esearch bash scripts.txt)


#### Important addition!
#### SRR1234567[Accession] should be specified, otherwise you also get accessions associated with one you search for.



wdir="~/EukBook_notes/SRA_search/"
#file="SraRunTable_7.4k_sizefilt1Gb_5140.txt"
#file="SraRunTable_7.4k_sizefilt1Gb_5140_accessions_available_at_denbi.txt"
file="my_test_subset_acc.tsv"

t = read.csv(paste0(wdir, file), header=F)
#t = read.csv(paste0(wdir,"Intersect_SraAccList_13k_no_transcr.txt_PRJNA_search_results_5k_no_transcr.txt"), header=F)
#t

# esearch tool has a size limit for query. Because of that, for long queries one might 
# want to separate list of project accessions into groups
len = nrow(t)
window = 6000
#1    1001 2001 3001 4001 5001
#1000 2000 3000 4000 5000 5356
s1 = seq(1, len, window)
s2 = c(s1[-1]-1, len)
s1
s2
rm(t2)
for (i in 1:length(s1)) {
  t2 = paste(t[s1[i]:s2[i],1], collapse = "[Accession] OR ")
  #head(t2)
  write(t2, file=paste0(wdir,file,"_OR_list",i,".txt"))
  
}

#older version, that concatenates all PRJNAs at once,
#that sometimes results in too long strings to query with esearch
#t2 = paste(t[1001:9738,1], collapse = "[Accession] OR ")
#head(t2)
write(t2, file=paste0(wdir,"PRJNA_converted_16k_no_transcr_custom.txt"))
#write(t2, file=paste0(wdir,"Intersect_converted.txt"))
#cowplot
#install.packages("cowplot")
#library(cowplot)

#one serch: 2 s
#100: 14s
#500: 66s (14*5 = 70, almost the same)
#1000: 77s!   (66*2=132, 2:12)