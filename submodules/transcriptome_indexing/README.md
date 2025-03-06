# **Transcriptome indexing module**

## **Overview**

I used the `kallisto index -i` command to generate a **precomputed transcriptome index**, which is essential for performing fast pseudo-alignment of RNA-Seq reads. This step is crucial for **transcript quantification** and **differential expression analysis**.

## **Why this is needed**

The **transcriptome index** is necessary for efficient RNA-Seq quantification. Without this index, Kallisto cannot perform fast and accurate pseudo-alignment of RNA-Seq reads. This index is required for the next steps of the workflow, including **quantification** and **differential expression analysis**.

## **Kallisto is fully dockerized**

This module **does not require manual installation of Kallisto**. 

Instead, **I created a public Docker container** that includes **Kallisto v0.51.1** to ensure **consistency across different environments** and prevent dependency issues.

This is specified in `nextflow.config`:

```
process {
    withName: transcriptome_indexing_app {
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

| Parameter                  | Type    | Description                                                                 |
|----------------------------|---------|-----------------------------------------------------------------------------|
| `transcriptome_fasta_path` | string  | Path to the reference transcriptome FASTA file (e.g., `Homo_sapiens.GRCh38.cdna.all.fa.gz`) |
| `index_output_dir`         | string  | Directory where the Kallisto index will be stored                           |
| `index_basename`           | string  | Name of the output Kallisto index file                                      |
| `create_index`             | boolean | Whether to generate the index (`true`) or use an existing one (`false`)    |

## **How to run this module**

### **Running normally (generate index)**

To generate a **real** Kallisto index, execute:

```
nextflow run main.nf -params-file test_input.json -with-docker
```

### **Example test input file**

This is an example of the `test_input.json` file for running the module:

```
{
    "create_index": true,
    "transcriptome_fasta_path": "/path/to/reference/fasta/Homo_sapiens.GRCh38.cdna.all.fa.gz",
    "index_output_dir": "/path/to/index",
    "index_basename": "Homo_sapiens.GRCh38.cdna.all.idx"
}
```

### **Running in stub mode (simulated execution)**

To test the module **without actually generating an index**, stub mode can be used:

```
nextflow run main.nf -stub-run -params-file stub/stub_test_input.json -with-docker
```

### **Example stub test input file**

```
{
    "transcriptome_fasta_path": "/path/to/stub/references/reference.fa.gz",
    "index_output_dir": "stub/index/",
    "index_basename": "/path/to/stub_kallisto.idx",
    "create_index": true
}
```

## **Expected outputs**

| Mode       | Output path                                      |
|------------|------------------------------------------------|
| Normal     | `/path/to/index/Homo_sapiens.GRCh38.cdna.all.idx` |
| Stub mode  | `stub/index/stub_kallisto.idx`                 |

After execution, the **generated transcriptome index** is stored in the directory specified by `index_output_dir`, using the filename defined in `index_basename`.