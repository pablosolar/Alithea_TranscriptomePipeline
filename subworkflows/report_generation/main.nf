nextflow.enable.dsl=2

include {
    report_engine_wf
} from '../../submodules/report_engine/main.nf'


workflow report_generation_wf {

    take:
        index_info
        transcriptome_counts
        transcriptome_boxplot
        se_sleuth_metadata_file
        se_sleuth_lrt_results
        se_sleuth_wald_results
        se_sleuth_pca_plot
        se_sleuth_heatmap_plot
        se_sleuth_transcript_heatmap_plot
        se_sleuth_bootstrap_plot
        pe_sleuth_metadata_file
        pe_sleuth_lrt_results
        pe_sleuth_wald_results
        pe_sleuth_pca_plot
        pe_sleuth_heatmap_plot
        pe_sleuth_transcript_heatmap_plot
        pe_sleuth_bootstrap_plot


    main:
        report_engine_wf (
            index_info = index_info,
            transcriptome_counts = transcriptome_counts,
            transcriptome_boxplot = transcriptome_boxplot,
            // Inputs for Single-end
            se_sleuth_metadata_file = se_sleuth_metadata_file,
            se_sleuth_lrt_results = se_sleuth_lrt_results,
            se_sleuth_wald_results = se_sleuth_wald_results,
            se_sleuth_pca_plot = se_sleuth_pca_plot,
            se_sleuth_heatmap_plot = se_sleuth_heatmap_plot,
            se_sleuth_transcript_heatmap_plot = se_sleuth_transcript_heatmap_plot,
            se_sleuth_bootstrap_plot = se_sleuth_bootstrap_plot,
            // Inputs for Paired-end
            pe_sleuth_metadata_file = pe_sleuth_metadata_file,
            pe_sleuth_lrt_results = pe_sleuth_lrt_results,
            pe_sleuth_wald_results = pe_sleuth_wald_results,
            pe_sleuth_pca_plot = pe_sleuth_pca_plot,
            pe_sleuth_heatmap_plot = pe_sleuth_heatmap_plot,
            pe_sleuth_transcript_heatmap_plot = pe_sleuth_transcript_heatmap_plot,
            pe_sleuth_bootstrap_plot = pe_sleuth_bootstrap_plot
        )
}