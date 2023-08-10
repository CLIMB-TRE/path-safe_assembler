process etoki_prepare {

    label 'process medium'

    publishDir "${params.out_dir}/${sample_uuid}/trimmed_reads/", mode: 'copy'

    container 'biocontainers/etoki:1.2.3--hdfd78af_0'

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
    python EToKi.py prepare --pe ${fastq_1},${fastq_2} -p ${sample_uuid} -m $task.memory
    """
}

process etoki_assemble {

    label 'process medium'

    publishDir "${params.out_dir}/${sample_uuid}/assembly/", mode: 'copy'

    container 'biocontainers/etoki:1.2.3--hdfd78af_0'

    input:
    val sample_uuid
    path fastq_1
    path fastq_2

    output:
    path "${sample_uuid}_result.fasta"

    script:
    """
    python EToKi.py assemble --pe ${fastq_1},${fastq_2} -p ${sample_uuid}
    """
}

workflow {
    Channel
        .of (fastq_1, fastq_2)
        .set { fastq_1_ch, fastq_2_ch }
    
    etoki_prepare(sample_uuid, fastq_1_ch, fastq_2_ch) | etoki_assmeble

}