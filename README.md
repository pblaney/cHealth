# cHealth
clonal HEmopoiesis And teLomere lengTH

This repository holds the scripts and files used for the bioinformatic analysis of whole-exome sequencing data as described in [Improving prognostic assignment in older adults with multiple myeloma using acquired genetic features, clonal hemopoiesis and telomere length](https://www.nature.com/articles/s41375-021-01320-3)

## Analysis Workflow
The analysis is largely executed within the `clonalHematopoiesisOfCommpassPatients.Rmd` which includes detailed comments on each step in the workflow.

However, the full detailed methods are included in the **Bioinformatics analysis of massively parallel sequencing data alignments** section of the Supplemental material of the paper linked above.


### Dependencies
The scripts rely on the following `R` associated libraries and `singularity`:
* `dplyr`
* `readr`
* `spatstat.utils`

*NOTE: These scripts were written and designed to be executed on BigPurple, the HPC for NYU Langone Health*