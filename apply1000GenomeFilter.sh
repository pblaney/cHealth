#!/bin/bash

####################	Help Message	####################
Help()
{
	# Display help message
	echo "This script will submit a SLURM batch job that apply a mask filter to a variant callset"
	echo 
	echo "Usage:"
	echo '	./apply1000GenomeFilter.sh [filterScript] [variantCalls] [filterName] [filterFile]'
	echo 
	echo "Argument Descriptions:"
	echo "	[-h]		Print this message"
	echo "	[filterScript]	The name of the specific R script to execute the filtering: 1000GenomeRegionVariantFilter.R or strictMaskFilter.R"
	echo "	[variantCalls]	The user-defined text file containing variant callset to be filtered"
	echo "	[filterName]	The name of the filter being applied, will be used in output filename, see filters directory"
	echo "	[filterFile]	The BED file for the filter being applied, see filters directory"
	echo 
	echo "Usage Example:"
	echo '	./apply1000GenomeFilter.sh 1000GenomeRegionVariantFilter.R variantCalls.basefilter.txt LRC data/filters/LCR-hg38.bed'
	echo 
}

while getopts ":h" option;
	do
		case $option in
			h) # Show help message
				Help
				exit;;
		    \?) # Reject other passed options
				echo "Invalid option"
				exit;;
		esac
	done

############################################################

# Debugging settings
set -euo pipefail

# User defined filter script (1000 Genome Region or Strict Mask), variant call set, filter
# name, and filter file
filterScript=${1}
variantCalls=${2}
filterName=${3}
filterFile=${4}

# Set chromosome list
declare -a chromList=("chr1" "chr2" "chr3" "chr4" "chr5"
	                  "chr6" "chr7" "chr8" "chr9" "chr10"
	                  "chr11" "chr12" "chr13" "chr14" "chr15"
	                  "chr16" "chr17" "chr18" "chr19" "chr20"
	                  "chr21" "chr22" "chrX" "chrY")

# Loop through the chromosome list and submit a batch command to run the filter script
for chrom in "${chromList[@]}"
do
	batchCommand="
	sbatch \
	--job-name=${filterName}_${chrom} \
	${filterScript} \
	${variantCalls} \
	${filterName} \
	${filterFile} \
	${chrom}"

	eval "$batchCommand"
done
