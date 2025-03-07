# **Differential Expression Analysis (DEA) Module**

## **Overview**
I developed this module to **perform transcript-level differential expression analysis (DEA) using Sleuth** on quantification results from **Kallisto pseudo-alignment**. This step identifies transcripts that exhibit **significant expression changes** between conditions (e.g., **treated vs. untreated**).

## **What This Module Does?**
1. **Reads** Kallisto `.h5` quantification outputs for each sample.
2. **Generates metadata** to associate samples with conditions (e.g., **treated vs. untreated**).
3. **Fits statistical models** using Sleuth:
   - **Likelihood Ratio Test (LRT)** to detect globally significant transcripts.
   - **Wald Test** for pairwise comparisons (treated vs untreated).
4. **Visualizes results** via multiple plots:
   - **PCA plot** (`se_pca_plot.png`, `pe_pca_plot.png`) for sample clustering.
   - **Sample distance heatmap** (`se_heatmap_plot.png`, `pe_heatmap_plot.png`).
   - **Transcript expression heatmap** (`se_transcript_heatmap_plot.png`, `pe_transcript_heatmap_plot.png`).
   - **Bootstrap confidence plot** (`se_bootstrap_plot.png`, `pe_bootstrap_plot.png`).

---

## **Why Use Sleuth for DEA?**
I chose **Sleuth** because it **natively integrates with Kallisto** and accounts for **quantification uncertainty** using bootstrapped variance estimates.

- **LRT** identifies **globally significant transcript expression changes** across conditions.
- **Wald Test** pinpoints **specific pairwise differences** in transcript expression.
- **Bootstrap estimates** allow **confidence intervals**, improving robustness.

---

## **Sleuth DEA is Fully Dockerized**
This module **does not require manual installation of dependencies**.

Instead, **I created a public Docker container** (`pablosolar/sleuth_dea:v1.0.0`) to ensure **consistency across different environments** and prevent dependency issues.

This is specified in `nextflow.config`:

```bash
process {
    withName: transcriptome_dea_app {
        container = "pablosolar/sleuth_dea:v1.0.0"
    }
}
```

When running the module, simply add `-with-docker` to ensure execution inside the container:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

---

## **Input Parameters**

This module requires the following input parameters:

| Parameter              | Type    | Description                                           |
|------------------------|--------|------------------------------------------------------|
| `se_abundance_h5s`    | list   | List of SE `.h5` quantification files               |
| `pe_abundance_h5s`    | list   | List of PE `.h5` quantification files               |
| `results_dir`         | string | Path where output results will be stored           |

---

## **How to Run This Module**

### **Running Normally (Perform DEA & Generate Plots)**
To perform **differential expression analysis**, I run:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

#### **Example of `test_input.json`**
Here is the test input JSON file I use for running the module normally:

```json
{
    "se_abundance_h5s": [
        "/path/to/transcriptome_quantification/single_end/Treated1_se_abundance.h5",
        "/path/to/transcriptome_quantification/single_end/Treated2_se_abundance.h5",
        "/path/to/transcriptome_quantification/single_end/Untreated1_se_abundance.h5",
        "/path/to/transcriptome_quantification/single_end/Untreated2_se_abundance.h5"
    ],
    "pe_abundance_h5s": [
        "/path/to/transcriptome_quantification/paired_end/Treated1_pe_abundance.h5",
        "/path/to/transcriptome_quantification/paired_end/Untreated1_pe_abundance.h5"
    ],
    "results_dir": "results"
}
```

### **Running in Stub Mode (Simulated Execution)**
To test without performing real DEA, I use stub mode:

```bash
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json
```

#### **Example of `stub_test_input.json`**
This is the stub test input JSON file for validating module execution:

```json
{
    "se_abundance_h5s": [
        "/path/to/stub/transcriptome_quantification/single_end/Stub_Sample1_pe_abundance.h5"
    ],
    "results_dir": "stub"
}
```

---

## **Expected Outputs**

