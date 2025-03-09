# Alithea Transcriptome Pipeline

## 📌 Overview
The **Alithea Transcriptome Pipeline** is a fully automated Nextflow pipeline designed to perform **transcript quantification** using **Kallisto** and **differential expression analysis (DEA)** using **Sleuth**. The pipeline processes RNA-seq data, supporting both **Single-End (SE) and Paired-End (PE) reads**, and generates **comprehensive transcript abundance tables, DEA results, and visual reports**.

This pipeline is structured to be **modular, scalable, and reproducible**, making it adaptable for large-scale transcriptomic studies and potential **CI/CD integration**.

Each submodule and subworkflow is designed to be **independently executable and testable**, ensuring that components can be validated separately and seamlessly integrated into the full pipeline.

## 🔹 Key Features
- **Automated transcript quantification** using **Kallisto**.
- **Differential Expression Analysis (DEA)** using **Sleuth**.
- **Support for both Single-End (SE) and Paired-End (PE) RNA-seq analysis**.
- **Fully modular Nextflow design**, allowing independent execution of components.
- **JSON-driven execution**, enabling flexible configuration.
- **Containerized execution** for reproducibility and portability.
- **Independent testing framework** for validation and debugging.
- **Scalable architecture**, suitable for large datasets and potential CI/CD workflows.

---

## 📂 Pipeline Structure
The pipeline follows a structured **modular approach** to ensure reproducibility, facilitate debugging, and allow easy scalability. It is composed of **subworkflows**, which orchestrate multiple **submodules** that handle specific tasks.

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

## 🔹 Subworkflows & Modules
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

### **Submodules Used**
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


## 📥 Input Parameters
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

## 🚀 Running the Pipeline
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

## 📤 Expected Output
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
