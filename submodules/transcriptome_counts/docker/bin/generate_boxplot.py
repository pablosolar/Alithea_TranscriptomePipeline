#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse


def generate_plot(input_file):
    """
    Generate a boxplot (if multiple samples) or barplot (if single samples)
    comparing transcript detection in Single-End vs. Paired-End mode.
    """
    # Load transcript counts
    df = pd.read_csv(input_file, sep="\t")

    # Compute total detected transcripts
    total_se = df[df['Mode-End'] == 'Single']['Detected_Transcripts'].sum()
    total_pe = df[df['Mode-End'] == 'Paired']['Detected_Transcripts'].sum()

    # Count number of samples per mode
    num_se_samples = df[df['Mode-End'] == 'Single'].shape[0]
    num_pe_samples = df[df['Mode-End'] == 'Paired'].shape[0]

    plt.figure(figsize=(8, 6))

    if num_se_samples > 1 and num_pe_samples > 1:
        # Use boxplot if we have multiple samples
        sns.boxplot(x='Mode-End', y='Detected_Transcripts', data=df, palette="Set2")
    else:
        # Use barplot if only one sample per mode
        sns.barplot(x='Mode-End', y='Detected_Transcripts', hue='Mode-End', data=df, palette="Set2", legend=False)

    # Formatting
    title_text = (
        f"Comparison of Transcript Detection: SE vs PE\n"
        f"Total SE: {total_se} | Total PE: {total_pe}\n"
        f"Samples - SE: {num_se_samples}, PE: {num_pe_samples}"
    )

    plt.title(title_text, fontsize=12, fontweight="bold")
    plt.xlabel("")
    plt.ylabel("Number of Detected Transcripts")
    plt.grid(axis="y", linestyle="--", alpha=0.7)

    # Save plot
    plt.savefig("se_vs_pe_boxplot.png", dpi=300, bbox_inches="tight")
    print(f"Plot saved to se_vs_pe_boxplot.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate SE vs PE Boxplot or Barplot")
    parser.add_argument("--counts", required=True, help="Input transcript counts file (TSV)")
    args = parser.parse_args()

    generate_plot(args.counts)