nextflow.enable.dsl=2

process transcriptome_quantification_se_app {
    tag "Kallisto Quantification (single_end) - ${sample_id}"

    publishDir "${params.results_dir}/transcriptome_quantification/single_end", mode: 'copy'

    input:
        tuple val(sample_id), path(fastq_files), path(transcriptome_index)

    output:
        path "${sample_id}_se_abundance.tsv", emit: kallisto_quant_abundance_tsv_ch
        path "${sample_id}_se_abundance.h5", emit: kallisto_quant_abundance_h5_ch

    script:
        """
        echo "Running kallisto quant (single-end) for ${sample_id}"
        kallisto quant -i ${transcriptome_index} -o single_end -b 10 --single -l 550 -s 150 ${fastq_files}
        # Rename output before Nextflow stages it to avoid input file name collision
        mv single_end/abundance.tsv ${sample_id}_se_abundance.tsv
        mv single_end/abundance.h5 ${sample_id}_se_abundance.h5
        """

    stub:
        """
        echo "Stubbing Kallisto quant (single-end)"
        touch ${sample_id}_se_abundance.tsv
        touch ${sample_id}_se_abundance.h5
        """
}

process transcriptome_quantification_pe_app {
    tag "Kallisto Quantification (paired_end) - ${sample_id}"

    publishDir "${params.results_dir}/transcriptome_quantification/paired_end", mode: 'copy'

    input:
        tuple val(sample_id), path(fastq_files), path(transcriptome_index)

    output:
        path "${sample_id}_pe_abundance.tsv", emit: kallisto_quant_abundance_tsv_ch
        path "${sample_id}_pe_abundance.h5", emit: kallisto_quant_abundance_h5_ch

    script:
        """
        echo "Running kallisto quant (paired-end) for ${sample_id}"
        mkdir -p paired_end
        kallisto quant -i ${transcriptome_index} -o paired_end -b 10 ${fastq_files[0]} ${fastq_files[1]}
        # Rename output before Nextflow stages it to avoid input file name collision
        mv paired_end/abundance.tsv ${sample_id}_pe_abundance.tsv
        mv paired_end/abundance.h5 ${sample_id}_pe_abundance.h5
        """

    stub:
        """
        echo "Stubbing Kallisto quant (paired-end)"
        touch ${sample_id}_pe_abundance.tsv
        touch ${sample_id}_pe_abundance.h5
        """
}

workflow transcriptome_quantification_se_wf {
    take:
        sample_input

    main:
        transcriptome_quantification_se_app(
            sample_input = sample_input
        )

    emit:
        kallisto_quant_abundance_tsv_ch = transcriptome_quantification_se_app.out.kallisto_quant_abundance_tsv_ch
        kallisto_quant_abundance_h5_ch = transcriptome_quantification_se_app.out.kallisto_quant_abundance_h5_ch
}

workflow transcriptome_quantification_pe_wf {
    take:
        sample_input

    main:
        transcriptome_quantification_pe_app(
            sample_input = sample_input
        )

    emit:
        kallisto_quant_abundance_tsv_ch = transcriptome_quantification_pe_app.out.kallisto_quant_abundance_tsv_ch
        kallisto_quant_abundance_h5_ch = transcriptome_quantification_pe_app.out.kallisto_quant_abundance_h5_ch
}

// Testing Workflow to be used with module test_input.json
workflow {
    def sample_input_ch = Channel.fromList(params.sample_input)
    def transcriptome_index_ch = Channel.fromPath(params.transcriptome_index)

    // Transcriptome single-end quantification for testing module
    transcriptome_quantification_se_wf(
        sample_input = sample_input_ch.combine(transcriptome_index_ch),
    )
}