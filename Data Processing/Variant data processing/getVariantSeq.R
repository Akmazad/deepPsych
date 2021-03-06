getVariantSeq <- function(dat, flankingLength){
  require(data.table)
  require(BSgenome.Hsapiens.UCSC.hg19)
  require(dplyr)
  require(stringr)
  
  hg <- BSgenome.Hsapiens.UCSC.hg19
  start = dat$Pos - flankingLength
  end = dat$Pos + (flankingLength - 1)
  # chrName= paste0("chr",as.character(dat$Chr))
  
  # ref seq
  fasta.seq.ref = BSgenome::getSeq(hg, dat$Chr, start=start, end=end, strand = as.character(dat$Strand))
  fasta.seq.ref = as.data.frame(fasta.seq.ref)[,1]
  # print(substring(fasta.seq.ref, (flankingLength + 1), (flankingLength + 1)))\
  message("ref Fasta seq retrieval: [DONE]")

  # variant seq
  fasta.seq.var = fasta.seq.ref
  substr(fasta.seq.var, (flankingLength + 1), (flankingLength + 1)) <- as.character(dat$Alt)
  message("variant Fasta seq retrieval: [DONE]")
  
  # print(substring(fasta.seq.var, (flankingLength + 1),(flankingLength + 1)))
  # substring(fasta.seq,(flankingLength + 1),(flankingLength + 1))

  dat = cbind(fasta.seq.ref, fasta.seq.var, dat$Label)
  colnames(dat) <- c("refDNAseq", "varDNAseq", "Label")
  # dat = cbind(dat$Ref, dat$Alt, flankingLength, fasta.seq.ref, dat$Label)
  # colnames(dat) <- c("Ref","Alt", "Pos", "refDNAseq", "Label")
  return(dat)
}

# start
flankingLength = 500
library(data.table)
library(dplyr)

dir = "/srv/scratch/z3526914/DeepBrain/Data/"

# filename="brain_specific_eQTL"
# allSNPFileName = "SNPS_DER_08a"
# codingExonFileName = "CODING.EXONS"
# ncSNPFileName = "NONCODING_08a.SNPS"

# # True Positives (i.e. Functional SNPs - Brain-based)
# dat = fread(paste0(dir, filename, ".txt")) %>% as.data.frame()
# dat.sm = dat[,c(10,11,12,9,20,21,6)]     # "SNP_chr"   "SNP_start" "SNP_end"   "SNP_id"    "REF"       "ALT" "strand"
# # find unique snps
# dat.sm = dat.sm[!duplicated(dat.sm[,-c(5,6,7)]),]
# fwrite(dat.sm, paste0(dir,allSNPFileName,".BED"), col.names=F, sep="\t")   # this list has both coding and non-coding SNPs)

# message("Intersect BED to get non-coding based SNPs:",appendLF=F)
# system2('intersectBed', 
#         paste0('-v -a ', paste0(dir, allSNPFileName,".BED "), ' -b ', paste0(dir,codingExonFileName,".BED ")), 
#         stdout=paste0(dir,ncSNPFileName,".BED"), 
#         wait=T)
# message("Done",appendLF=T)

allSNPFileName = "SNPS_DER_08d"
codingExonFileName = "CODING.EXONS"
ncSNPFileName = "NONCODING_08d.SNPS"

# True positives (the most stringent one: FDR<0.05 and a filter requiring genes to have an expression > 1 FPKM in at least 20% of the samples)
filename="DER-08d_hg19_eQTL.FPKM1_20per"
dat = fread(paste0("http://resource.psychencode.org/Datasets/Derived/QTLs/", filename, ".txt")) %>% as.data.frame()

dat.sm = dat[,c(9,10,11,8,5, 15)]     # "SNP_chr"   "SNP_start" "SNP_end"   "SNP_id"    "strand"  "FDR"
# find unique snps
dat.sm = dat.sm[!duplicated(dat.sm[,-c(5,6)]),]

# select top-most (10%) significant SNPs (based on ascending FDR-value)
# n = as.integer(nrow(dat.sm)*0.1) # which is ~10% of all SNPS in the file
# dat.sm = dat.sm[order(dat.sm$FDR),]
# dat.sm = dat.sm[1:n,] 
# allSNPFileName = paste0(allSNPFileName, "_top_10_perc")
# ncSNPFileName = paste0(ncSNPFileName, "_top_10_perc")

# dat.sm = dat[,c(9,10,11,8,5)]     # "SNP_chr"   "SNP_start" "SNP_end"   "SNP_id"    "strand"
# # find unique snps
# dat.sm = dat.sm[!duplicated(dat.sm[,-c(5)]),]
# get snp allele info
allele.info = fread("http://resource.psychencode.org/Datasets/Derived/QTLs/SNP_Information_Table_with_Alleles.txt") %>% as.data.frame()
dat.sm.comb = dplyr::inner_join(dat.sm, allele.info, by=c("SNP_id" = "PEC_id"))
dat.sm.comb = dat.sm.comb %>% dplyr::select(c("SNP_chr","SNP_start","SNP_end","SNP_id","REF","ALT", "strand"))
fwrite(dat.sm.comb, paste0(dir,allSNPFileName,".BED"), col.names=F, sep="\t")   # this list has both coding and non-coding SNPs)


# for HGMD file
# first run process_HGMD_file.R file (https://github.com/Akmazad/deepPsych/blob/master/Data%20Processing/Variant%20data%20processing/process_HGMD_file.R)
# allSNPFileName = "HGMD_Search_Results_PromoterActivity_processed"

message("Intersect BED to get non-coding based SNPs:",appendLF=F)
system2('intersectBed', 
        paste0('-v -a ', paste0(dir, allSNPFileName,".BED "), ' -b ', paste0(dir,codingExonFileName,".BED ")), 
        stdout=paste0(dir,ncSNPFileName,".BED"), 
        wait=T)
message("Done",appendLF=T)




# read the non
ncSNPs = fread(paste0(dir,ncSNPFileName,".BED")) %>% as.data.frame() %>% dplyr::select(c(1,2,5,6,7))
colnames(ncSNPs) = c("Chr", "Pos", "Ref", "Alt", "Strand")
ncSNPs$Label = "1"
# invoke function for sequence retreival and save
fwrite(getVariantSeq(ncSNPs, flankingLength), file = paste0(dir, filename, "_", ncSNPFileName, "_fastaseq_Positives.csv"), sep = ",")


# True Negative (i.e. non-Functional SNPs - from deepSea supple table 5)
filename="deepsea_supple_tabale5"
# anything other than "eQTL" is negative
dat = fread(paste0(dir, filename, ".csv")) %>% dplyr::filter(label != "eQTL") %>% as.data.frame() 
# dat[,8] = ifelse(dat[,8] == "eQTL",1,0)
dat = dat[,c(2,3,4,5)]
colnames(dat) <- c("Chr","Pos","Ref","Alt")
dat$Label = "0"
dat$Strand = "+"

# invoke function for sequence retreival and save
fwrite(getVariantSeq(dat, flankingLength), file = paste0(dir, filename, "_fastaseq_Negatives.csv"), sep = ",")
