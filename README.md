[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/zbi/spliceview)

## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->

**zbi/spliceview** is a bioinformatics best-practice analysis pipeline for Pipeline for extracting alignment information from a genomic regions for inspection of splicing events.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

<!-- TODO nf-core: Add full-sized test dataset and amend the paragraph below if applicable -->

On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources.

## Pipeline summary

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))
3. Perform adapter/quality trimming on sequencing reads (https://cutadapt.readthedocs.io/en/stable/#)
4. Create genome index for STAR alignment (https://github.com/alexdobin/STAR) 
5. Align reads using reference genome index (https://github.com/alexdobin/STAR)
6. Generate alignment files in .bam format and its index in .bam.bai format for IGV

## Quick Start

### Step 1
Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)

### Step 2
Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

### Step 3
Download the pipeline and test it on a minimal dataset with a single command:

   ```bash
   nextflow run zbi/spliceview -profile test,docker
   ```

### Step 4
Start running your own analysis!

#### I. Check for pipeline requirements
##### 1. Working directory setup
🏠**/home/trang/**\
┣ 📦SpliceView\
┣ 📦TEST\
┃  ┣ 📂genomes\
┃  ┃ ┗ 📂mm10\
┃  ┣ 📂mRNA_seq\
┃  ┃ ┗ 📂raw_files\
┃  ┃ ┃ ┣ 📂testdata\
┃  ┃ ┃ ┃ ┣ 📜samplesheet.csv\
┃  ┃ ┃ ┃ ┣ 📜test1_1.fastq.gz\
┃  ┃ ┃ ┃ ┗ 📜test1_2.fastq.gz\
┃  ┣ 📂spliceview_testdata\
┃  ┃ ┣ 📂cutadapt\
┃  ┃ ┣ 📂fastqc\
┃  ┃ ┣ 📂genomes\
┃  ┃ ┃ ┗ 📂mm10\
┃  ┃ ┃ ┃ ┗ 📂star\
┃  ┃ ┣ 📂multiqc\
┃  ┃ ┃ ┣ 📂multiqc_data\
┃  ┃ ┃ ┗ 📜multiqc_report.html\
┃  ┃ ┣ 📂pipeline_info\
┃  ┃ ┣ 📂star_align_log\
┃  ┃ ┗ 📂star_align_result\
┃  ┃ ┃ ┣ 📜**test1_T1.Aligned.sortedByCoord.out.bam**\
┃  ┃ ┃ ┗ 📜**test1_T1.Aligned.sortedByCoord.out.bam.bai**


##### 2. Mandatory arguments
`--input`
- [ ] The full path to the folder where fastq-files are stored. 
**For example:** With the above folder structure, `--input` is #TODO   
- [ ] All fastq-files should be compressed and end with **.gz**. You can use `gzip file.fastq` command to compress a .fastq files. 
- [ ] For paired-end fastq-files in `--input` folder, forward reads must end with **_1.fastq.gz** and reverse reads must end with **_2.fastq.gz**. 

- **For example:** For a paired-end sample WT with 2 replicates, the files should be named: for 
   - Replicate 1: _WT_Rep1_1.fastq.gz_ and _WT_Rep1_2.fastq.gz_ 
   - Replicate 2: _WT_Rep2_1.fastq.gz_ and _WT_Rep2_2.fastq.gz_


`--outdir`
- [ ] The full path to the folder where all outputs and logs are stored. 
**For example:** With the above folder structure, `--outdir` is #TODO 


`--genome`
- [ ] The reference genome used for STAR genome indexing and STAR alignment. 
**For example:** The reference genome options for human is **GRCh38** or **GRCh37**, and for mouse is **mm10**.

- ❗️ Defining `--genome` will download and use the reference genome from iGenome database. If you wish to use an existing version of the reference genome, please define `--fasta` **and** `--gtf` and do not include `--genome` in the command line. See [here](#####1.-OPTION-1) and [here](#####3.-OPTION-3)


`--fasta`
- [ ] The reference genome FASTA file used for STAR genome indexing and STAR alignment **UNLESS** `--genome` is defined (see `--genome`). 
**For example:** The path to FASTA file in the above folder structure is #TODO
- [ ] `--fasta` must be declared together with `--gtf`


`--gtf`
- [ ] The reference genome GTF file used for STAR genome indexing and STAR alignment **UNLESS** `--genome` is defined (see `--genome`). 
**For example:** The path to GTF file in the above folder structure is #TODO
- [ ] `--gtf` must be declared together with `--fasta`


`-profile` 
- [ ] Always use **docker** as --profile
- ❗️ There is only one hyphen (-) in front of this parameter, while all other require two hyphens (--)

##### 3. Optional arguments
`--star_index` 
- Path to the folder containing a prebuilt/generated genome index. This parameter can be used when a specific genome index has been created successfully from a previous run. 
- Using `--star_index` speeds up the process significantly as genome indexing step  requires extensive time and memory (For test data, `--star_index` can reduce run time from 1 hour to 5 minutes). 

- **For example:** The path to genome index in the above folder structure is #TODO. This genome index is generated from previous run using the 'mm10' mouse reference genome, which is intially stored in #TODO. 

- ❗️ It is highly recommended to copy the genome index to a folder such as #TODO once it is generated successfully from a run for **reusing** purpose.
- ❗️ `--genome` must be defined when `--star_index` is used

`--extra_star_align_args`
- Extra arguments to pass to STAR alignment that can be found [here](https://physiology.med.cornell.edu/faculty/skrabanek/lab/angsd/lecture_notes/STARmanual.pdf)
- **For example:** _--outSAMtype BAM SortedByCoordinate --readFilesCommand gunzip -c_ 

`--fastq_dir_to_samplesheet_args`
- Extra arguments to pass to fastq_dir_to_samplesheet.py to prepare samplesheet for Nextflow pipeline that can be found [here](https://github.com/nf-core/rnaseq/blob/master/bin/fastq_dir_to_samplesheet.py)
- **For example:** _--single_end true --recursive true_


#### II. Run pipeline
##### 1. OPTION 1
Download and use FASTA/GTF reference genome files from iGenome for genome indexing:
```bash
nextflow run zbi/spliceview\
   --input <ABSOLUTE_PATH_TO_FASTQ_FILES_FOLDER>\
   --outdir <ABSOLUTE_PATH_TO_RESULT_FOLDER>\
   --genome #TODO\
   -profile docker
```
<sup>* Please make sure there is no empty space behind the slash ( **\\** ) at the end of each line</sup>

Note:
- `--genome` must be defined for downloading the reference genome from iGenome database


##### 2. OPTION 2
Use self-defined/existing FASTA/GTF reference genome files for genome indexing:
```bash
nextflow run zbi/spliceview\
   --input <ABSOLUTE_PATH_TO_FASTQ_FILES_FOLDER>\
   --outdir <ABSOLUTE_PATH_TO_RESULT_FOLDER>\
   --fasta <ABSOLUTE_PATH_TO_FASTA_FILE>\
   --gtf <ABSOLUTE_PATH_TO_GTF_FILE>\
   -profile docker
```
<sup>* Please make sure there is no empty space behind the slash ( **\\** ) at the end of each line</sup>

Note:
- `--fasta` *and* `--gtf` must be defined while `--genome` is not provided


##### 3. OPTION 3
Use a previously generated genome index and skip STAR indexing (less time-consuming):
```bash
nextflow run zbi/spliceview\
   --input <ABSOLUTE_PATH_TO_FASTQ_FILES_FOLDER>\
   --outdir <ABSOLUTE_PATH_TO_RESULT_FOLDER>\
   --genome #TODO\
   --star_index <ABSOLUTE_PATH_TO_STAR_INDEX_FOLDER>\
   -profile docker
```
<sup>* Please make sure there is no empty space behind the slash ( **\\** ) at the end of each line</sup>

Note:
- `--genome` must be defined when `--star_index` is used


#### III. PIPELINE RESULTS


## Credits

zbi/spliceview was originally written by Trang Do.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
