# ============================================================
# Differential Expression Analysis using Sleuth
# ============================================================
# This script performs:
# - PCA Plot with fixed axis orientation while preserving Sleuth's style
# - Differential Expression Analysis using Wald & LRT tests
# - Heatmaps, Bootstrap, Sample & PCA Plots
# - Ensures all required outputs for Nextflow are created
# ============================================================

# Load necessary libraries
library(sleuth)
library(dplyr)
library(ggplot2)

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Ensure correct number of arguments are provided
if (length(args) < 2) {
  stop("Error: Metadata file and dataset type (se/pe) must be provided!")
}

# Extract metadata file and dataset type (se/pe)
metadata_file <- args[1]
dataset_type <- args[2]

# Check if metadata file exists
if (!file.exists(metadata_file)) {
  stop(paste("Error: Metadata file does not exist:", metadata_file))
}

# Read metadata
metadata <- read.table(metadata_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# Validate metadata structure
if (!all(c("sample", "condition", "path") %in% colnames(metadata))) {
  stop("Error: Metadata file must have 'sample', 'condition', and 'path' columns.")
}

# Save metadata for tracking
metadata_output <- paste0(dataset_type, "_sleuth_metadata.tsv")
write.table(metadata, file = metadata_output, sep = "\t", quote = FALSE, row.names = FALSE)

# Initialize Sleuth analysis
so <- sleuth_prep(metadata, full_model = ~condition, extra_bootstrap_summary = TRUE)

# Fit full and reduced models
so <- sleuth_fit(so, formula = ~condition, fit_name = "full")
so <- sleuth_fit(so, formula = ~1, fit_name = "reduced")

# Perform Likelihood Ratio Test (LRT)
so <- sleuth_lrt(so, "reduced", "full")

# Extract and save LRT results
lrt_results <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
lrt_results_output <- paste0(dataset_type, "_sleuth_lrt_results.tsv")
write.table(lrt_results, file = lrt_results_output, sep = "\t", quote = FALSE, row.names = FALSE)

# Perform Wald test
so <- sleuth_wt(so, which_beta = "conditionuntreated", which_model = "full")

# Extract and save Wald test results
sleuth_wald_results <- sleuth_results(so, "conditionuntreated", test_type = "wt", show_all = FALSE)
sleuth_wald_results_sorted <- sleuth_wald_results %>%
  arrange(qval, desc(abs(b)))

wald_results_output <- paste0(dataset_type, "_sleuth_wald_results.tsv")
write.table(sleuth_wald_results_sorted, file = wald_results_output, sep = "\t", quote = FALSE, row.names = FALSE)

# PCA Plot
print("Generating PCA plot...")
pca_plot <- plot_pca(so, color_by = 'condition', text_labels = TRUE)
ggsave(paste0(dataset_type, "_pca_plot.png"), plot = pca_plot)
print("Saved PCA plot to: pca_plot.png")

# Sample Heatmap
heatmap_plot <- plot_sample_heatmap(so)
ggsave(paste0(dataset_type, "_heatmap_plot.png"), plot = heatmap_plot)

# Transcript Heatmaps
sig_transcripts <- sleuth_wald_results_sorted %>%
  filter(qval < 0.05) %>%
  arrange(qval, desc(abs(b)))

top_n_transcripts <- min(nrow(sig_transcripts), 40)
if (top_n_transcripts > 0) {
  transcript_heatmap_plot <- plot_transcript_heatmap(so, transcripts = sig_transcripts$target_id[1:top_n_transcripts])
  ggsave(paste0(dataset_type, "_transcript_heatmap_plot.png"), plot = transcript_heatmap_plot)
} else {
  print("No significant transcripts found. Skipping transcript heatmap.")
}

# Bootstrap Plot
bootstrap_results_output <- paste0(dataset_type, "_bootstrap_plot.png")

if (!is.null(so$bs_quants) && length(so$bs_quants) > 0) {
  valid_transcripts <- sig_transcripts$target_id[
    sig_transcripts$target_id %in% rownames(so$bs_quants[[1]]$est_counts)
  ]

  if (length(valid_transcripts) > 0) {
    most_sig_transcript <- valid_transcripts[1]
    bootstrap_plot <- plot_bootstrap(so, target_id = most_sig_transcript, units = "est_counts", color_by = "condition")
    ggsave(bootstrap_results_output, plot = bootstrap_plot)
  }
}

# ============================================================
# Final Output Summary
# ============================================================

output_files <- list(
  metadata_output,
  lrt_results_output,
  wald_results_output,
  paste0(dataset_type, "_pca_plot.png"),
  paste0(dataset_type, "_heatmap_plot.png"),
  paste0(dataset_type, "_transcript_heatmap_plot.png"),
  bootstrap_results_output
)

print("Analysis complete. Outputs generated:")
print(output_files)