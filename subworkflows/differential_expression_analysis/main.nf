nextflow.enable.dsl=2

include {
    transcriptome_dea_se_wf
} from '../../submodules/transcriptome_dea/main.nf'

include {
    transcriptome_dea_pe_wf
} from '../../submodules/transcriptome_dea/main.nf'


workflow differential_expression_analysis_wf {

    take:
        se_abundance_h5s
        pe_abundance_h5s

    main:
        transcriptome_dea_se_wf (
            se_abundance_h5 = se_abundance_h5s
        )
        transcriptome_dea_pe_wf (
            pe_abundance_h5 = pe_abundance_h5s
        )

    emit:
        // DEA results for Single-end
        se_sleuth_metadata_ch = transcriptome_dea_se_wf.out.sleuth_metadata_ch
        se_sleuth_lrt_results_ch = transcriptome_dea_se_wf.out.sleuth_lrt_results_ch
        se_sleuth_wald_results_ch = transcriptome_dea_se_wf.out.sleuth_wald_results_ch
        se_sleuth_pca_plot_ch = transcriptome_dea_se_wf.out.sleuth_pca_plot_ch
        se_sleuth_heatmap_plot_ch = transcriptome_dea_se_wf.out.sleuth_heatmap_plot_ch
        se_sleuth_transcript_heatmap_plot_ch = transcriptome_dea_se_wf.out.sleuth_transcript_heatmap_plot_ch
        se_sleuth_bootstrap_plot_ch = transcriptome_dea_se_wf.out.sleuth_bootstrap_plot_ch
        // DEA results for Paired-end
        pe_sleuth_metadata_ch = transcriptome_dea_pe_wf.out.sleuth_metadata_ch
        pe_sleuth_lrt_results_ch = transcriptome_dea_pe_wf.out.sleuth_lrt_results_ch
        pe_sleuth_wald_results_ch = transcriptome_dea_pe_wf.out.sleuth_wald_results_ch
        pe_sleuth_pca_plot_ch = transcriptome_dea_pe_wf.out.sleuth_pca_plot_ch
        pe_sleuth_heatmap_plot_ch = transcriptome_dea_pe_wf.out.sleuth_heatmap_plot_ch
        pe_sleuth_transcript_heatmap_plot_ch = transcriptome_dea_pe_wf.out.sleuth_transcript_heatmap_plot_ch
        pe_sleuth_bootstrap_plot_ch = transcriptome_dea_pe_wf.out.sleuth_bootstrap_plot_ch
}