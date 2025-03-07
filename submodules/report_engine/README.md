# **Report Generation Module**

## **Overview**
I developed this module to **generate a structured and interactive HTML report** summarizing the results of the transcriptome analysis pipeline. The report dynamically adapts to the available results, displaying **Single-End (SE), Paired-End (PE), or both analyses** based on the input data.

## **What This Module Does?**
1. **Processes input data from DEA results** to generate a summary.
2. **Uses Jinja2 templates** to dynamically create an HTML report.
3. **Automatically detects available SE/PE results** and displays only relevant sections.
4. **Includes expandable tables for large data** to improve readability.
5. **Displays multiple visualizations**, such as PCA plots, heatmaps, and bootstrap confidence plots.

---

## **How the Report is Generated?**
This module leverages **Jinja2 templating** to dynamically create the HTML report.

- **Template (`report_template.html`)**: Defines the **structure and style** of the report.
- **Data (`generate_report.py`)**: Extracts and processes input data.
- **Rendering**: The script fills in the template with results using Jinja2.

The output is an **interactive, structured, and expandable report** with clear visualizations.

---

## **Sections of the Final Report**
The HTML report includes the following sections:

1. **Index Information**
2. **Transcriptome Quantification Summary**
3. **Single-End (SE) Analysis** *(if SE results are available)*:
   - SE Metadata Table
   - Likelihood Ratio Test (LRT) Results
   - Wald Test Results
   - PCA Plot
   - Sample Distance Heatmap
   - Transcript Expression Heatmap
   - Bootstrap Confidence Plot
4. **Paired-End (PE) Analysis** *(if PE results are available)*:
   - PE Metadata Table
   - Likelihood Ratio Test (LRT) Results
   - Wald Test Results
   - PCA Plot
   - Sample Distance Heatmap
   - Transcript Expression Heatmap
   - Bootstrap Confidence Plot
5. **SE vs. PE Transcript Detection Boxplot** *(if both SE & PE exist)*

---

## **Fully Dockerized Execution**
This module is designed for **reproducibility** and is **fully containerized**.

```bash
process {
    withName: report_engine_app {
        container = "pablosolar/report_engine:v1.0.0"
    }
}
```

To run with Docker, execute:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

---

## **Input Parameters**
This module requires the following parameters:

| Parameter                 | Type   | Description                                    |
|---------------------------|--------|------------------------------------------------|
| `index_info`              | string | Path to index information file                 |
| `transcriptome_counts`    | string | Transcript quantification results              |
| `transcriptome_boxplot`   | string | (Optional) SE vs PE transcript detection plot |
| `se_sleuth_metadata_file` | string | (Optional) SE Metadata file for DEA           |
| `se_sleuth_lrt_results`   | string | (Optional) SE LRT results                     |
| `se_sleuth_wald_results`  | string | (Optional) SE Wald results                    |
| `se_sleuth_pca_plot`      | string | (Optional) SE PCA plot                        |
| `se_sleuth_heatmap_plot`  | string | (Optional) SE Sample Heatmap                  |
| `se_sleuth_transcript_heatmap_plot` | string | (Optional) SE Transcript Heatmap             |
| `se_sleuth_bootstrap_plot` | string | (Optional) SE Bootstrap Confidence Plot       |
| `pe_sleuth_metadata_file` | string | (Optional) PE Metadata file for DEA           |
| `pe_sleuth_lrt_results`   | string | (Optional) PE LRT results                     |
| `pe_sleuth_wald_results`  | string | (Optional) PE Wald results                    |
| `pe_sleuth_pca_plot`      | string | (Optional) PE PCA plot                        |
| `pe_sleuth_heatmap_plot`  | string | (Optional) PE Sample Heatmap                  |
| `pe_sleuth_transcript_heatmap_plot` | string | (Optional) PE Transcript Heatmap             |
| `pe_sleuth_bootstrap_plot` | string | (Optional) PE Bootstrap Confidence Plot       |
| `results_dir`             | string | Directory where the report is stored          |

---

## **How to Run This Module**

### **Running Normally (Generate Report)**
To generate the **interactive transcriptome analysis report**, run:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

