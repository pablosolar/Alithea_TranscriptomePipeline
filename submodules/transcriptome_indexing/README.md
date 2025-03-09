# **Transcriptome Indexing Module**

## **Overview**

I developed this module to **generate a transcriptome index for Kallisto** using a **reference transcriptome FASTA file**. This step is required to enable **fast pseudo-alignment** of RNA-Seq reads in later stages of the pipeline.

## **What This Module Does?**
1. Uses `kallisto index -i` to generate a **precomputed transcriptome index**.
2. Saves the generated index in the specified directory (`index_output_dir`).
3. Ensures consistency by allowing the user to **choose between generating a new index or using an existing one** (`create_index`).

---

## **Why is This Needed?**
Kallisto requires a **precomputed index** to efficiently perform pseudo-alignment and transcript quantification. Without this index, RNA-Seq reads cannot be aligned quickly, making transcript abundance estimation **impractically slow**.

- **Using an index greatly reduces computational time** for RNA-Seq analysis.
- **Ensures reproducibility** by working with a pre-defined reference transcriptome.
- **Supports flexible execution**: If a pre-existing index is available, the module can skip the index generation step.

---

## **Kallisto Indexing is Fully Dockerized**

This module **does not require manual installation of Kallisto**.

Instead, **I created a public Docker container** (`pablosolar/kallisto_tool:v0.51.1`) to ensure **consistency across different environments** and prevent dependency issues.

This is specified in `nextflow.config`:

```bash
process {
    withName: transcriptome_indexing_app {
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

This module requires the following input parameters:

| Parameter                  | Type    | Description                                                                                 |
|----------------------------|---------|---------------------------------------------------------------------------------------------|
| `transcriptome_fasta_path` | string  | Path to the reference transcriptome FASTA file (e.g., `Homo_sapiens.GRCh38.cdna.all.fa.gz`) |
| `index_output_dir`         | string  | Directory where the Kallisto index will be stored or fetched (if `create_index` is `false`   |
| `index_basename`           | string  | Name of the output Kallisto index file                                                      |
| `create_index`             | boolean | Whether to generate the index (`true`) or use an existing one (`false`)                     |

---

## **How to Run This Module**

### **Running Normally (Generate Index)**
To generate a **real** Kallisto index, I run:

```bash
nextflow run main.nf -params-file test_input.json -with-docker
```

#### **Example of `test_input.json`**
Here is the test input JSON file I use for running the module normally:

```json
{
    "create_index": true,
    "transcriptome_fasta_path": "/path/to/reference/fasta/Homo_sapiens.GRCh38.cdna.all.fa.gz",
    "index_output_dir": "/path/to/index",
    "index_basename": "Homo_sapiens.GRCh38.cdna.all.idx"
}
```

### **Running in Stub Mode (Simulated Execution)**
To test without generating an actual index, I use stub mode:

```bash
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json
```

#### **Example of `stub_test_input.json`**
This is the stub test input JSON file for validating module execution:

```json
{
    "transcriptome_fasta_path": "/path/to/stub/references/reference.fa.gz",
    "index_output_dir": "stub/index/",
    "index_basename": "stub_kallisto.idx",
    "create_index": true
}
```

---

## **Expected Outputs**

| Mode       | Output File Path                                       |
|------------|--------------------------------------------------------|
| Normal     | `/path/to/index/Homo_sapiens.GRCh38.cdna.all.idx`      |
| Stub Mode  | `stub/index/stub_kallisto.idx`                        |

After execution, the **generated transcriptome index** is stored in the directory specified by `index_output_dir`, using the filename defined in `index_basename`.

Additionally, this module generates an `md5sum.txt` file listing checksums for key output files.

---

## **References**
I based my approach on these references:
- [Kallisto GitHub](https://github.com/pachterlab/kallisto)  
- [Kallisto official documentation](https://pachterlab.github.io/kallisto/)
- Bray, N.L., Pimentel, H., Melsted, P., & Pachter, L. (2016). *Near-optimal probabilistic RNA-seq quantification.* *Nature Biotechnology*, 34(5), 525-527.
---