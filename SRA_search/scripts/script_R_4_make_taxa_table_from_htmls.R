library(readr)
library(stringr)
library(dplyr)
library(ggplot2)

workdir <- "~/EukBook_notes/SRA_search/"
SRA_html_files_dir <- "SRA_Run_browser_webpages_R/"
setwd(dir=workdir)


### Choose the files for taxa table:
# all available html files
files = list.files(path = SRA_html_files_dir)
# Specified by input list:
## ATTENTION! At this point all the html files should be already there, otherwise df creation fails later on.
files = read_file("SraRunTable_7.4k_sizefilt1Gb_5140_accessions_available_at_denbi_4581.txt")
files <- strsplit(files, split = "\n")[[1]]
files <- paste0(files2, ".html")

n_files=length(files)  
n_files
#Benchmarking:
#files=c("SRR5924853.html", "SRR5677500.html", "SRR5720223.html")

query_unident = '(?<=Unidentified reads: <strong>)[[:digit:]|\\.]*'
query_bact = '(?<=\\{"name":"Bacteria","percent":")[[:digit:]|\\.]*' #*"\\}'
query_euk = '(?<=\\{"name":"Eukaryota","percent":")[[:digit:]|\\.]*' #*"\\}'

# Two versions of parcing are implemented: lapply and for loop. Both work approx equal. For loop is even a bit faster.

### for loop method
{ l=list()
  i=1
   
  start_time <- Sys.time()
   
   for (file in files) {
     #t= read_file(paste0("SRA_Run_browser_webpages_R/", file))
     accession=strsplit(file,".html")[[1]][1]
     print(paste0("Accession ", accession, ", ", i, "/",n_files))
     p_unident <- system(paste0("grep 'Unidentified reads: <strong>[0-9,\\.]*' ", workdir, SRA_html_files_dir, file), intern = TRUE)
     p_unident = as.numeric( str_extract(p_unident, query_unident) )
     p_bact <- system(paste0("grep '\\{\"name\":\"Bacteria\",\"percent\":\"[0-9,\\.]*' ", workdir, SRA_html_files_dir, file), intern = TRUE)
     p_bact = as.numeric( str_extract(p_bact, query_bact)    )
     p_euk <- system(paste0("grep '\\{\"name\":\"Eukaryota\",\"percent\":\"[0-9,\\.]*' ", workdir, SRA_html_files_dir, file), intern = TRUE)
     p_euk = as.numeric( str_extract(p_euk, query_euk)     )
     l[[i]] = list(Accession=accession, Unidentified=p_unident, Bacteria=p_bact, Eukaryotes=p_euk)
     i=i+1
     
   }
   end_time <- Sys.time()
   end_time - start_time
}

### lapply method (commented out)
{ 
#l=list()
#  i=1
#  
#  start_time <- Sys.time()
#  l <- lapply(files, function(file) {
#    #t= read_file(paste0("SRA_Run_browser_webpages_R/", file))
#    accession=strsplit(file,".html")[[1]][1]
#    print(paste0("Accession ", accession, ", ", i, "/",n_files))
#    #p_unident =   
#    #p_bact    = as.numeric( str_extract(t, query_bact)    )
#    #p_euk     = as.numeric( str_extract(t, query_euk)     )
#    i<<-i+1
#    return(c(accession, 
#             as.numeric( str_extract(system(paste0("grep 'Unidentified reads: <strong>[0-9,\\.]*' ", workdir, SRA_html_files_dir, file), intern = TRUE), query_unident) ) ,
#             as.numeric( str_extract(system(paste0("grep '\\{\"name\":\"Bacteria\",\"percent\":\"[0-9,\\.]*' ", workdir, SRA_html_files_dir, file), intern = TRUE), query_bact) ) ,
#             as.numeric( str_extract(system(paste0("grep '\\{\"name\":\"Eukaryota\",\"percent\":\"[0-9,\\.]*' ", workdir, SRA_html_files_dir, file), intern = TRUE), query_euk) )           
#    ))
#  })
#  end_time <- Sys.time()
#  end_time - start_time
}
# 5140 samples parced for 3,55 min


# A numeric(0) problem walkaround:
{
  #Where grep does not faind a pattern it outputs not NA but a missing value - numeric vector of length 0 - numeric(0). 
  #This makes problems when coercing unlisted list to matrix - missing values are skipped and that skewes the matrix.
  # This is walkaround to replace all numeric(0) with NAs:
  is.numeric0 <- function(x) { is.numeric(x) && length(x) == 0L }
  for (i in 1:length(l)) {
    for (j in 1:4) {
      if (is.numeric0(l[[i]][[j]])) {l[[i]][[j]]=NA}
    }
  }
}


# df composing
{df <- data.frame(matrix(unlist(l), nrow=length(l), byrow=T), stringsAsFactors = F)
colnames(df)=c("Accession", "Unidentified", "Bacteria", "Eukaryotes")
df <- df %>% mutate_at(vars(-"Accession"), as.numeric)
df <- df %>% filter(!is.na(Eukaryotes)) 
df
#class(df[126,4])
#table(df)
#summary(df)
#View(df)
}

title = "SraRunTable_7.4k_sizefilt1Gb_5140_accessions_available_at_denbi_4581"
write.table(df, file=paste0(workdir, title, "_TAXA_table.tsv"), sep = "\t", row.names = F)
#df2 <- read.table(file=paste0(workdir, "SraRunTable_7.4k_sizefilt1Gb_5140_TAXA_table.tsv"), header = T, stringsAsFactors = F)
#save(df, file=paste0(workdir, "SraRunTable_7.4k_sizefilt1Gb_5140_TAXA_table.RData"))
#load(file=paste0(workdir, "SraRunTable_7.4k_sizefilt1Gb_5140_TAXA_table.RData"))