#### **Example of `test_input.json`**
```json
{
    "index_info": "/path/ro/results/Homo_sapiens.GRCh38.cdna.all.idx",
    "transcriptome_counts": "/path/ro/results/transcriptome_counts/se_vs_pe_transcript_counts.tsv",
    "transcriptome_boxplot": "",

    "se_sleuth_metadata_file": "/path/ro/results/transcriptome_dea/single_end/se_sleuth_metadata.tsv",
    "se_sleuth_lrt_results": "/path/ro/results/transcriptome_dea/single_end/se_sleuth_lrt_results.tsv",
    "se_sleuth_wald_results": "/path/ro/results/transcriptome_dea/single_end/se_sleuth_wald_results.tsv",
    "se_sleuth_pca_plot": "/path/ro/results/transcriptome_dea/single_end/se_pca_plot.png",
    "se_sleuth_heatmap_plot": "/path/ro/results/transcriptome_dea/single_end/se_heatmap_plot.png",
    "se_sleuth_transcript_heatmap_plot": "/path/ro/results/transcriptome_dea/single_end/se_transcript_heatmap_plot.png",
    "se_sleuth_bootstrap_plot": "/path/ro/results/transcriptome_dea/single_end/se_bootstrap_plot.png",

    "pe_sleuth_metadata_file": "",
    "pe_sleuth_lrt_results": "",
    "pe_sleuth_wald_results": "",
    "pe_sleuth_pca_plot": "",
    "pe_sleuth_heatmap_plot": "",
    "pe_sleuth_transcript_heatmap_plot": "",
    "pe_sleuth_bootstrap_plot": "",

    "results_dir": "results"
}
```

### **Running in Stub Mode (Simulated Execution)**
To test the module without generating a real report:

```bash
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json
```

#### **Example of `stub_test_input.json`**
```json
{
    "index_info": "/path/ro/sutb/stub/index/stub_kallisto.idx",
    "transcriptome_counts": "/path/ro/sutb/stub/transcriptome_counts/se_vs_pe_transcript_counts.tsv",
    "transcriptome_boxplot": "/path/ro/sutb/stub/transcriptome_counts/se_vs_pe_boxplot.png",

    "se_sleuth_metadata_file": "/path/ro/sutb/stub/transcriptome_dea/single_end/sleuth_metadata.tsv",
    "se_sleuth_lrt_results": "/path/ro/sutb/stub/transcriptome_dea/single_end/sleuth_lrt_results.tsv",
    "se_sleuth_wald_results": "/path/ro/sutb/stub/transcriptome_dea/single_end/sleuth_wald_results.tsv",
    "se_sleuth_pca_plot": "/path/ro/sutb/stub/transcriptome_dea/single_end/pca_plot.png",
    "se_sleuth_heatmap_plot": "/path/ro/sutb/stub/transcriptome_dea/single_end/heatmap_plot.png",
    "se_sleuth_transcript_heatmap_plot": "/path/ro/sutb/stub/transcriptome_dea/single_end/transcript_heatmap_plot.png",
    "se_sleuth_bootstrap_plot": "/path/ro/sutb/stub/transcriptome_dea/single_end/bootstrap_plot.png",

    "pe_sleuth_metadata_file": "",
    "pe_sleuth_lrt_results": "",
    "pe_sleuth_wald_results": "",
    "pe_sleuth_pca_plot": "",
    "pe_sleuth_heatmap_plot": "",
    "pe_sleuth_transcript_heatmap_plot": "",
    "pe_sleuth_bootstrap_plot": "",
    "results_dir": "stub"
}
```

---

## **Expected Outputs**

| Mode      | Output File Path                                  |
|-----------|--------------------------------------------------|
| Normal    | `results/report_engine/transcriptome_pipeline_report.html` |
| Stub Mode | `stub/report_engine/transcriptome_pipeline_report.html` |

After execution, the report will be stored in the `results_dir` specified in the parameters.

---

## **Decisions I Took in Report Generation**

### **1. Dynamic Content Rendering**
- The report **only includes SE or PE sections if results exist**.
- If **both SE and PE are available**, the report includes **comparative visualizations**.

### **2. Expandable Tables**
- Large result tables are **expandable** to keep the report clean.
- This ensures **readability** while maintaining **accessibility** to full data.

### **3. Template-Driven Report**
- The **Jinja2 template system** ensures report structure is **modular and reusable**.
- If future updates require new sections, **modifications only need changes in the template**.

---

## **References**
The approach for dynamic HTML report generation is based on:
- [Jinja2 Documentation](https://jinja.palletsprojects.com/)