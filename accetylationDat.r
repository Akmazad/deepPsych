### ba9_81.filepath <- "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_BA9_81_April2015_LR.csv"
### ba41_66.filepath <- "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_BA41_66_Mar2015_LR.csv"
### baVermis_62.filepath <- "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_Vermis_62_Mar2015_LR.csv"
### chrFile = "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\chromosome_Length.csv"


accetylationDat <- function(ba9_81.filepath, ba41_66.filepath, baVermis_62.filepath, samplefilePath, chrFile, binSize, overlapCutoff, outputPath){
  library("readxl")
  
  ### load the files
  ba9_81.dat <- read.csv(ba9_81.filepath,header = TRUE)
  ba41_66.dat <- read.csv(ba41_66.filepath,header = TRUE)
  baVermis.dat <- read.csv(baVermis_62.filepath,header = TRUE)
  sample.dat <- read_excel(samplefilePath)
  
  ## make header (includes sampleID composed as brainID.RegionID)
  header <- c("ChrID", "start", "end", paste0(sample.dat$BrainID,".",sample.dat$RegionID))
  
  ## read chromosome length file
  chrInfo = read.csv(file=chrFile, sep="\t", stringsAsFactors = FALSE)
  chrInd <- 1
  while(chrInd <=25 ){
    chrID <- toString(chrInfo$chrID[chrInd])
    # message(paste(chrID, " started"), appendLF=TRUE)
    chrLength <- chrInfo$chr_length[chrInd]
    # message(chrLength, appendLF=FALSE)
    start <- 1
    b <- binSize
    binID <- 1
    while (start < chrLength){
      end <- if(start + b - 1 <= chrLength) (start + b - 1) else chrLength
      ## read data within a window of a particular chromosom  
      temp.ba9_81 <- ba9_81.dat[which((ba9_81.dat[,1]==paste0("chr",chrInd)) && (ba9_81.dat[,2] < start && ba9_81.dat[,3] > end)),]
      temp.ba41_66 <- ba41_66.dat[which((ba41_66.dat[,1]==paste0("chr",chrInd)) && (ba41_66.dat[,2] < start && ba41_66.dat[,3] > end)),]
      temp.baVermis <- baVermis.dat[which((baVermis.dat[,1]==paste0("chr",chrInd)) && (baVermis.dat[,2] < start && baVermis.dat[,3] > end)),]
      names(temp.ba9_81) <- paste0(names(temp.ba9_81),".","ba9")
      names(temp.ba41_66) <- paste0(names(temp.ba41_66),".","ba41-42-22")
      names(temp.baVermis) <- paste0(names(temp.baVermis),".","vermis")
      
      for (i in 3:length(sample.dat$BrainID)) {
        sam <- paste0(sample.dat$BrainID[i],".",sample.dat$RegionID[i])
        val <- if(!is.null(temp2[[sam]])) temp2[[sam]] else NULL
          aRow <- cbind(aRow,val)
      }
        
      start <- end + 1
      binID <- binID + 1
    }
    
    chrInd <- chrInd + 1
  }
  
}

