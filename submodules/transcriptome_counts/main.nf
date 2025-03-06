nextflow.enable.dsl=2

process transcriptome_counts_app {
    tag "Transcript Counts Extraction - abundance.tsv"

    publishDir "${params.results_dir}/transcriptome_counts", mode: 'copy'

    input:
        path se_abundance_tsvs
        path pe_abundance_tsvs

    output:
        path "se_vs_pe_transcript_counts.tsv", emit: transcript_counts
        path "se_vs_pe_boxplot.png", emit: boxplot, optional: true

    script:
        """
        echo "Extracting transcript counts from Kallisto quantification results"
        mkdir -p transcriptome_counts
        # Run transcript counting script
        python3 /bin/extract_transcript_counts.py --se ${se_abundance_tsvs} --pe ${pe_abundance_tsvs}

        # Generate boxplot only if both SE & PE lists are non-empty
        if [[ -n "$se_abundance_tsvs" && -n "$pe_abundance_tsvs" ]]; then
            python3 /bin/generate_boxplot.py --counts "se_vs_pe_transcript_counts.tsv"
        else
            echo "Skipping boxplot generation: One of the datasets is missing."
        fi
        """

    stub:
        """
        echo "Stubbing transcript counts"
        mkdir -p transcriptome_counts
        touch se_vs_pe_transcript_counts.tsv
        """
}

workflow transcriptome_counts_wf {
    take:
        se_abundance_tsvs
        pe_abundance_tsvs

    main:
        transcriptome_counts_app(
            se_abundance_tsvs = se_abundance_tsvs,
            pe_abundance_tsvs = pe_abundance_tsvs
        )

    emit:
        transcript_counts = transcriptome_counts_app.out.transcript_counts
        boxplot = transcriptome_counts_app.out.boxplot
}

workflow {
    def se_abundance_tsvs = Channel.fromPath(params.se_abundance_tsvs).toList()
    def pe_abundance_tsvs = Channel.fromPath(params.pe_abundance_tsvs).toList()

    // Kallisto transcript counts for single-ends and paired-ends
    transcriptome_counts_wf(
        se_abundance_tsvs = se_abundance_tsvs,
        pe_abundance_tsvs = pe_abundance_tsvs
    )
}