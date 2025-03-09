# Alithea Transcriptome Pipeline

## Overview
I developed the **Alithea Transcriptome Pipeline** as a fully automated Nextflow workflow for **transcript quantification** using **Kallisto** and **differential expression analysis (DEA)** with **Sleuth**. The pipeline is designed to handle **both Single-End (SE) and Paired-End (PE) reads**, producing **transcript abundance tables, DEA results, and visual reports**.

I structured this pipeline to be **modular, scalable, and fully reproducible**, ensuring it can be used for both **research and production environments**. Every component was designed to be **independently testable**, so submodules and subworkflows can be validated separately while integrating seamlessly.

## Enhancements Beyond the Original Task
While implementing this pipeline, I took steps to **go beyond** the original requirements to ensure **best practices, flexibility, and maintainability**.

- **Modular and Scalable Design:**  
  - The pipeline is structured into **subworkflows and submodules**, allowing each step to be executed **independently** or as part of the full workflow.
  - This ensures better debugging, scalability, and the ability to reuse components in different contexts.

- **Containerization for Reproducibility:**  
  - Each module runs inside **Docker**, guaranteeing a consistent execution environment.
  - This helps avoid system dependency issues and makes the pipeline **portable across different infrastructures**.

- **Independent Testing & Stub Mode:**  
  - I included **test_input.json** files for each module, allowing **isolated testing** before integrating them.
  - Stub mode was implemented to **simulate execution with minimal resources**, making it easier to validate individual steps.

- **Nextflow Best Practices Implemented:**  
  - I separated `main.nf`, `nextflow.config`, **subworkflows**, and **submodules** to keep the pipeline organized.
  - Efficient **channel-based communication** ensures a **scalable and optimized workflow**.
  - Parameters allow skipping index generation, **making execution more flexible**.

- **Comprehensive Documentation:**  
  - I wrote **clear and structured READMEs** for the entire pipeline, subworkflows and each module.
  - Documentation covers **expected outputs, execution steps, and test procedures**.

- **Bonus Features Implemented:**  
  - I added **report generation with visualizations**, which was an optional bonus task.
  - The **output structure is well-organized**, making it easy to interpret results.

This approach ensures **reproducibility, maintainability, and scalability**, making the pipeline **ready for real-world use**.

## Key Features
- **Automated transcript quantification** using **Kallisto**.
- **Differential Expression Analysis (DEA)** using **Sleuth**.
- **Support for both Single-End (SE) and Paired-End (PE) RNA-seq analysis**.
- **Fully modular Nextflow design**, allowing independent execution of components.
- **JSON-driven execution**, enabling flexible configuration.
- **Containerized execution** for reproducibility and portability.
- **Independent testing framework** for validation and debugging.
- **Scalable architecture**, suitable for large datasets and potential CI/CD workflows.

---

## Pipeline Structure
I designed the pipeline with a **structured modular approach**, ensuring **reproducibility, scalability, and ease of debugging**. It consists of **subworkflows** that orchestrate multiple **submodules**, each handling a specific task.

```
/Alithea_TranscriptomePipeline/
├── main.nf                             # Main Nextflow script
├── nextflow.config                     # Configuration file
├── test_input.json                     # General test input for the entire pipeline
├── README.md                           # Pipeline documentation
├── LICENSE                             # License file
├── .gitignore                          # Git ignore file
├── submodules/                         # Core computational submodules
│   ├── transcriptome_indexing/  
│   ├── transcriptome_quantification/
│   ├── transcriptome_counts/
│   ├── transcriptome_dea/
│   ├── report_engine/                  # Report generation
├── subworkflows/                       # Subworkflows orchestrating submodules
│   ├── transcriptome_analysis/
│   ├── differential_expression_analysis/
│   ├── report_generation/
```

## Subworkflows & Modules
The pipeline consists of multiple **subworkflows**, each calling **submodules** responsible for specific computational tasks:

### **Subworkflows**
| Subworkflow | Description |
|------------|-------------|
| **transcriptome_analysis_wf** | Performs transcriptome quantification by indexing a reference transcriptome (if needed) and running Kallisto for SE and PE reads. |
| **differential_expression_analysis_wf** | Conducts DEA using Sleuth, taking transcript abundance files from SE and PE quantification steps. |
| **report_generation_wf** | Generates a final HTML report summarizing transcript quantification and DEA results. |

