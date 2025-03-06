# Kallisto Quantification Subworkflow (`transcriptome_analysis_wf`)

## Overview

This subworkflow performs **isoform quantification** using Kallisto in both **Single-End (SE) and Paired-End (PE) modes**. It automatically detects the sequencing mode based on the Nextflow parameters and processes the appropriate samples accordingly.

The results are **separated by mode** to ensure clear organization and compatibility with downstream analyses.

## How the Subworkflow Works

1. **Loads the Kallisto index**
   - If `create_index=true`, it runs the `transcriptome_index` module to generate the index.
   - Otherwise, it loads an existing index file.

2. **Reads input FASTQ files**
   - Automatically **detects SE and PE samples** based on filenames (`_R1` / `_R2`).

3. **Runs separate Kallisto quantification workflows**
   - **SE quantification (`transcriptome_quantification_se_wf`)** → Processes `_R2` files.
   - **PE quantification (`transcriptome_quantification_pe_wf`)** → Groups `_R1 + R2` for paired-end.

## Why Separate Workflows for SE & PE?

Using **separate workflows** instead of a single combined workflow **resolves multiple issues**, including:

✔ **Output structure conflicts** → `publishDir` works reliably when SE & PE results are stored in separate locations.  
✔ **Process independence** → Debugging, testing, and execution are clearer.  
✔ **Performance stability** → Kallisto runs efficiently even when workflows are separate.  

### **Final Approach → Two Independent Workflows**
- **`transcriptome_quantification_se_wf`** → Runs for Single-End samples (SE).  
- **`transcriptome_quantification_pe_wf`** → Runs for Paired-End samples (PE).  

## Prerequisites

### Install Kallisto  
Ensure Kallisto is installed before running the pipeline:

```
brew install kallisto
```

## Usage

### Nextflow Parameters

| Parameter         | Type    | Description  |
|------------------|--------|-------------|
| `create_index` | Boolean | `true` → Generate index, `false` → Use existing index. |
| `transcriptome_fasta_path` | String  | Path to the reference transcriptome FASTA file. |
| `index_output_dir`  | String  | Directory where the Kallisto index is stored or generated. |
| `index_basename`  | String  | Name of the Kallisto index file. |
| `demultiplexed_fastqs` | String | Path to the input FASTQ files. |
| `single_end` | Boolean | `true` → Run SE processing, `false` → Skip SE. |
| `paired_end` | Boolean | `true` → Run PE processing, `false` → Skip PE. |

## Testing

### Run Normally (Full Execution)

```
nextflow run main.nf -params-file test_input.json
```

### Run in Stub Mode (Simulated Execution)

```
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json
```

#### Example: `stub/stub_test_input.json`

```
{
    "create_index": false,
    "transcriptome_fasta_path": "stub/references/Homo_sapiens.GRCh38.cdna.all.fa.gz",
    "index_output_dir": "stub/index/",
    "index_basename": "stub_kallisto.idx",
    "demultiplexed_fastqs": "stub/demultiplexed/*.fastq.gz",
    "single_end": true,
    "paired_end": false
}
```

## Expected Outputs

| Mode      | Output Path  |
|-----------|--------------|
| **SE Quantification** | `results/transcriptome_quantification/single_end/quant_SAMPLE_ID/` |
| **PE Quantification** | `results/transcriptome_quantification/paired_end/quant_SAMPLE_ID/` |
| **Stub Mode (SE)** | `stub/transcriptome_quantification/single_end/quant_SAMPLE_ID/abundance.tsv` |
| **Stub Mode (PE)** | `stub/transcriptome_quantification/paired_end/quant_SAMPLE_ID/abundance.tsv` |

---