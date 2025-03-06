# **Transcriptome Quantification Module**

## **Overview**

I decided to use the `kallisto quant` command to perform transcript quantification from RNA-Seq reads using a **precomputed transcriptome index**. This step is crucial for **isoform quantification** and **differential expression analysis**, as specified in the Alithea Genomics testing assignment.

This module supports quantification in the following modes:
- **Single-End (SE) Mode**: Uses only Read 2 (`_R2.fastq.gz`).
- **Paired-End (PE) Mode**: Uses both Read 1 (`_R1.fastq.gz`) and Read 2 (`_R2.fastq.gz`).

## **Why this is needed**

Accurate transcript quantification is essential for understanding gene expression patterns. This module processes RNA-Seq data using **pseudo-alignment**, which enables **fast and efficient quantification** while avoiding computationally expensive full alignments.

- **Single-End Mode (SE)** assumes that only Read 2 is available, which can occur due to sequencing constraints, cost reductions, or specific experimental setups. **SE quantification is faster but may have slightly lower accuracy** compared to PE.
- **Paired-End Mode (PE)** uses both Read 1 and Read 2. PE reads provide **more complete fragment information**, improving **quantification accuracy** by considering both ends of the cDNA fragment.

## **Kallisto is fully dockerized**

This module **does not require manual installation of Kallisto**.

Instead, **I created a public Docker container** that includes **Kallisto v0.51.1**, ensuring **consistency across different environments** and avoiding dependency issues.

This is specified in `nextflow.config`:

```
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

```
nextflow run main.nf -params-file test_input.json -with-docker
```

## **Input parameters**

This module requires the following input parameters:

| Parameter                | Type    | Description                                                                   |
|--------------------------|---------|-------------------------------------------------------------------------------|
| `sample_input`           | array   | List of tuples: [`sample_id, fastq_files`] (single file for SE, two files for PE) |
| `transcriptome_index`    | string  | Path to the precomputed Kallisto transcriptome index file                     |
| `results_dir`            | string  | Directory where quantification results will be stored                         |

## **How to run this module**

### **Running normally (perform quantification)**

To run **real** Kallisto quantification, execute:

```
nextflow run main.nf -params-file test_input.json -with-docker
```

### **Example test input file**

This is an example of the `test_input.json` file for running the module:

```
{
    "sample_input": [
        ["Treated1", "/path/to/demultiplexed/Treated1_R2.fastq.gz"]
    ],
    "transcriptome_index": "/path/to/index/Homo_sapiens.GRCh38.cdna.all.idx",
    "results_dir": "/path/to/results"
}
```

### **Running in stub mode (simulated execution)**

To test the module **without actually running Kallisto**, stub mode can be used:

```
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json -with-docker
```

### **Example stub test input file**

```
{
    "sample_input": [
        ["Stub_Sample1", "/path/to/stub/demultiplexed_fastqs/Stub_Sample1_R2.fastq.gz"]
    ],
    "transcriptome_index": "/path/to/stub/index/stub_kallisto.idx",
    "results_dir": "stub"
}
```

## **Expected outputs**

| Mode          | Final Published Path                                                      |
|--------------|-------------------------------------------------------------------------|
| **Single-End** | `/path/to/results/transcriptome_quantification/single_end/sample_id_se_abundance.tsv` |
| **Single-End** | `/path/to/results/transcriptome_quantification/single_end/sample_id_se_abundance.h5`  |
| **Paired-End** | `/path/to/results/transcriptome_quantification/paired_end/sample_id_pe_abundance.tsv` |
| **Paired-End** | `/path/to/results/transcriptome_quantification/paired_end/sample_id_pe_abundance.h5`  |
| **Stub**      | `stub/transcriptome_quantification/single_end/sample_id_se_abundance.tsv`    |
| **Stub**      | `stub/transcriptome_quantification/paired_end/sample_id_pe_abundance.h5`     |

After execution, the **quantification results** are stored in the directory specified by `results_dir`.

---