| Mode      | Output File Path                                                      |
|-----------|-----------------------------------------------------------------------|
| **SE**    | `results/transcriptome_dea/single_end/se_sleuth_metadata.tsv`         |
| **SE**    | `results/transcriptome_dea/single_end/se_sleuth_lrt_results.tsv`      |
| **SE**    | `results/transcriptome_dea/single_end/se_sleuth_wald_results.tsv`     |
| **SE**    | `results/transcriptome_dea/single_end/se_pca_plot.png`                |
| **SE**    | `results/transcriptome_dea/single_end/se_heatmap_plot.png`            |
| **SE**    | `results/transcriptome_dea/single_end/se_transcript_heatmap_plot.png` |
| **SE**    | `results/transcriptome_dea/single_end/se_bootstrap_plot.png`          |
| **PE**    | `results/transcriptome_dea/paired_end/pe_sleuth_metadata.tsv`         |
| **PE**    | `results/transcriptome_dea/paired_end/pe_sleuth_lrt_results.tsv`      |
| **PE**    | `results/transcriptome_dea/paired_end/pe_sleuth_wald_results.tsv`     |
| **PE**    | `results/transcriptome_dea/paired_end/pe_pca_plot.png`                |
| **PE**    | `results/transcriptome_dea/paired_end/pe_heatmap_plot.png`            |
| **PE**    | `results/transcriptome_dea/paired_end/pe_transcript_heatmap_plot.png` |
| **PE**    | `results/transcriptome_dea/paired_end/pe_bootstrap_plot.png`          |
| Stub Mode | `stub/transcriptome_dea/single_end/se_sleuth_metadata.tsv`               |
| Stub Mode | `stub/transcriptome_dea/single_end/se_sleuth_lrt_results.tsv`               |
| Stub Mode | `stub/transcriptome_dea/single_end/se_sleuth_wald_results.tsv`               |
| Stub Mode | `stub/transcriptome_dea/single_end/se_pca_plot.tsv`            |
| Stub Mode | `stub/transcriptome_dea/single_end/se_heatmap_plot.tsv`            |
| Stub Mode | `stub/transcriptome_dea/single_end/se_transcript_heatmap_plot.tsv`            |
| Stub Mode | `stub/transcriptome_dea/single_end/se_bootstrap_plot.tsv`            |

#### **Generated Plots**
- **PCA Plot (`se|pe_pca_plot.png`)**: Shows clustering of samples by condition.
- **Heatmap (`se|pe_heatmap_plot.png`)**: Displays pairwise distances between samples.
- **Transcript Heatmap (`se|pe_transcript_heatmap_plot.png`)**: Highlights expression patterns of **up to first 40** differentially expressed transcripts.
- **Bootstrap Plot (`se|pe_bootstrap_plot.png`)**: Generated for the **most significant transcript**.

After execution, the **quantification results** are stored in the directory specified by `results_dir`.

---

## **Decisions I Took in the R Script**

### **1. Metadata Handling**
- I automatically generate `sleuth_metadata.tsv` to **map samples to conditions** (treated/untreated).
- This ensures samples are correctly grouped for statistical modeling.
- The metadata file is **validated** to ensure it contains the required `sample`, `condition`, and `path` columns before proceeding.

### **2. Model Selection**
I defined:
- **Full model**: `~condition` (includes condition-based expression differences).
- **Reduced model**: `~1` (null model with no condition effect).
- This setup allows **LRT to detect global transcript expression changes** by comparing the **full** and **reduced** models.

### **3. Likelihood Ratio Test (LRT)**
- Compares the **full** and **reduced** models to identify transcripts with **significant expression differences**.
- Results are saved in `se|pe_sleuth_lrt_results.tsv`.

### **4. Wald Test**
- Applied for **pairwise comparisons** (e.g., treated vs. untreated conditions).
- Results are **sorted** by q-value (FDR-adjusted p-value) and effect size before saving to `sleuth_wald_results.tsv`.

### **5. Selection of the Most Significant Transcript for Bootstrap Plot**
- I **checked if bootstrap estimates were available** (`so$bs_quants`).
- The **most significant transcript** (lowest q-value) with valid bootstrap estimates is selected for visualization.
- The plot is saved as `bootstrap_plot.png`.

### **6. Quality Control and Visualization**
- **PCA Plot (`se|pe_pca_plot.png`)**: Detects batch effects and sample clustering.
- **Sample Heatmap (`se|pe_heatmap_plot.png`)**: Displays transcript-based sample similarities.
- **Transcript Heatmap (`se|pe_transcript_heatmap_plot.png`)**: Visualizes expression patterns of **the top 40 differentially expressed transcripts**.
- **Bootstrap Plot (`se|pe_ootstrap_plot.png`)**:  Visualizes bootstrap variation for the most significant transcript with valid bootstrap estimates.

---

## **References**
I based my approach on these references:
- [Pachter Lab - Sleuth Walkthrough](https://pachterlab.github.io/sleuth_walkthroughs/trapnell/analysis.html)
- [Harvard Biostatistics Training - Sleuth](https://hbctraining.github.io/DGE_workshop_salmon/lessons/09_sleuth.html)
- [Sleuth Analysis RPubs](https://rpubs.com/kapeelc12/Sleuth)
- Pimentel, H., Bray, N.L., Puente, S., Melsted, P., & Pachter, L. (2017). *Differential analysis of RNA-Seq incorporating quantification uncertainty.* *Nature Methods*, 14(7), 687-690.
- Bray, N.L., Pimentel, H., Melsted, P., & Pachter, L. (2016). *Near-optimal probabilistic RNA-seq quantification.* *Nature Biotechnology*, 34(5), 525-527.
"""