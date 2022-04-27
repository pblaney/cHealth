#!/usr/bin/env Rscript

#SBATCH --partition=fn_long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
#SBATCH --time=10-00:00:00
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --mail-user=patrick.blaney@nyulangone.org
#SBATCH --output=1000GenomeRegionVariantFilter-%x.log

print("###############################################################", quote = FALSE)
print("#            1000 Genome Region Variant Filter                #", quote = FALSE)
print("###############################################################", quote = FALSE)

# Install and load necessary
library(dplyr, lib.loc = "/gpfs/scratch/blanep01/chipAnalysis/lib/R/library")
library(readr, lib.loc = "/gpfs/scratch/blanep01/chipAnalysis/lib/R/library")
library(spatstat.utils, lib.loc = "/gpfs/scratch/blanep01/chipAnalysis/lib/R/library")

# Accept user defined arguments for the variant calls, name of the filter, filter file,
# and which chromosome to subset with
inputArgs <- commandArgs(trailingOnly = TRUE)
variantCalls <- inputArgs[1]
filterName <- inputArgs[2]
filterFile <- inputArgs[3]
queryChrom <- inputArgs[4]

# LoFreq VCF file
variantCalls <- read_delim(file = variantCalls,
                           delim = "\t",
                           col_names = TRUE)

# Read in filter file
regionFilter <- read_delim(file = filterFile,
                           delim = "\t",
                           col_types = "cdd")

colnames(regionFilter) <- c("chr", "start", "end")

# First subset the variant calls by the specified chromosome and then filter out any
# repeated variant call position to speed up process
callChromSubset <- variantCalls %>%
  filter(CHR == queryChrom)

queryCalls <- callChromSubset %>%
  select(POS) %>%
  unique()

# Check if the chromosome string matches the query chrom format. If it does not, correct it
if(!length(grep("chr", regionFilter$chr[1]))) {
	regionFilter$chr <- paste0("chr", regionFilter$chr)
}

# Subset the region filter by the specified chromosome
regionSubset <- regionFilter %>%
  filter(chr == queryChrom) %>%
  select(start, end)

# Create vector for positions that fail in filter regions and need to be removed
positionsToRemove <- c()

# Loop through all query variant call positions to check if they fall within a filter region
for(i in 1:nrow(queryCalls)) {
  
  position <- queryCalls$POS[i]
  
  for(k in 1:nrow(regionSubset)) {
    
    # Check if the variant's position falls in the range of the filter region, if so
    # add it to the vector and break out of the loop to start checking next position
    if(inside.range(position, range(regionSubset[k,1:2]))) {
      
      positionsToRemove <- append(positionsToRemove, position)
      break
    }
  }
}

# Check if there are positions to remove from the variant call list, if so
# remove them
if(!is.null(positionsToRemove)) {

  filteredCalls <- callChromSubset[!callChromSubset$POS %in% positionsToRemove,]

} else {

  filteredCalls <- callChromSubset
}

# Write the new filtered variant call list to a file
fileName <- sprintf("%s%sFilteredCalls.txt", filterName, queryChrom)
write_delim(x = filteredCalls,
            path = fileName,
            delim = "\t",
            col_names = TRUE)

