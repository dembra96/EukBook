#This script is designed to analyse the RunInfo table output from NCBI search results.

#Runinfo table is a special type of downloadable output from SRA search results.
#It contains many descriptive info about each run in search results. 
#For example filesize (compressed SRA, not fastq), number of spots (illumina reads), etc.
#For more go and check out the csv file.

library(ggplot2)
library(cowplot)
library(grid)
library(gridExtra)

saple_size_filter = 1000 #Mb


wdir="~/EukBook_notes/SRA search/"
#wdir="/home/vlad/SRA_project/"
setwd(wdir)


RunInfo = read.table("SraRunTable_7.4k.txt",
                     header=T, sep=",", stringsAsFactors = F, quote = '"', fill = T)
dim(RunInfo)
#RunInfo = RunInfo[-c(which(RunInfo$Run=="Run")),] #to remove rudandant column heading lines in the file
#dim(RunInfo)

RunInfo$size_MB = as.numeric(RunInfo$MBytes) #as usual, all cols are character vectors, so need to convert into numeric
#hist(RunInfo$size_MB, breaks = seq(0,50000,by=500))
length(RunInfo$size_MB[which(RunInfo$size_MB<90)])
total_filesize = sum(RunInfo$size_MB, na.rm = T)/1000 #total size in Gb
total_filesize
total_filesize = round(total_filesize/1000, 1) # in Tb
  
#Filtering by size:
RunInfo <- RunInfo[which(RunInfo$size_MB > saple_size_filter),]
nrow(RunInfo)
write.table(RunInfo$Run, file = "SraRunTable_7.4k_sizefilt1Gb_5140.txt", col.names = F, quote = F, row.names = F)
  
  #Plot distrubioton of SRA files by filesize
  plot1 <- ggplot(RunInfo, aes(size_MB/1000)) +
    geom_histogram(binwidth = 0.10) +
    xlab("SRA file size, Gb") +
    #xlab("size, Gb\ncol width = 100Mb") +
  scale_x_continuous(breaks = c(seq(0,45,by=5))) #+
  #xlim(c(-1,45)) #+
  #ggtitle("SRA filesize distribution, n=2,293")
plot1
ggsave("SRA_filesize_hist_2293.pdf")

#Plot the cumulative density for SRA filesize
plot2 <- ggplot(RunInfo, aes(size_MB/1000)) +
  geom_hline(yintercept = 1.0, linetype="dashed", color="darkgrey") +
  stat_ecdf(na.rm = T) +
  #ggtitle("SRA filesize cumulative density, n=2,293") +
  scale_x_continuous(breaks = c(seq(0,45,by=5))) +
  xlab("SRA file size, Gb") +
  ylab(paste0("Cumulative density")) +
  scale_y_continuous(breaks = c(seq(0,1, by=0.1)))# , labels = seq(0,11, by=1))
plot2
ggsave("SRA_filesize_cumulative_2293.pdf")

#joining two plots:
g = grid.arrange(plot1, plot2, ncol=2)
ggsave(g, file="file_size_histogram_and_cumulative_density_together.jpg", width = 10, height = 5)
# geom_histogram(binwidth = 0.10)
