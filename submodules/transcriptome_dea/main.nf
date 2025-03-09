nextflow.enable.dsl=2

process transcriptome_dea_app {
    tag "Differential Expression Analysis (${mode})"

    publishDir "${params.results_dir}/differential_expression_analysis/transcriptome_dea/${mode}", mode: 'copy'

    input:
        val mode
        val prefix
        path kallisto_abundance_h5s

    output:
        path "${prefix}_sleuth_metadata.tsv", emit: sleuth_metadata_ch
        path "${prefix}_sleuth_lrt_results.tsv", emit: sleuth_lrt_results_ch
        path "${prefix}_sleuth_wald_results.tsv", emit: sleuth_wald_results_ch
        path "${prefix}_pca_plot.png", emit: sleuth_pca_plot_ch
        path "${prefix}_heatmap_plot.png", emit: sleuth_heatmap_plot_ch
        path "${prefix}_transcript_heatmap_plot.png", emit: sleuth_transcript_heatmap_plot_ch
        path "${prefix}_bootstrap_plot.png", emit: sleuth_bootstrap_plot_ch

    script:
        """
        echo "Running Sleuth analysis for ${mode}"
        /scripts/run_sleuth_analysis.sh ${kallisto_abundance_h5s} ${prefix}
        """

    stub:
        """
        echo "Stubbing Differential Expression Analysis"
        mkdir -p transcriptome_dea
        touch se_sleuth_metadata.tsv
        touch se_sleuth_lrt_results.tsv
        touch se_sleuth_wald_results.tsv
        touch se_pca_plot.png
        touch se_heatmap_plot.png
        touch se_transcript_heatmap_plot.png
        touch se_bootstrap_plot.png
        """
}

workflow transcriptome_dea_se_wf {
    take:
        se_abundance_h5

    main:
        transcriptome_dea_app(
            mode = "single_end",
            prefix = "se",
            kallisto_abundance_h5s = se_abundance_h5
        )

    emit:
        sleuth_metadata_ch = transcriptome_dea_app.out.sleuth_metadata_ch
        sleuth_lrt_results_ch = transcriptome_dea_app.out.sleuth_lrt_results_ch
        sleuth_wald_results_ch = transcriptome_dea_app.out.sleuth_wald_results_ch
        sleuth_pca_plot_ch = transcriptome_dea_app.out.sleuth_pca_plot_ch
        sleuth_heatmap_plot_ch = transcriptome_dea_app.out.sleuth_heatmap_plot_ch
        sleuth_transcript_heatmap_plot_ch = transcriptome_dea_app.out.sleuth_transcript_heatmap_plot_ch
        sleuth_bootstrap_plot_ch = transcriptome_dea_app.out.sleuth_bootstrap_plot_ch
}

workflow transcriptome_dea_pe_wf {
    take:
        pe_abundance_h5

    main:
        transcriptome_dea_app(
            mode = "paired_end",
            prefix = "pe",
            kallisto_abundance_h5s = pe_abundance_h5
        )

    emit:
        sleuth_metadata_ch = transcriptome_dea_app.out.sleuth_metadata_ch
        sleuth_lrt_results_ch = transcriptome_dea_app.out.sleuth_lrt_results_ch
        sleuth_wald_results_ch = transcriptome_dea_app.out.sleuth_wald_results_ch
        sleuth_pca_plot_ch = transcriptome_dea_app.out.sleuth_pca_plot_ch
        sleuth_heatmap_plot_ch = transcriptome_dea_app.out.sleuth_heatmap_plot_ch
        sleuth_transcript_heatmap_plot_ch = transcriptome_dea_app.out.sleuth_transcript_heatmap_plot_ch
        sleuth_bootstrap_plot_ch = transcriptome_dea_app.out.sleuth_bootstrap_plot_ch
}

// Testing Workflow to be used with module test_input.json
workflow {
    def se_abundance_h5s = Channel.fromPath(params.se_abundance_h5s).toList()

    // Kallisto transcript counts for single-ends and paired-ends
    transcriptome_dea_se_wf(
        se_abundance_h5 = se_abundance_h5s
    )
}