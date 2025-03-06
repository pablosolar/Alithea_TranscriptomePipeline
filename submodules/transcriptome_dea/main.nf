nextflow.enable.dsl=2

process transcriptome_dea_app {
    tag "Differential Expression Analysis (${mode})"

    publishDir "${params.results_dir}/transcriptome_dea/${mode}", mode: 'copy'

    input:
        val mode
        path kallisto_abundance_h5s

    output:
        path "sleuth_metadata.tsv", emit: sleuth_metadata_ch
        path "sleuth_lrt_results.tsv", emit: sleuth_lrt_results_ch
        path "sleuth_wald_results.tsv", emit: sleuth_wald_results_ch
        path "pca_plot.png", emit: pca_plot_ch
        path "heatmap_plot.png", emit: heatmap_plot_ch
        path "transcript_heatmap_plot.png", emit: density_plot_ch
        path "bootstrap_plot.png", emit: transcript_heatmap_plot_ch

    script:
        """
        echo "Running Sleuth analysis"
        /scripts/run_sleuth_analysis.sh ${kallisto_abundance_h5s}
        """

    stub:
        """
        echo "Stubbing Differential Expression Analysis"
        mkdir -p transcriptome_dea
        touch sleuth_metadata.tsv
        touch pca_plot.png
        touch heatmap_plot.png
        touch transcript_heatmap_plot.png
        touch bootstrap_plot.png
        """
}

workflow transcriptome_dea_se_wf {
    take:
        se_abundance_h5

    main:
        transcriptome_dea_app(
            mode = "single_end",
            kallisto_abundance_h5s = se_abundance_h5
        )

    emit:
        sleuth_metadata_ch = transcriptome_dea_app.out.sleuth_metadata_ch
        sleuth_lrt_results_ch = transcriptome_dea_app.out.sleuth_lrt_results_ch
        sleuth_wald_results_ch = transcriptome_dea_app.out.sleuth_wald_results_ch
}

workflow transcriptome_dea_pe_wf {
    take:
        pe_abundance_h5

    main:
        transcriptome_dea_app(
            mode = "paired_end",
            kallisto_abundance_h5s = pe_abundance_h5
        )

    emit:
        sleuth_metadata_ch = transcriptome_dea_app.out.sleuth_metadata_ch
        sleuth_lrt_results_ch = transcriptome_dea_app.out.sleuth_lrt_results_ch
        sleuth_wald_results_ch = transcriptome_dea_app.out.sleuth_wald_results_ch
}

workflow {
    def se_abundance_h5s = Channel.fromPath(params.se_abundance_h5s).toList()

    // Kallisto transcript counts for single-ends and paired-ends
    transcriptome_dea_se_wf(
        se_abundance_h5 = se_abundance_h5s
    )
}