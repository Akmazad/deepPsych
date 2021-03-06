# note, Create random bins (for a binSize) for one category (e.g. HumanFC), and then
# copy that for others (e.g. EpiMap, CAGE, and TFs)

library(dplyr)
library(data.table)
source = "HumanFC"   
# ------------- Set Bin-flanking configuration
binSize = 400
flanking = 2*binSize     # can be arbitrarily given
dataDir = paste0("/Volumes/Data1/PROJECTS/DeepLearning/Test/", source, "/",binSize,"_",flanking,"/")
# dataDir = paste0("/srv/scratch/z3526914/DeepBrain/Data/", source, "/",binSize,"_",flanking,"/")
dir.create(dataDir, recursive=T)

# ------------- Bin creation
# set a fixed number of bins for this bin_flanking test:
# Rationale: for smaller bin/flanking size, the number of bins will be huge
#            for which downstream data processing may suffer resource issue
howManyBins = 1000000
# chrSizeFileName = "/srv/scratch/z3526914/DeepBrain/Data/hg19.chrom.sizes.txt"
chrSizeFileName = "/Volumes/Data1/PROJECTS/DeepLearning/Test/hg19.chrom.sizes.txt"
chr_size = fread(chrSizeFileName, sep="\t") %>% as.data.frame()
colnames(chr_size)=c("chr", "size")
# remove chromosome patches and sort by chr number
chr_size=chr_size[-grep("_", chr_size$chr, fixed=TRUE),]
chr_size=chr_size[match(paste0("chr", c(c(1:22), "M", "X", "Y")), chr_size$chr), ]

# 1. generate binIDs with size given, and chose randomly 1M of them: one File output
# generate bed file of bins of size b
message("Generating bed files for each bins of size b: ",appendLF=F)
b=binSize
for (j in c(1:nrow(chr_size))){
  start=seq(from=0, to=chr_size$size[j], by=b)+1
  end=seq(from=b, to=chr_size$size[j], by=b)
  chr_bins=cbind(as.character(chr_size$chr[j]),start[1:length(end)],end)
  if (j==1) bins=chr_bins else bins=rbind(bins, chr_bins) 
}
bins=as.data.frame(bins)
colnames(bins)=c("chr", "start", "end")
bins$id=paste(bins$chr, bins$start, bins$end, sep="_")
# Note: no strand is mentioned, hence 1 less column in all the subsequent files

binFile=paste0("hg19_bins_", b,"bp")
fwrite(bins, file=paste0(dataDir,binFile,".bed"), sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)
message("Done",appendLF=T)
# select randomly a fixed number of bins
bin_inputFile = binFile
bin_outputFile = paste0(bin_inputFile,"_rand")

message(paste("Select", howManyBins, "bins randomly "),appendLF=F)
system2('shuf', 
        paste('-n', howManyBins, paste0(dataDir,bin_inputFile,".bed"), '>',paste0(dataDir,bin_outputFile,".bed"), sep=' '), 
        wait=T)
message("Done",appendLF=T)
