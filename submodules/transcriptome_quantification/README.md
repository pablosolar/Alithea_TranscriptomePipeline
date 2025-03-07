# **Transcriptome Quantification Module**

## **Overview**

I developed this module to **perform transcript quantification using Kallisto** on RNA-Seq reads. This step is essential for **isoform quantification and differential expression analysis (DEA)**, ensuring that transcript abundance is accurately estimated for downstream analysis.

This module supports two quantification modes:
- **Single-End (SE) Mode**: Uses only Read 2 (`_R2.fastq.gz`).
- **Paired-End (PE) Mode**: Uses both Read 1 (`_R1.fastq.gz`) and Read 2 (`_R2.fastq.gz`).

To avoid filename collisions in Nextflow, I created separate workflows for SE and PE quantification, ensuring that outputs are properly distinguished and managed.

---

## **Why Use Kallisto for Quantification?**
I chose **Kallisto** because it offers **fast and accurate transcript quantification** through **pseudo-alignment**.

- **Single-End Mode (SE)** is useful when only Read 2 is available, reducing costs but with slightly lower accuracy.
- **Paired-End Mode (PE)** provides **better fragment information**, improving quantification precision.

---

## **Kallisto is Fully Dockerized**
This module **does not require manual installation of Kallisto**.

Instead, **I created a public Docker container** (`pablosolar/kallisto_tool:v0.51.1`) to ensure **consistency across different environments**.

This is specified in `nextflow.config`:

```bash
process {
    withName: transcriptome_quantification_se_app {
        container = "pablosolar/kallisto_tool:v0.51.1"
    }
    withName: transcriptome_quantification_pe_app {
        container = "pablosolar/kallisto_tool:v0.51.1"
    }
}
```

When running the module, simply add `-with-docker` to ensure execution inside the container:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

---

## **Input Parameters**

| Parameter                | Type   | Description                                                   |
|--------------------------|--------|---------------------------------------------------------------|
| `sample_input`           | array  | List of tuples: [`sample_id, fastq_files`] (single file for SE, two files for PE) |
| `transcriptome_index`    | string | Path to the precomputed Kallisto transcriptome index file     |
| `results_dir`            | string | Directory where quantification results will be stored         |

---

## **How to Run This Module**

### **Running Normally (Perform Quantification)**
To run **real** Kallisto quantification, execute:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

#### **Example of `test_input.json`**
```json
{
    "sample_input": [
        ["Treated1", "/path/to/demultiplexed/Treated1_R2.fastq.gz"]
    ],
    "transcriptome_index": "/path/to/index/Homo_sapiens.GRCh38.cdna.all.idx",
    "results_dir": "/path/to/results"
}
```

---

### **Running in Stub Mode (Simulated Execution)**
To test without performing real quantification, use stub mode:

```bash
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json -with-docker
```

#### **Example of `stub_test_input.json`**
```json
{
    "sample_input": [
        ["Stub_Sample1", "/path/to/stub/demultiplexed_fastqs/Stub_Sample1_R2.fastq.gz"]
    ],
    "transcriptome_index": "/path/to/stub/index/stub_kallisto.idx",
    "results_dir": "stub"
}
```

---

## **Expected Outputs**

| Mode          | Final Published Path                                                                  |
|--------------|---------------------------------------------------------------------------------------|
| **Single-End** | `/path/to/results/transcriptome_quantification/single_end/sample_id_se_abundance.tsv` |
| **Single-End** | `/path/to/results/transcriptome_quantification/single_end/sample_id_se_abundance.h5`  |
| **Paired-End** | `/path/to/results/transcriptome_quantification/paired_end/sample_id_pe_abundance.tsv` |
| **Paired-End** | `/path/to/results/transcriptome_quantification/paired_end/sample_id_pe_abundance.h5`  |
| **Stub**      | `stub/transcriptome_quantification/single_end/sample_id_se_abundance.tsv`             |
| **Stub**      | `stub/transcriptome_quantification/single_end/sample_id_se_abundance.h5`              |

After execution, the **quantification results** are stored in the directory specified by `results_dir`.

---

## **References**
I based my approach on these references:
- [Kallisto GitHub](https://github.com/pachterlab/kallisto)  
- [Kallisto official documentation](https://pachterlab.github.io/kallisto/)
- Bray, N.L., Pimentel, H., Melsted, P., & Pachter, L. (2016). *Near-optimal probabilistic RNA-seq quantification.* *Nature Biotechnology*, 34(5), 525-527.
---