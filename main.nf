process etoki_prepare {

    label 'process_medium'

    publishDir "${params.out_dir}/${sample_uuid}/trimmed_reads/", mode: 'copy'

    container 'biowilko/etoki:1.2.1'

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
    EToKi.py prepare --pe ${fastq_1},${fastq_2} -p ${sample_uuid}
    """
}

process etoki_assemble {

    label 'process_medium'

    publishDir "${params.out_dir}/${sample_uuid}/assembly/", mode: "copy", pattern: "${sample_uuid}.result.fasta"
    publishDir "${params.out_dir}/${sample_uuid}", mode: "copy", pattern: "etoki_outputs"

    container 'biowilko/etoki:1.2.1'

    errorStrategy {task.exitStatus == 255 ? "ignore" : "terminate"}

    input:
    val sample_uuid
    path fastq_1
    path fastq_2

    output:
    path "${sample_uuid}.result.fasta"
    path "etoki_outputs"

    script:
    """
    EToKi.py assemble --pe ${fastq_1},${fastq_2} -p ${sample_uuid}

    if [ -f ${sample_uuid}/etoki.fasta ]; then
        mv ${sample_uuid}/etoki.fasta ${sample_uuid}.result.fasta
    fi

    mv ${sample_uuid} etoki_outputs
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