```
/subworkflows/
├── subworkflow_name/
│   ├── main.nf             # Module Nextflow script
│   ├── nextflow.config     # Module configuration file
│   ├── README.md           # Module README
│   ├── test_input.json     # Module test input
```

### **Submodules**
| Submodule | Description                                                          | Docker Image used |
|-----------|----------------------------------------------------------------------|-------------------|
| **transcriptome_indexing_wf** | Generates or loads a transcriptome index for Kallisto.               | `pablosolar/kallisto_tool:v0.51.0` |
| **transcriptome_quantification_se_wf** | Runs Kallisto for SE reads.                                         | `pablosolar/kallisto_tool:v0.51.0` |
| **transcriptome_quantification_pe_wf** | Runs Kallisto for PE reads.                                          | `pablosolar/kallisto_tool:v0.51.0` |
| **transcriptome_counts_wf** | Extracts transcript abundance counts and generates a summary boxplot. | `pablosolar/kallisto_counts_boxplot:v1.0.0` |
| **transcriptome_dea_se_wf** | Runs DEA using Sleuth for SE reads.                                  | `pablosolar/sleuth_dea:v2.0.0` |
| **transcriptome_dea_pe_wf** | Runs DEA using Sleuth for PE reads.                                  | `pablosolar/sleuth_dea:v2.0.0` |
| **report_engine_wf** | Generates the final report, including tables and visualizations.     | `pablosolar/transcriptome_report_engine:v1.0.0` |

```
/submodules/
├── module_name/
│   ├── docker/                     # Docker image (Dockerfile, scripts & resources)
│   │   ├── bin/                    
│   │   ├── Dockerfile              
│   ├── stub/                       # Stubbing folder (stub test input JSON and input/out folders)
│   │   ├── stub_test_input.json    
│   │   ├── other_folders           
│   ├── main.nf                     # Submodule Nextflow script
│   ├── md5sum.txt                  # Submodule Checksum file
│   ├── nextflow.config             # Submodule configuration file
│   ├── README.md                   # Submodule README
│   ├── test_input.json             # Submodule test input
```

Each module is **containerized** to ensure reproducibility and ease of deployment.

---


## Input Parameters
| Parameter | Description                                                                                                          | Example Value |
|-----------|----------------------------------------------------------------------------------------------------------------------|---------------|
| `create_index` | Whether to generate a new transcriptome index (`true`) or retrieve from `ìndex_output_dir/index_basename` (`false`). | `true` |
| `transcriptome_fasta_path` | Path to the input transcriptome FASTA file.                                                                          | `/path/to/genome.fa.gz` |
| `index_output_dir` | Directory to store the transcriptome index.                                                                          | `/path/to/index` |
| `index_basename` | Filename for the transcriptome index.                                                                                | `genome.idx` |
| `demultiplexed_fastqs` | Path to the demultiplexed FASTQ files.                                                                               | `/path/to/fastq/*.fastq.gz` |
| `single_end` | Process SE reads (`true`/`false`).                                                                                   | `false` |
| `paired_end` | Process PE reads (`true`/`false`).                                                                                   | `true` |
| `results_dir` | Directory for storing results.                                                                                       | `/path/to/results` |

## Running the Pipeline
Run the full pipeline using:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

This is the `test_input.json` used in tests:

```json
{
    "create_index": true,
    "transcriptome_fasta_path": "/path/to/downloads/Homo_sapiens.GRCh38.cdna.all.fa.gz",
    "index_output_dir": "/path/to/test",
    "index_basename": "Homo_sapiens.GRCh38.cdna.all.idx",
    "demultiplexed_fastqs": "/path/to/downloads/demultiplexed/*.fastq.gz",
    "single_end": true,
    "paired_end": true,
    "results_dir": "/path/to/test"
}
```

## Expected Output
After a successful run, the pipeline produces the following output structure:

