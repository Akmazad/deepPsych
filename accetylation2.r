# ba9_81.filepath <- "C:\\Users\\z3526914\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_BA9_81_April2015_LR.csv"
# ba41_66.filepath <- "C:\\Users\\z3526914\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_BA41_66_Mar2015_LR.csv"
# baVermis_62.filepath <- "C:\\Users\\z3526914\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_Vermis_62_Mar2015_LR.csv"
# samplefilePath = "C:\\Users\\z3526914\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\BrainSampleList.csv"
# chrFile = "C:\\Users\\z3526914\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\chromosome_Length.csv"
# outputPath = "C:\\Users\\z3526914\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data"

ba9_81.filepath <- "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_BA9_81_April2015_LR.csv"
ba41_66.filepath <- "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_BA41_66_Mar2015_LR.csv"
baVermis_62.filepath <- "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\normalized_log2_tags_Vermis_62_Mar2015_LR.csv"
samplefilePath = "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\Brain_Prabhakar_H3K27Ac\\BrainSampleList.csv"
chrFile = "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data\\chromosome_Length.csv"
outputPath = "C:\\Users\\Azad\\OneDrive - UNSW\\Vafaee Lab\\Projects\\Deep Brain\\Data"

accetylationDat <- function(ba9_81.filepath, ba41_66.filepath, baVermis_62.filepath, samplefilePath, chrFile, binSize, overlapCutoff, outputPath){
  library("reproducible")
  ### load files
  ba9_81.dat <- read.csv(ba9_81.filepath,header = TRUE)
  ba41_66.dat <- read.csv(ba41_66.filepath,header = TRUE)
  baVermis.dat <- read.csv(baVermis_62.filepath,header = TRUE)
  sample.dat <- read.csv(samplefilePath,header = TRUE,stringsAsFactors = FALSE)
  
  ## make header (includes sampleID composed as brainID.RegionID)
  header <- c("ChrID", "start", "end", paste0(sample.dat$BrainID,".",sample.dat$RegionID))
  
  ## read chromosome length file
  chrInfo = read.csv(file=chrFile, sep="\t", stringsAsFactors = FALSE)
  chrInd <- 1
  out <- NULL
  while(chrInd <=1 ){
    chrID <- toString(chrInfo$chrID[chrInd])
    chrLength <- chrInfo$chr_length[chrInd]
    wStart <- 12900
    binID <- 1
    #while (wStart < chrLength){
    while (wStart < 13200){
      wEnd <- if(wStart + binSize - 1 <= chrLength) (wStart + binSize - 1) else chrLength
      ## read data within a window of a particular chromosom       
      dat <- Copy(ba9_81.dat)
      cond1 <- which((dat[,1]==paste0("chr",chrInd)) && (dat[,2] <= wStart && dat[,3] >= wEnd)) ## whole window contained
      #rStart <- if ((dat[,2] - dat[,2]*overlapCutoff) >= 0) (dat[,2] - dat[,2]*overlapCutoff) else 0
      #rEnd <- if ((dat[,3] + dat[,3]*overlapCutoff) <= chrLength) (dat[,3] + dat[,3]*overlapCutoff) else chrLength
      #cond2 <- which((dat[,1]==paste0("chr",chrInd)) && (rStart <= wStart && dat[,3] >= wEnd))   ## window start is before the chr start
      #cond3 <- which((dat[,1]==paste0("chr",chrInd)) && (dat[,2] <= wStart && rEnd >= wEnd))   ## window end is after the chr end
      #temp.ba9_81 <- ba9_81.dat[cond1||cond2 ||cond3,]
      temp.ba9_81 <- Copy(ba9_81.dat[cond1,])
      
      dat <- Copy(ba41_66.dat)            ## affects the conditions
      cond1 <- which((dat[,1]==paste0("chr",chrInd)) && (dat[,2] <= wStart && dat[,3] >= wEnd)) ## whole window contained
      #rStart <- if ((dat[,2] - dat[,2]*overlapCutoff) >= 0) (dat[,2] - dat[,2]*overlapCutoff) else 0
      #rEnd <- if ((dat[,3] + dat[,3]*overlapCutoff) <= chrLength) (dat[,3] + dat[,3]*overlapCutoff) else chrLength
      #cond2 <- which((dat[,1]==paste0("chr",chrInd)) && (rStart <= wStart && dat[,3] >= wEnd))   ## window start is before the chr start
      #cond3 <- which((dat[,1]==paste0("chr",chrInd)) && (dat[,2] <= wStart && rEnd >= wEnd))   ## window end is after the chr end
      #temp.ba41_66 <- ba41_66.dat[cond1|| cond2||cond3,]
      temp.ba41_66 <- Copy(ba41_66.dat[cond1,])
      
      dat <- Copy(baVermis.dat)           ## affects the conditions
      cond1 <- which((dat[,1]==paste0("chr",chrInd)) && (dat[,2] <= wStart && dat[,3] >= wEnd)) ## whole window contained
      #rStart <- if ((dat[,2] - dat[,2]*overlapCutoff) >= 0) (dat[,2] - dat[,2]*overlapCutoff) else 0
      #rEnd <- if ((dat[,3] + dat[,3]*overlapCutoff) <= chrLength) (dat[,3] + dat[,3]*overlapCutoff) else chrLength
      #cond2 <- which((dat[,1]==paste0("chr",chrInd)) && (rStart <= wStart && dat[,3] >= wEnd))   ## window start is before the chr start
      #cond3 <- which((dat[,1]==paste0("chr",chrInd)) && (dat[,2] <= wStart && rEnd >= wEnd))   ## window end is after the chr end
      #temp.baVermis <- baVermis.dat[cond1||cond2||cond3,]
      temp.baVermis <- Copy(baVermis.dat[cond1,])
      
      names(temp.ba9_81) <- paste0(names(temp.ba9_81),".","ba9")
      names(temp.ba41_66) <- paste0(names(temp.ba41_66),".","ba41-42-22")
      names(temp.baVermis) <- paste0(names(temp.baVermis),".","vermis")
      
      aRow <- NULL
      aRow <- cbind(aRow,chrInd, wStart,wEnd)
      i <- 1
      while(i <= length(sample.dat$BrainID)) {
        sam <- paste0(sample.dat$BrainID[i], ".", sample.dat$RegionID[i])     
        toCheck <- NULL
        if(sample.dat$RegionID[i] == "ba9"){
          toCheck <- Copy(temp.ba9_81)
        }else if(sample.dat$RegionID[i] == "ba41-42-22"){
          toCheck <- Copy(temp.ba41_66)
        }else{
          toCheck <- Copy(temp.baVermis)
        }
        val <- if(!is.null(toCheck[[sam]]) && length(toCheck[[sam]]) > 0) toCheck[[sam]] else NA
        print(paste(sam, toCheck[[sam]], length(toCheck[[sam]])), appendLF=FALSE)
        aRow <- cbind(aRow,val)
        ##rm(toCheck)
        i <- i + 1
      }
      ##message(paste(wEnd, ""), appendLF=FALSE)
      ## bind that row
      out <- rbind(out,aRow)
      wStart <- wEnd + 1
      binID <- binID + 1
    }
    
    chrInd <- chrInd + 1
  }
  names(out) <- header
  #write.csv(out,file = paste(outputPath, "\\outputAccetylation.csv"))
  write.csv(out,file = "outputAccetylation.csv")
}

accetylationDat(ba9_81.filepath, ba41_66.filepath, ba41_66.filepath, samplefilePath, chrFile, 200, overlapCutoff = 0, outputPath)