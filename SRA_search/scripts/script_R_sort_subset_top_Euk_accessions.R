# This script takes as input a TAXA_table output from script script_R_4_make_taxa_table_from_htmls.R
# and produces list of most Euk-enriched samples
library(dplyr)

workdir <- "~/EukBook_notes/SRA_search/"
setwd(workdir)
TAXA_table_file <- "SraRunTable_7.4k_sizefilt1Gb_5140_accessions_available_at_denbi_4581_TAXA_table.tsv"
df <- read.table(TAXA_table_file, header = T, stringsAsFactors = F)
df
df_sorted <- df %>% arrange(desc(Eukaryotes))
df_sorted


df_subset <- df_sorted[9:38,]
dim(df_subset)
df_subset
acc_list <- df_subset %>% select(Accession)
acc_list

write.table(acc_list, file=paste0(workdir,  "my_test_subset_acc.tsv"), sep = "\t", row.names = F, col.names = F )
