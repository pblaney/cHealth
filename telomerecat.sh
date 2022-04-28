#!/bin/bash

#SBATCH --partition=cpu_short
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=3:00:00
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --mail-user=patrick.blaney@nyulangone.org
#SBATCH --output=telomerecat-%x.log


####################	Help Message	####################
Help()
{
	# Display help message
	echo "This script will run Telomerecat on the user-defined input BAM"
	echo 
	echo "Usage:"
	echo '	sbatch --job-name=[jobName] /path/to/telomerecat.sh [inputBam]'
	echo 
	echo "Argument Descriptions:"
	echo "	[-h]		Print this message"
	echo "	[jobName]	The name of the SLURM job, must be unique"
	echo "	[inputBam]	The user-defined BAM to perform the telomere lenght estimation"
	echo 
	echo "Usage Example:"
	echo '	sbatch --job-name=test ~/telomerecat.sh test.bam'
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

echo "###########################################################"
echo "#                      Telomerecat                        #"
echo "###########################################################"
echo 

# Load in Singularity
module load singularity/3.7.1

# List modules for quick debugging
module list -t
echo 

# Set a variable to hold user defined input BAM file
inputBam=$1

# Isolate the sample ID
sampleId=$(echo "${inputBam}" | sed -E 's|\..*bam||')

# Calculate telomere length estimates for each BAM
singularity exec -B $PWD:/data --pwd /data telomerecat-3.4.0.simg telomerecat bam2length -p 4 -v 1 --temp_dir . --output "${sampleId}_telomerecat.csv" "${inputBam}"
