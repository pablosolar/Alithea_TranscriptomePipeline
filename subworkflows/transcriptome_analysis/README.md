# Transcriptome Analysis Subworkflow

## Overview
The `transcriptome_analysis_wf` subworkflow orchestrates the complete transcriptome analysis pipeline. It takes as input raw sequencing reads in FASTQ format, processes them through multiple steps, and outputs quantification results, including transcript abundance tables and a summary count matrix.

This subworkflow ensures that **transcriptome quantification** is performed efficiently by handling both **Single-End (SE) and Paired-End (PE) sequencing data**, using an indexed reference transcriptome.

## Why This Subworkflow Exists
This subworkflow automates the key steps required for transcript-level quantification, integrating:
- **Transcriptome Indexing** (if not provided)
- **Sample Quantification** using Kallisto for both SE and PE reads
- **Transcriptome Counts Extraction** for downstream analysis

By bundling these related tasks together, this subworkflow ensures consistency and efficiency while simplifying execution.

## How It Works
The subworkflow follows these major steps:

1. **Index Generation (Optional):**
   - If `create_index` is `true`, generates an index from the provided transcriptome FASTA file.
   - Otherwise, uses a precomputed index.

2. **FASTQ File Loading:**
   - Loads FASTQ files based on the given input path (`demultiplexed_fastqs`).
   - Identifies Single-End (SE) and Paired-End (PE) samples based on filename patterns.

3. **Transcript Quantification:**
   - Runs `transcriptome_quantification_se_wf` for SE reads.
   - Runs `transcriptome_quantification_pe_wf` for PE reads.

4. **Transcript Counts Extraction:**
   - Once quantification is complete, calls `transcriptome_counts_wf` to extract count matrices.

5. **Outputs Final Results:**
   - Indexed transcriptome reference (if generated)
   - Kallisto abundance results (`.h5` files for SE and PE)
   - Combined transcript count matrices (`.tsv` files)
   - A visualization boxplot comparing SE vs PE transcript detection

## Submodules Used
This subworkflow calls the following **containerized** submodules:

- **Transcriptome Indexing:** [`transcriptome_indexing_wf`](../../submodules/transcriptome_indexing/README.md)
- **Single-End Quantification:** [`transcriptome_quantification_se_wf`](../../submodules/transcriptome_quantification/README.md)
- **Paired-End Quantification:** [`transcriptome_quantification_pe_wf`](../../submodules/transcriptome_quantification/README.md)
- **Transcriptome Counts Extraction:** [`transcriptome_counts_wf`](../../submodules/transcriptome_counts/README.md)

Each of these submodules is containerized, ensuring reproducibility and compatibility across different environments. Refer to their respective README files for details on their implementations.

## Input Parameters
| Parameter              | Description                                                                                                               | Example Value               |
|------------------------|---------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `create_index`        | Whether to generate a new transcriptome index or not. If not, it takes the index from `index_output_dir`/`index_basename` | `true`                      |
| `transcriptome_fasta_path` | Path to input transcriptome FASTA file                                                                                    | `/path/to/genome.fa.gz`     |
| `index_output_dir`    | Directory to store/fetch the transcriptome index                                                                          | `/path/to/index`            |
| `index_basename`      | Filename for the generated transcriptome index                                                                            | `genome.idx`                |
| `demultiplexed_fastqs` | Path to demultiplexed FASTQ files                                                                                         | `/path/to/fastq/*.fastq.gz` |
| `single_end`          | Process SE reads (`true`/`false`)                                                                                         | `false`                     |
| `paired_end`          | Process PE reads (`true`/`false`)                                                                                         | `true`                      |
| `results_dir`         | Directory for storing results (will create `transcriptome_analysis` subfolder)                                            | `/path/to/results`          |

## How to Run
Run the subworkflow using Nextflow and Docker:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

This will execute the subworkflow using the parameters defined in `test_input.json`. Example

```json
{
    "create_index": true,
    "transcriptome_fasta_path": "/path/to/reference/Homo_sapiens.GRCh38.cdna.all.fa.gz",
    "index_output_dir": "/path/to/index",
    "index_basename": "Homo_sapiens.GRCh38.cdna.all.idx",
    "demultiplexed_fastqs": "/path/to/demultiplexed/*.fastq.gz",
    "single_end": false,
    "paired_end": true,
    "results_dir": "/path/to/results"
}
```


## Expected Outputs
| Output                          | Description                                      |
|----------------------------------|--------------------------------------------------|
| `transcriptome_index_ch`        | Indexed transcriptome reference (if created)    |
| `se_abundance_h5s_ch`           | Kallisto `.h5` abundance files for SE samples   |
| `pe_abundance_h5s_ch`           | Kallisto `.h5` abundance files for PE samples   |
| `transcriptome_counts_tsv_ch`   | Extracted transcript count matrix (TSV format)  |
| `transcriptome_counts_boxplot_ch` | Boxplot comparing SE vs PE transcript detection |

## Decisions Taken
- The pipeline dynamically detects whether an index needs to be generated or can be reused.
- FASTQ files are filtered based on `_R2.fastq.gz` (SE) and `_R1.fastq.gz + _R2.fastq.gz` (PE) naming conventions.
- The workflow **only calls quantification workflows when necessary** to prevent unnecessary computation.
- The final transcript count extraction module (`transcriptome_counts_wf`) is only executed **after quantification is completed** to ensure that all abundance files are ready.
