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

// Testing Workflow to be used with module test_input.json
workflow {
    // General Inputs
    def index_info = params.index_info ? Channel.fromPath(params.index_info).toList() : []
    def transcriptome_counts = params.transcriptome_counts ? Channel.fromPath(params.transcriptome_counts).toList() : []
    def transcriptome_boxplot = params.transcriptome_boxplot ? Channel.fromPath(params.transcriptome_boxplot).toList() : []

    // SE Inputs
    def se_sleuth_metadata_file = params.se_sleuth_metadata_file ? Channel.fromPath(params.se_sleuth_metadata_file).toList() : []
    def se_sleuth_lrt_results = params.se_sleuth_lrt_results ? Channel.fromPath(params.se_sleuth_lrt_results).toList() : []
    def se_sleuth_wald_results = params.se_sleuth_wald_results ? Channel.fromPath(params.se_sleuth_wald_results).toList() : []
    def se_sleuth_pca_plot = params.se_sleuth_pca_plot ? Channel.fromPath(params.se_sleuth_pca_plot).toList() : []
    def se_sleuth_heatmap_plot = params.se_sleuth_heatmap_plot ? Channel.fromPath(params.se_sleuth_heatmap_plot).toList() : []
    def se_sleuth_transcript_heatmap_plot = params.se_sleuth_transcript_heatmap_plot ? Channel.fromPath(params.se_sleuth_transcript_heatmap_plot).toList() : []
    def se_sleuth_bootstrap_plot = params.se_sleuth_bootstrap_plot ? Channel.fromPath(params.se_sleuth_bootstrap_plot).toList() : []

    // PE Inputs
    def pe_sleuth_metadata_file = params.pe_sleuth_metadata_file ? Channel.fromPath(params.pe_sleuth_metadata_file).toList() : []
    def pe_sleuth_lrt_results = params.pe_sleuth_lrt_results ? Channel.fromPath(params.pe_sleuth_lrt_results).toList() : []
    def pe_sleuth_wald_results = params.pe_sleuth_wald_results ? Channel.fromPath(params.pe_sleuth_wald_results).toList() : []
    def pe_sleuth_pca_plot = params.pe_sleuth_pca_plot ? Channel.fromPath(params.pe_sleuth_pca_plot).toList() : []
    def pe_sleuth_heatmap_plot = params.pe_sleuth_heatmap_plot ? Channel.fromPath(params.pe_sleuth_heatmap_plot).toList() : []
    def pe_sleuth_transcript_heatmap_plot = params.pe_sleuth_transcript_heatmap_plot ? Channel.fromPath(params.pe_sleuth_transcript_heatmap_plot).toList() : []
    def pe_sleuth_bootstrap_plot = params.pe_sleuth_bootstrap_plot ? Channel.fromPath(params.pe_sleuth_bootstrap_plot).toList() : []

    // Run the report engine workflow
    report_generation_wf(
        index_info = index_info,
        transcriptome_counts = transcriptome_counts,
        transcriptome_boxplot = transcriptome_boxplot,

        // SE Inputs
        se_sleuth_metadata_file = se_sleuth_metadata_file,
        se_sleuth_lrt_results = se_sleuth_lrt_results,
        se_sleuth_wald_results = se_sleuth_wald_results,
        se_sleuth_pca_plot = se_sleuth_pca_plot,
        se_sleuth_heatmap_plot = se_sleuth_heatmap_plot,
        se_sleuth_transcript_heatmap_plot = se_sleuth_transcript_heatmap_plot,
        se_sleuth_bootstrap_plot = se_sleuth_bootstrap_plot,

        // PE Inputs
        pe_sleuth_metadata_file = pe_sleuth_metadata_file,
        pe_sleuth_lrt_results = pe_sleuth_lrt_results,
        pe_sleuth_wald_results = pe_sleuth_wald_results,
        pe_sleuth_pca_plot = pe_sleuth_pca_plot,
        pe_sleuth_heatmap_plot = pe_sleuth_heatmap_plot,
        pe_sleuth_transcript_heatmap_plot = pe_sleuth_transcript_heatmap_plot,
        pe_sleuth_bootstrap_plot = pe_sleuth_bootstrap_plot
    )
}