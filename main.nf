#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {
    transcriptome_analysis_wf
} from './subworkflows/transcriptome_analysis/main.nf'

include {
    differential_expression_analysis_wf
} from './subworkflows/differential_expression_analysis/main.nf'

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

    // Collect all abundace h5 files from Transcriptome Analysis
    transcriptome_analysis_wf.out.se_abundance_h5s
        .collect()
        .set { se_abundance_h5s }

    transcriptome_analysis_wf.out.pe_abundance_h5s
        .collect()
        .set { pe_abundance_h5s }

    // Call differential expression analysis
    // 1. Performs DEA in Sleuth using an R script
    // 2. Creates some useful DEA plots
    differential_expression_analysis_wf(
        se_abundance_h5s = se_abundance_h5s,
        pe_abundance_h5s = pe_abundance_h5s
    )
}