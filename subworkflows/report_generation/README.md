# Report Generation Subworkflow

## Overview
The `report_generation_wf` subworkflow is responsible for generating a comprehensive **HTML report** summarizing the results of the transcriptome analysis pipeline. It integrates key outputs from the transcriptome quantification and differential expression analysis steps, presenting them in an organized and visually appealing manner.

This subworkflow ensures that all relevant results, including transcript counts, differential expression outputs, and statistical visualizations, are compiled into a single, easy-to-read report.

## Why This Subworkflow Exists
Manually reviewing transcriptome analysis results across multiple files and directories can be cumbersome. This subworkflow automates report generation, integrating:
- **Transcriptome Index Information**
- **Transcript Quantification Summaries**
- **Differential Expression Analysis Results**
- **Visualization Plots**

By consolidating these outputs, the report enhances **readability, reproducibility, and accessibility** of key findings.

## How It Works
The subworkflow follows these major steps:

1. **Collects input data** from transcriptome analysis and differential expression workflows.
2. **Processes data** using Jinja2 templating to dynamically generate an HTML report.
3. **Integrates visualizations** such as PCA plots, heatmaps, and transcript quantification boxplots.
4. **Saves the final report** as `transcriptome_pipeline_report.html`.

## Submodules Used
This subworkflow calls the following **containerized** submodule:
- **Report Engine:** [`report_engine_wf`](../../submodules/report_engine/README.md)

Refer to its README file for details on implementation.

## Input Parameters
| Parameter                           | Description                                                                        | Example Value                  |
|--------------------------------------|------------------------------------------------------------------------------------|--------------------------------|
| `index_info`                        | Path to the transcriptome index file                                               | `/path/to/index/genome.idx`   |
| `transcriptome_counts`               | Transcript count matrix (TSV format)                                               | `/path/to/results/counts.tsv` |
| `transcriptome_boxplot`              | Boxplot comparing SE vs PE transcript detection                                    | `/path/to/results/boxplot.png` |
| `se_sleuth_metadata_file`            | Metadata file for SE differential expression analysis                              | `/path/to/results/se_metadata.tsv` |
| `se_sleuth_lrt_results`              | LRT results for SE DEA                                                             | `/path/to/results/se_lrt.tsv` |
| `se_sleuth_wald_results`             | Wald test results for SE DEA                                                       | `/path/to/results/se_wald.tsv` |
| `se_sleuth_pca_plot`                 | PCA plot for SE analysis                                                           | `/path/to/results/se_pca.png` |
| `se_sleuth_heatmap_plot`             | Sample heatmap for SE analysis                                                     | `/path/to/results/se_heatmap.png` |
| `se_sleuth_transcript_heatmap_plot`  | Transcript heatmap for SE analysis                                                 | `/path/to/results/se_transcript_heatmap.png` |
| `se_sleuth_bootstrap_plot`           | Bootstrap confidence plot for SE analysis                                          | `/path/to/results/se_bootstrap.png` |
| `pe_sleuth_metadata_file`            | Metadata file for PE differential expression analysis                              | `/path/to/results/pe_metadata.tsv` |
| `pe_sleuth_lrt_results`              | LRT results for PE DEA                                                             | `/path/to/results/pe_lrt.tsv` |
| `pe_sleuth_wald_results`             | Wald test results for PE DEA                                                       | `/path/to/results/pe_wald.tsv` |
| `pe_sleuth_pca_plot`                 | PCA plot for PE analysis                                                           | `/path/to/results/pe_pca.png` |
| `pe_sleuth_heatmap_plot`             | Sample heatmap for PE analysis                                                     | `/path/to/results/pe_heatmap.png` |
| `pe_sleuth_transcript_heatmap_plot`  | Transcript heatmap for PE analysis                                                 | `/path/to/results/pe_transcript_heatmap.png` |
| `pe_sleuth_bootstrap_plot`           | Bootstrap confidence plot for PE analysis                                          | `/path/to/results/pe_bootstrap.png` |
| `results_dir`                        | Directory where the final report is stored (will create `report_engine` subfolder) | `/path/to/results`            |

## How to Run
Run the subworkflow using Nextflow and Docker:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

This will execute the subworkflow using the parameters defined in `test_input.json`. Example

```json
{
    "index_info": "/path/to/Homo_sapiens.GRCh38.cdna.all.idx",
    "transcriptome_counts": "/path/to/transcriptome_counts/se_vs_pe_transcript_counts.tsv",
    "transcriptome_boxplot": "/path/to/transcriptome_counts/se_vs_pe_boxplot.png",

    "se_sleuth_metadata_file": "/path/to/transcriptome_dea/single_end/se_sleuth_metadata.tsv",
    "se_sleuth_lrt_results": "/path/to/transcriptome_dea/single_end/se_sleuth_lrt_results.tsv",
    "se_sleuth_wald_results": "/path/to/transcriptome_dea/single_end/se_sleuth_wald_results.tsv",
    "se_sleuth_pca_plot": "/path/to/transcriptome_dea/single_end/se_pca_plot.png",
    "se_sleuth_heatmap_plot": "/path/to/transcriptome_dea/single_end/se_heatmap_plot.png",
    "se_sleuth_transcript_heatmap_plot": "/path/to/transcriptome_dea/single_end/se_transcript_heatmap_plot.png",
    "se_sleuth_bootstrap_plot": "/path/to/transcriptome_dea/single_end/se_bootstrap_plot.png",

    "pe_sleuth_metadata_file": "/path/to/transcriptome_dea/paired_end/pe_sleuth_metadata.tsv",
    "pe_sleuth_lrt_results": "/path/to/transcriptome_dea/paired_end/pe_sleuth_lrt_results.tsv",
    "pe_sleuth_wald_results": "/path/to/transcriptome_dea/paired_end/pe_sleuth_wald_results.tsv",
    "pe_sleuth_pca_plot": "/path/to/transcriptome_dea/paired_end/pe_pca_plot.png",
    "pe_sleuth_heatmap_plot": "/path/to/transcriptome_dea/paired_end/pe_heatmap_plot.png",
    "pe_sleuth_transcript_heatmap_plot": "/path/to/transcriptome_dea/paired_end/pe_transcript_heatmap_plot.png",
    "pe_sleuth_bootstrap_plot": "/path/to/transcriptome_dea/paired_end/pe_bootstrap_plot.png",

    "results_dir": "/path/to/results"
}
```

## Expected Outputs
| Output                        | Description                              |
|--------------------------------|------------------------------------------|
| `transcriptome_pipeline_report.html` | HTML report summarizing all analysis results |

## Decisions Taken
- The report includes both **Single-End (SE) and Paired-End (PE) results** if available.
- Visualizations such as PCA plots and heatmaps are automatically integrated.
- The report format follows a structured layout for clarity and ease of interpretation.
- **All submodules used in this workflow are containerized**, ensuring reproducibility.

## References
- Jinja2 Documentation: https://jinja.palletsprojects.com/en/latest/
- Nextflow Documentation: https://www.nextflow.io/docs/latest/getstarted.html

