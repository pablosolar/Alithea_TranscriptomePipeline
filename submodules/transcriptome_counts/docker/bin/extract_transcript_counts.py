#!/usr/bin/env python3

import argparse
import pandas as pd
import os

def count_detected_transcripts(abundance_file):
    """Counts the number of transcripts with TPM > 0 in an abundance.tsv file."""
    df = pd.read_csv(abundance_file, sep='\t')
    detected_transcripts = (df['tpm'] > 0).sum()
    return detected_transcripts

def process_kallisto_outputs(se_files, pe_files):
    """Processes Kallisto outputs and writes transcript counts for SE & PE samples."""
    counts = []

    # Process Single-End (SE) results
    for se_file in se_files:
        sample_name = os.path.basename(se_file).replace("_se_abundance.tsv", "")
        count = count_detected_transcripts(se_file)
        counts.append({"Sample": sample_name, "Mode-End": "Single", "Detected_Transcripts": count})

    # Process Paired-End (PE) results
    for pe_file in pe_files:
        sample_name = os.path.basename(pe_file).replace("_pe_abundance.tsv", "")
        count = count_detected_transcripts(pe_file)
        counts.append({"Sample": sample_name, "Mode-End": "Paired", "Detected_Transcripts": count})

    # Convert to DataFrame
    df_counts = pd.DataFrame(counts)

    # Sort first by Sample, then by Mode-End to ensure SE appears before PE
    df_counts.sort_values(by=["Sample", "Mode-End"], ascending=[True, False], inplace=True)

    # Save to file
    df_counts.to_csv("se_vs_pe_transcript_counts.tsv", sep='\t', index=False)
    print(f"Transcript counts saved to se_vs_pe_transcript_counts.tsv")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract transcript detection counts from Kallisto results")
    parser.add_argument("--se", nargs="*", default=[], help="List of single-end abundance.tsv files")
    parser.add_argument("--pe", nargs="*", default=[], help="List of paired-end abundance.tsv files")

    args = parser.parse_args()

    # Process and write the output
    process_kallisto_outputs(args.se, args.pe)