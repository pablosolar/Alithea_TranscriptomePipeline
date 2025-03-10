nextflow.enable.dsl=2

include {
    transcriptome_indexing_wf
} from '../../submodules/transcriptome_indexing/main.nf'

include {
     transcriptome_quantification_se_wf
} from '../../submodules/transcriptome_quantification/main.nf'

include {
     transcriptome_quantification_pe_wf
} from '../../submodules/transcriptome_quantification/main.nf'

include {
     transcriptome_counts_wf
} from '../../submodules/transcriptome_counts/main.nf'

workflow transcriptome_analysis_wf {

    take:
        transcriptome_fasta_path
        index_output_dir
        index_basename
        create_index
        demultiplexed_fastqs
        single_end
        paired_end

    main:
        // STEP 1: Generate index OR use existing one
        transcriptome_indexing_wf(
            transcriptome_fasta_path = transcriptome_fasta_path,
            index_output_dir = index_output_dir,
            index_basename = index_basename,
            create_index = create_index
        )

        transcriptome_index_ch = transcriptome_indexing_wf.out.transcriptome_index_ch.ifEmpty {
            def index_file = file("${index_output_dir}/${index_basename}")
            if (!index_file.exists()) {
                log.error "No Index file found in the path: ${index_output_dir}/${index_basename}"
                System.exit(1)
            }
        }

        // STEP 2: Load FASTQ files from the specified path
        fastq_files_ch = Channel.fromPath(demultiplexed_fastqs, type: "file") .ifEmpty {
            error "ERROR ~ No FASTQ files found in the provided path: ${demultiplexed_fastqs}"
        }

        // STEP 3: Samples Quantification
        // Create single-end samples vector (R2 files only) if required by parameter
        fastq_files_ch
            .filter { single_end && it.name.endsWith("_R2.fastq.gz") }
            .map { file -> tuple(file.name.replaceAll(/_R2\.fastq\.gz$/, ""), file) }
            .combine(transcriptome_index_ch)
            .set { se_sample_input_ch }

        // Create paired-end samples vector (R1 + R2 files)  if required by parameter
        fastq_files_ch
            .map { file -> tuple(file.name.replaceAll(/_R[12]\.fastq\.gz$/, ""), file) }
            .groupTuple()
            .filter { paired_end && it[1].size() == 2 }
            .map { sample_id, fastq_files -> tuple(sample_id, fastq_files.sort { a, b -> a.name <=> b.name }) }
            .combine(transcriptome_index_ch)
            .set { pe_sample_input_ch }

        // Call the workflows (Nextflow will handle empty channels gracefully)
        transcriptome_quantification_se_wf(
            sample_input = se_sample_input_ch
        )
        transcriptome_quantification_pe_wf(
            sample_input = pe_sample_input_ch
        )

        // Collect SE and PE results before calling counts
        transcriptome_quantification_se_wf.out.kallisto_quant_abundance_tsv_ch.toList()
            .set { se_abundance_tsvs_ch }
        transcriptome_quantification_pe_wf.out.kallisto_quant_abundance_tsv_ch.toList()
            .set { pe_abundance_tsvs_ch }

        // STEP 4: Extract counts and plot a boxplot
        // Extracted counts TSV will store info for the enabled modes
        // Boxplot will be generated only if both modes are enabled
        transcriptome_counts_wf(
            se_abundance_tsvs = se_abundance_tsvs_ch,
            pe_abundance_tsvs = pe_abundance_tsvs_ch
        )

        emit:
            transcriptome_index_ch = transcriptome_index_ch
            se_abundance_h5s_ch = transcriptome_quantification_se_wf.out.kallisto_quant_abundance_h5_ch
            pe_abundance_h5s_ch = transcriptome_quantification_pe_wf.out.kallisto_quant_abundance_h5_ch
            transcriptome_counts_tsv_ch = transcriptome_counts_wf.out.transcriptome_counts_tsv_ch
            transcriptome_counts_boxplot_ch = transcriptome_counts_wf.out.transcriptome_counts_boxplot_ch
}

// Testing Workflow to be used with subworkflow test_input.json
workflow {
    transcriptome_analysis_wf (
        transcriptome_fasta_path = file(params.transcriptome_fasta_path),
        index_output_dir = file(params.index_output_dir),
        index_basename = params.index_basename,
        create_index = params.create_index,
        demultiplexed_fastqs = params.demultiplexed_fastqs,
        single_end = params.single_end,
        paired_end = params.paired_end
    )
}