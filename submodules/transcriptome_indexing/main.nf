nextflow.enable.dsl=2

process transcriptome_indexing_app {

    tag "Indexing ${index_basename}"

    publishDir "${index_output_dir}", mode: 'copy'

    input:
        path transcriptome_fasta_path
        val index_output_dir
        val index_basename
        val create_index

    output:
        path index_basename, emit: transcriptome_index_ch

    script:
        """
        echo "Generating Kallisto index"
        kallisto index -i ${index_basename} ${transcriptome_fasta_path}
        """

    stub:
        """
        echo "Stubbing Kallisto index generation."
        mkdir -p stub/index
        touch ${index_basename}
        """
}

workflow transcriptome_indexing_wf {
    take:
        transcriptome_fasta_path
        index_output_dir
        index_basename
        create_index

    main:
        transcriptome_indexing_app (
            transcriptome_fasta_path,
            index_output_dir,
            index_basename,
            create_index
        )

    emit:
        transcriptome_index_ch = transcriptome_indexing_app.out.transcriptome_index_ch
}

// Testing Workflow to be used with module test_input.json
workflow {
    transcriptome_indexing_wf(
        transcriptome_fasta_path = Channel.fromPath(params.transcriptome_fasta_path, type: "file"),
        index_output_dir = params.index_output_dir,
        index_basename = params.index_basename,
        create_index = params.create_index
    )
}