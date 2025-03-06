# Alithea Transcriptome Quantification Pipeline

## 📌 Overview
This Nextflow pipeline is designed to automate **transcript quantification** using **Kallisto** and **differential 
expression analysis** using **Sleuth**. The goal is to analyze RNA-seq references efficiently, compare **single-end vs.
paired-end pseudo-alignment results**, and streamline the process for large-scale transcriptomic studies.

The pipeline follows a **modular, scalable, and reproducible** structure, making it adaptable for different 
datasets, workflows, and potential **CI/CD integration**. While CI/CD is not required for this test, the structure 
ensures that future expansions can easily incorporate automated testing and deployment.

Each **module** is structured in a way that it could be independently hosted in a GitLab repository, enabling 
separate development, testing, and validation if needed. This is why each module includes `test_input.json`, 
stubbing, and MD5 validation—ensuring that components can be tested in isolation and seamlessly integrated into
the full pipeline when required.

## 🔹 Key Features
- **Automated transcript quantification** using **Kallisto**.
- **Differential Expression Analysis (DEA)** using **Sleuth**.
- **Support for single-end and paired-end RNA-seq analysis**.
- **Fully modular Nextflow design**, allowing independent execution of components.
- **JSON-driven execution**, enabling flexible configuration.
- **Separate testing framework** for validation and reproducibility.
- **Scalable architecture**, suitable for large datasets and potential CI/CD workflows.

---

## 📂 Pipeline Structure
The pipeline follows a structured **modular approach** to improve reproducibility, facilitate debugging, and ensure adaptability for future expansions.

```
/Alithea_NF_pipeline/
├── main.nf                 # Main Nextflow script
├── nextflow.config         # Configuration file (resources, params)
├── modules/                
│   ├── kallisto/           
│   │   ├── main.nf         # Kallisto process
│   │   ├── stub/           
│   │   │   ├── stub_input.json   # Test input for stubbing
│   │   │   ├── stub_expected.tsv # Expected output (simulated)
│   │   │   ├── stub_log.txt      # Fake log output
│   │   ├── md5sum.txt      # MD5 checksum for Kallisto output
│   ├── sleuth/             
│   │   ├── main.nf         # Sleuth process
│   │   ├── stub/           
│   │   │   ├── stub_input.json   # Test input for stubbing
│   │   │   ├── stub_expected.tsv # Expected output (simulated)
│   │   │   ├── stub_log.txt      # Fake log output
│   │   ├── md5sum.txt      # MD5 checksum for Sleuth output
│   ├── report/             
│       ├── main.nf         # Report generation
│       ├── stub/           
│       │   ├── stub_input.json   # Test input for stubbing
│       │   ├── stub_expected.html # Expected report output
│       │   ├── stub_log.txt      # Fake log output
│       ├── md5sum.txt      # MD5 checksum for report output
│   ├── utils/              # Centralized helper scripts and utilities
│       ├── main.nf         # Utility functions entry point
│       ├── parser.nf       # JSON parser for pipeline execution
│       ├── validate_md5.nf # Function to validate MD5 checksums
│       ├── compare_stub.nf # Function to validate stub outputs
├── subworkflows/           
│   ├── kallisto_analysis/  
│   │   ├── main.nf         # Kallisto subworkflow
│   │   ├── stub/           
│   │   │   ├── stub_input.json   # Test input for stubbing
│   │   │   ├── stub_expected.tsv # Expected output
│   │   │   ├── stub_log.txt      # Fake log output
│   │   ├── md5sum.txt      # MD5 checksum for subworkflow output
│   ├── differential_expression/
│       ├── main.nf         # Sleuth subworkflow
│       ├── stub/           
│       │   ├── stub_input.json   # Test input for stubbing
│       │   ├── stub_expected.tsv # Expected output
│       │   ├── stub_log.txt      # Fake log output
│       ├── md5sum.txt      # MD5 checksum for subworkflow output
├── input_json/             # JSON-based execution (global test cases)
│   ├── test_input.json     # General test input for entire pipeline
├── tests/                  
│   ├── test_kallisto.nf    # Unit test for Kallisto module
│   ├── test_sleuth.nf      # Unit test for Sleuth module
│   ├── test_report.nf      # Unit test for Report generation
├── README.md               
└── Dockerfile                    
```

---

## 🔹 Why This Structure?
This structure was chosen to maximize **scalability, reproducibility, and flexibility**:

- **Modular design** → Each step (Kallisto, DEA, Reporting) is independently executable, making it easy to modify and scale.  
- **Reproducibility** → JSON-based execution allows parameterized runs with full traceability.  
- **Independent testing** → Each module and subworkflow can be tested separately using pre-defined test input JSONs.  
- **CI/CD Compatibility** → Although this test project does not include CI/CD integration, the structure is **ready for GitLab CI/CD pipelines**, making it suitable for production environments.  
- **GitLab Repo Integration** → Each module could be **independently hosted** in a GitLab repository and later integrated into the full pipeline seamlessly.  
- **Future-proofing** → Additional steps (e.g., new statistical models, quality control, or reporting enhancements) can be easily integrated without breaking the workflow.  

---
