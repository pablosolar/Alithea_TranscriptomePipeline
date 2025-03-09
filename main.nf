#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {
    transcriptome_analysis_wf
} from './subworkflows/transcriptome_analysis/main.nf'

include {
    differential_expression_analysis_wf
} from './subworkflows/differential_expression_analysis/main.nf'

include {
    report_generation_wf
} from './subworkflows/report_generation/main.nf'

workflow {

    // Call transcriptome analysis
    // 1. Creates index (if needed)
    // 2. Performs transcriptome quantification using Kallisto
    // 3. Extracts transcriptome counts and plots a box plot (if needed)
    transcriptome_analysis_wf (
        transcriptome_fasta_path = file(params.transcriptome_fasta_path),
        index_output_dir = file(params.index_output_dir),
        index_basename = params.index_basename,
        create_index = params.create_index,
        demultiplexed_fastqs = params.demultiplexed_fastqs,
        single_end = params.single_end,
        paired_end = params.paired_end
    )

    // Call differential expression analysis
    // 1. Performs DEA in Sleuth using an R script
    // 2. Creates some useful DEA plots
    // 3. Handles Single-end & Paired-end analysis (if required)
    differential_expression_analysis_wf(
        se_abundance_h5s = transcriptome_analysis_wf.out.se_abundance_h5s_ch .toList(),
        pe_abundance_h5s = transcriptome_analysis_wf.out.pe_abundance_h5s_ch .toList()
    )

    // Call report report_generation
    // 1. Generates HTML report using Python & Jinja Template
    // 2. Dynamically handles Single-end & Paired-end sections

    report_generation_wf(
        index_info = transcriptome_analysis_wf.out.transcriptome_index_ch.ifEmpty{[]},
        transcriptome_counts = transcriptome_analysis_wf.out.transcriptome_counts_tsv_ch.ifEmpty{[]},
        transcriptome_boxplot = transcriptome_analysis_wf.out.transcriptome_counts_boxplot_ch.ifEmpty{[]},
        // Single-end
        se_sleuth_metadata = differential_expression_analysis_wf.out.se_sleuth_metadata_ch.ifEmpty{[]},
        se_sleuth_lrt_result = differential_expression_analysis_wf.out.se_sleuth_lrt_results_ch.ifEmpty{[]},
        se_sleuth_wald_results = differential_expression_analysis_wf.out.se_sleuth_wald_results_ch.ifEmpty{[]},
        se_sleuth_pca_plot = differential_expression_analysis_wf.out.se_sleuth_pca_plot_ch.ifEmpty{[]},
        se_sleuth_heatmap_plot = differential_expression_analysis_wf.out.se_sleuth_heatmap_plot_ch.ifEmpty{[]},
        se_sleuth_transcript_heatmap_plot = differential_expression_analysis_wf.out.se_sleuth_transcript_heatmap_plot_ch.ifEmpty{[]},
        se_sleuth_bootstrap_plot = differential_expression_analysis_wf.out.se_sleuth_bootstrap_plot_ch.ifEmpty{[]},
        // Paired-end
        pe_sleuth_metadata = differential_expression_analysis_wf.out.pe_sleuth_metadata_ch.ifEmpty{[]},
        pe_sleuth_lrt_results = differential_expression_analysis_wf.out.pe_sleuth_lrt_results_ch.ifEmpty{[]},
        pe_sleuth_wald_results = differential_expression_analysis_wf.out.pe_sleuth_wald_results_ch.ifEmpty{[]},
        pe_sleuth_pca_plot = differential_expression_analysis_wf.out.pe_sleuth_pca_plot_ch.ifEmpty{[]},
        pe_sleuth_heatmap_plot = differential_expression_analysis_wf.out.pe_sleuth_heatmap_plot_ch.ifEmpty{[]},
        pe_sleuth_transcript_heatmap_plot = differential_expression_analysis_wf.out.pe_sleuth_transcript_heatmap_plot_ch.ifEmpty{[]},
        pe_sleuth_bootstrap_plot = differential_expression_analysis_wf.out.pe_sleuth_bootstrap_plot_ch.ifEmpty{[]}
    )
}