```
transcriptome_analysis/
│── transcriptome_quantification/
│   ├── single_end/
│   │   ├── Treated*_se_abundance.h5
│   │   ├── Treated*_se_abundance.tsv
│   │   ├── Untreated*_se_abundance.h5
│   │   ├── Untreated*_se_abundance.tsv
│   ├── paired_end/
│   │   ├── Treated*_pe_abundance.h5
│   │   ├── Treated*_pe_abundance.tsv
│   │   ├── Untreated*_pe_abundance.h5
│   │   ├── Untreated*_pe_abundance.tsv
│
├── transcriptome_counts/
│   ├── se_vs_pe_transcript_counts.tsv
│   ├── se_vs_pe_boxplot.png
│
├── differential_expression_analysis/
│   ├── transcriptome_dea/
│   │   ├── single_end/
│   │   │   ├── se_sleuth_metadata.tsv
│   │   │   ├── se_sleuth_lrt_results.tsv
│   │   │   ├── se_sleuth_wald_results.tsv
│   │   │   ├── se_pca_plot.png
│   │   │   ├── se_heatmap_plot.png
│   │   │   ├── se_transcript_heatmap_plot.png
│   │   │   ├── se_bootstrap_plot.png
│   │   ├── paired_end/
│   │   │   ├── pe_sleuth_metadata.tsv
│   │   │   ├── pe_sleuth_lrt_results.tsv
│   │   │   ├── pe_sleuth_wald_results.tsv
│   │   │   ├── pe_pca_plot.png
│   │   │   ├── pe_heatmap_plot.png
│   │   │   ├── pe_transcript_heatmap_plot.png
│   │   │   ├── pe_bootstrap_plot.png
│
├── report_generation/
│   ├── report_engine/
│   │   ├── transcriptome_pipeline_report.html
│
└── Homo_sapiens.GRCh38.cdna.all.idx
```

### Output and duration

This is the pipeline output for a full run (SE & PE), showing execution time:

````
nextflow run main.nf -params-file test_input.json -with-docker                                                                                                    ✔ │ at 18:59:07 
Nextflow 24.10.5 is available - Please consider updating your version to it

 N E X T F L O W   ~  version 24.10.4

Launching `main.nf` [gloomy_perlman] DSL2 - revision: dd4ba6cdaa

executor >  local (21)
[54/e8913e] process > transcriptome_analysis_wf:transcriptome_indexing_wf:transcriptome_indexing_app (Indexing Homo_sapiens.GRCh38.cdna.all.idx)                           [100%] 1 of 1 ✔
[4a/b682f6] process > transcriptome_analysis_wf:transcriptome_quantification_se_wf:transcriptome_quantification_se_app (Kallisto Quantification (single_end) - Untreated2) [100%] 8 of 8 ✔
[41/335747] process > transcriptome_analysis_wf:transcriptome_quantification_pe_wf:transcriptome_quantification_pe_app (Kallisto Quantification (paired_end) - Untreated4) [100%] 8 of 8 ✔
[a7/212bb8] process > transcriptome_analysis_wf:transcriptome_counts_wf:transcriptome_counts_app (Transcript Counts Extraction - abundance.tsv)                            [100%] 1 of 1 ✔
[d7/e372d4] process > differential_expression_analysis_wf:transcriptome_dea_se_wf:transcriptome_dea_app (Differential Expression Analysis (single_end))                    [100%] 1 of 1 ✔
[1d/69f61a] process > differential_expression_analysis_wf:transcriptome_dea_pe_wf:transcriptome_dea_app (Differential Expression Analysis (paired_end))                    [100%] 1 of 1 ✔
[da/38cbdb] process > report_generation_wf:report_engine_wf:report_engine_app (Report Engine - Generation)                                                                 [100%] 1 of 1 ✔

Completed at: 09-Mar-2025 19:10:10
Duration    : 11m
CPU hours   : 0.8
Succeeded   : 2
````

### MD5 Checksums
Each module automatically generates an **`md5sum.txt`** file with precomputed checksums for key outputs.  
These can be used for **manual verification** if needed, though no automatic validation is performed.

---

## Execution Environment

I developed and tested this pipeline using the following setup:

### Hardware
- **Machine:** MacBook Pro (14-inch, November 2024)
- **Chip:** Apple M4 Pro
- **Memory:** 48 GB RAM
- **Storage:** 1 TB SSD

### Software & Configuration
- **Operating System:** macOS Sequoia 15.2
- **Nextflow Version:** 24.10.4
- **Docker Desktop:**
  - **CPU Limit:**  12 cores
  - **Memory Limit:**  24 GB
  - **Swap:**  1 GB
  - **Disk Usage Limit::**  1 TB
