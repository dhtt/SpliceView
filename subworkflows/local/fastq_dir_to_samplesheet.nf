process FASTQ_DIR_TO_SAMPLESHEET {
    tag "$fastq_dir"
    label 'process_single'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:
    path fastq_dir
    val read1_extension
    val read2_extension

    output:
    path '*.csv'       , emit: input_table

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in zbi/spliceview/bin/
    // def samplesheet_dir = ${fastq_dir}/samplesheet.csv
    """
    fastq_dir_to_samplesheet.py \\
        $fastq_dir \\
        samplesheet.csv \\
        -r1 $read1_extension \\
        -r2 $read2_extension
    """
}
