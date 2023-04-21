/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowSpliceview.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.multiqc_config, params.fasta ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.input_alt) { ch_input_alt = Channel.of(file(params.input_alt)) } else { exit 1, 'Path to folder containing fastq.gz files is not specified!' }
if (params.read1_extension) { ch_read1_extension = Channel.of(params.read1_extension) } else { exit 1, 'Read 1 extension is not specified. Do the files for forward reads all end with `_1.fastq.gz`?' }
if (params.read2_extension) { ch_read2_extension = Channel.of(params.read2_extension) } else { exit 1, 'Read 2 extension is not specified. DO the files for reverse reads all end with `_2.fastq.gz`?' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { FASTQ_DIR_TO_SAMPLESHEET } from '../subworkflows/local/fastq_dir_to_samplesheet.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { GUNZIP                      } from '../modules/nf-core/gunzip/main'
include { FASTQC                      } from '../modules/nf-core/fastqc/main'
include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
include { CUTADAPT                    } from '../modules/nf-core/cutadapt/main'  
include { STAR_GENOMEGENERATE         } from '../modules/nf-core/star/genomegenerate/main'    
include { STAR_ALIGN                  } from '../modules/nf-core/star/align/main'  
include { SAMTOOLS_INDEX              } from '../modules/nf-core/samtools/index/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow SPLICEVIEW {

    ch_versions = Channel.empty()

    fasta = params.fasta
    if (fasta.endsWith('.gz')) {
        ch_fasta    = GUNZIP ( [ [:], fasta ] ).gunzip.map { it[1] }
        ch_versions = ch_versions.mix(GUNZIP.out.versions)
    } else {
        ch_fasta = file(fasta)
    }
    
    gtf = params.gtf
    if (gtf.endsWith('.gz')) {
        ch_gtf      = GUNZIP ( [ [:], gtf ] ).gunzip.map { it[1] }
        ch_versions = ch_versions.mix(GUNZIP.out.versions)
    } else {
        ch_gtf = file(gtf)
    }

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    FASTQ_DIR_TO_SAMPLESHEET (
        ch_input_alt,
        ch_read1_extension, 
        ch_read2_extension
    )
    ch_input = FASTQ_DIR_TO_SAMPLESHEET.out.input_table  // #TODO DEFINE input_table IN local subworkflow fastq_dir_to_samplesheet.nf

    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    // //
    // // MODULE: Run FastQC
    // //
    // FASTQC (
    //     INPUT_CHECK.out.reads
    // )
    // ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    // //
    // // MODULE: CUTADAPT
    // //
    // ch_reads = Channel.empty()
    // CUTADAPT (
    //     INPUT_CHECK.out.reads
    // )    
    // ch_reads = CUTADAPT.out.reads
    // ch_versions = ch_versions.mix(CUTADAPT.out.versions)

    // //
    // // MODULE: STAR GENOME GENERATE
    // //
    // star_index = params.star_index
    // ch_star_index = Channel.empty()
    // if (star_index) {
    //     if (star_index.endsWith('.tar.gz')) {
    //         ch_star_index = UNTAR_STAR_INDEX ( [ [:], star_index ] ).untar.map { it[1] }
    //         ch_versions   = ch_versions.mix(UNTAR_STAR_INDEX.out.versions)
    //     } else {
    //         ch_star_index = Channel.value(file(star_index))
    //     }
    // } else {
    //     STAR_GENOMEGENERATE ( 
    //         ch_fasta, 
    //         ch_gtf 
    //     )    
    //     ch_star_index = STAR_GENOMEGENERATE.out.index
    //     ch_versions = ch_versions.mix(STAR_GENOMEGENERATE.out.versions)
    // }

    // //
    // // MODULE: STAR ALIGN
    // //
    // ch_aligned_reads         = Channel.empty()
    // ch_aligned_sorted_reads  = Channel.empty()
    // star_ignore_sjdbgtf      = Channel.value(params.star_ignore_sjdbgtf)

    // STAR_ALIGN (
    //     ch_reads,
    //     ch_star_index,
    //     ch_gtf,
    //     star_ignore_sjdbgtf,
    //     '',
    //     params.seq_center ?: ''
    // )    
    // ch_aligned_reads = STAR_ALIGN.out.bam
    // ch_aligned_sorted_reads = STAR_ALIGN.out.bam_sorted
    // ch_versions = ch_versions.mix(STAR_ALIGN.out.versions)

    // //
    // // MODULE: SAMTOOL INDEX
    // //
    // ch_aligned_sorted_reads_index = Channel.empty()
    // star_ignore_sjdbgtf = Channel.value(params.star_ignore_sjdbgtf)
    // SAMTOOLS_INDEX (
    //     ch_aligned_sorted_reads
    // )    
    // ch_aligned_sorted_reads_index = SAMTOOLS_INDEX.out.bai
    // ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions)

    // CUSTOM_DUMPSOFTWAREVERSIONS (
    //     ch_versions.unique().collectFile(name: 'collated_versions.yml')
    // )

    // //
    // // MODULE: MultiQC
    // //
    // workflow_summary    = WorkflowSpliceview.paramsSummaryMultiqc(workflow, summary_params)
    // ch_workflow_summary = Channel.value(workflow_summary)

    // methods_description    = WorkflowSpliceview.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    // ch_methods_description = Channel.value(methods_description)

    // ch_multiqc_files = Channel.empty()
    // ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    // ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

    // MULTIQC (
    //     ch_multiqc_files.collect(),
    //     ch_multiqc_config.toList(),
    //     ch_multiqc_custom_config.toList(),
    //     ch_multiqc_logo.toList()
    // )
    // multiqc_report = MULTIQC.out.report.toList()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
