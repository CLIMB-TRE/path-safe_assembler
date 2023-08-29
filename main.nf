process etoki_prepare {

    label 'process_medium'

    publishDir "${params.out_dir}/${sample_uuid}/trimmed_reads/", mode: 'copy'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'library://library/biowilko/etoki/etoki:0.1' :
        'biocontainers/etoki:1.2.3--hdfd78af_0' }"

    input:
    val sample_uuid
    path fastq_1
    path fastq_2

    output:
    val sample_uuid
    path "${sample_uuid}_L1_R1.fastq.gz"
    path "${sample_uuid}_L1_R2.fastq.gz"

    script:
    """
    /bin/sh EToKi.py prepare --pe ${fastq_1},${fastq_2} -p ${sample_uuid}
    """
}

process etoki_assemble {

    label 'process_medium'
    label 'process_high_memory'

    publishDir "${params.out_dir}/${sample_uuid}/assembly/", mode: 'copy'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'library://library/biowilko/etoki/etoki:0.1' :
        'biocontainers/etoki:1.2.3--hdfd78af_0' }"

    input:
    val sample_uuid
    path fastq_1
    path fastq_2

    output:
    path "${sample_uuid}/etoki.mapping.reference.fasta"

    script:
    """
    /bin/sh EToKi.py assemble --pe ${fastq_1},${fastq_2} -p ${sample_uuid}
    """
}

workflow {

    Channel
        .of(file(params.fastq_1, type: "file", checkIfExists:true))
        .set { fastq_1_ch }

    Channel
        .of(file(params.fastq_2, type: "file", checkIfExists:true))
        .set { fastq_2_ch }

    
    etoki_prepare(params.sample_uuid, fastq_1_ch, fastq_2_ch) | etoki_assemble

}