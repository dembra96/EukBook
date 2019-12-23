#install.packages("downloader")
#install.packages("stringr")
#install.packages("snow")

library(downloader)
library(stringr)
library(snow)

wdir="~/EukBook_notes/SRA_search/"
setwd(wdir)
accessions_file="SraRunTable_7.4k_sizefilt1Gb_5140.txt"

accessions =read.csv(paste0(wdir,accessions_file), stringsAsFactors = F, header = F)
SRR_url = "https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=run_browser&run="
#n_accessions = nrow(accessions)

#i=1
#for (accession in sample(accessions[,1]) ) {
#  filename <- paste0(accession, ".html")
#  if (!(filename %in% list.files(paste0(wdir,"SRA_Run_browser_webpages_R")))) {
#    print(paste0(accession, " new one ", i,"/",n_accessions))
#    url = paste0( SRR_url, accession)
#    filename<-paste0(wdir, "SRA_Run_browser_webpages_R/", accession, ".html")
#    download(url, filename)
#  } else { print(paste0(accession, " already downloaded ", i,"/",n_accessions)) }
#  i = i+1
#}

clus <- makeCluster(100)
clusterExport(clus, c("wdir", "SRR_url", "download"))

system.time(expr = {
  parLapply(clus, sample(accessions[,1]), 
            function(accession) {
              filename <- paste0(accession, ".html")
              if (!(filename %in% list.files(paste0(wdir,"SRA_Run_browser_webpages_R")))) {
                #print(paste0(accession, " new one ", i,"/",n_accessions))
                url = paste0( SRR_url, accession)
                filename<-paste0(wdir, "SRA_Run_browser_webpages_R/", accession, ".html")
                download(url, filename)
              } #else { print(paste0(accession, " already downloaded ", i,"/",n_accessions)) }
            }
           )
  }
)
  