# Load necessary libraries
library(sleuth)
library(dplyr)
library(ggplot2)

# Debugging: Print command-line arguments
args <- commandArgs(trailingOnly = TRUE)
print("Command-line arguments received:")
print(args)

# Ensure an argument was passed
if (length(args) < 1) {
  stop("Error: No metadata file provided!")
}

# Extract metadata file path
metadata_file <- args[1]

# Debugging: Print metadata file path
print(paste("Reading metadata file:", metadata_file))

# Check if metadata file exists
if (!file.exists(metadata_file)) {
  stop(paste("Error: Metadata file does not exist:", metadata_file))
}

# Read metadata
metadata <- read.table(metadata_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
print("Metadata loaded successfully:")
print(metadata)

# Ensure metadata has the expected columns
if (!all(c("sample", "condition", "path") %in% colnames(metadata))) {
  stop("Error: Metadata file must have 'sample', 'condition', and 'path' columns.")
}

# Save metadata for tracking
metadata_output <- "sleuth_metadata.tsv"
write.table(metadata, file = metadata_output, sep = "\t", quote = FALSE, row.names = FALSE)
print(paste("Saved metadata to:", metadata_output))

# **Perform Transcript-Level Analysis**
print("Initializing Sleuth object for transcript-level analysis...")
so <- sleuth_prep(metadata, full_model = ~condition, extra_bootstrap_summary = TRUE)

# Fit full and reduced models
print("Fitting models for differential expression analysis...")
so <- sleuth_fit(so, formula = ~condition, fit_name = "full")
so <- sleuth_fit(so, formula = ~1, fit_name = "reduced")

# Perform likelihood ratio test (LRT) for differential expression
print("Performing likelihood ratio test (LRT)...")
so <- sleuth_lrt(so, "reduced", "full")

# Extract and save LRT results
print("Extracting transcript-level differential expression results (LRT)...")
lrt_results <- sleuth_results(so,	'reduced:full',	'lrt',show_all=FALSE)
lrt_results_output <- "sleuth_lrt_results.tsv"
write.table(lrt_results, file = lrt_results_output, sep = "\t", quote = FALSE, row.names = FALSE)
print(paste("Saved LRT results to:", lrt_results_output))

# Perform Wald test for pairwise comparisons
print("Performing Wald test...")
so <- sleuth_wt(so, which_beta = "conditionuntreated", which_model = "full")

# Extract and save Wald test results
print("Extracting transcript-level differential expression results (Wald test)...")
sleuth_wald_results <- sleuth_results(so, "conditionuntreated", test_type = "wt", show_all = FALSE)

# Ensure `%>%` works by explicitly loading dplyr
print("Sorting Wald test results...")
sleuth_wald_results_sorted <- sleuth_wald_results %>%
  arrange(qval, desc(abs(b)))

wald_results_output <- "sleuth_wald_results.tsv"
write.table(sleuth_wald_results_sorted, file = wald_results_output, sep = "\t", quote = FALSE, row.names = FALSE)
print(paste("Saved Wald results to:", wald_results_output))

# **Exploratory Analyses and Save Plots**
print("Generating PCA plot...")
pca_plot <- plot_pca(so, color_by = 'condition', text_labels = TRUE)
ggsave("pca_plot.png", plot = pca_plot)
print("Saved PCA plot to: pca_plot.png")

print("Generating sample heatmap...")
heatmap_plot <- plot_sample_heatmap(so)
ggsave("heatmap_plot.png", plot = heatmap_plot)
print("Saved heatmap plot to: heatmap_plot.png")

# **Expression heatmap for top significant transcripts**
print("Generating transcript expression heatmap...")
top_n <- min(nrow(sleuth_wald_results_sorted), 40)  # Select up to 40 transcripts

# **Transcript Heatmap for Significant Transcripts**
print("Filtering and sorting significant transcripts for heatmap...")
sig_transcripts <- sleuth_wald_results_sorted %>%
  filter(qval < 0.05) %>%
  arrange(qval, desc(abs(b)))

top_n_transcripts <- min(nrow(sig_transcripts), top_n)  # Avoid indexing errors

if (top_n_transcripts > 0) {
  print(paste("Plotting heatmap for top", top_n_transcripts, "significant transcripts..."))
  transcript_heatmap_plot <- plot_transcript_heatmap(so, transcripts = sig_transcripts$target_id[1:top_n_transcripts])
  ggsave("transcript_heatmap_plot.png", plot = transcript_heatmap_plot)
  print("Saved transcript heatmap plot to: transcript_heatmap_plot.png")
} else {
  print("No significant transcripts found. Skipping transcript heatmap.")
}

# **Bootstrap Variation for the Most Significant Transcript**
print("Checking bootstrap values for significant transcripts...")

if (!is.null(so$bs_quants) && length(so$bs_quants) > 0) {

  valid_transcripts <- sig_transcripts$target_id[
    sig_transcripts$target_id %in% rownames(so$bs_quants[[1]]$est_counts)
  ]

  print(paste("Found", length(valid_transcripts), "valid transcripts with bootstrap estimates."))

  if (length(valid_transcripts) > 0) {
    most_sig_transcript <- valid_transcripts[1]  # Select first valid transcript
    print(paste("Using transcript for bootstrap plot:", most_sig_transcript))

    bootstrap_plot <- plot_bootstrap(so, target_id = most_sig_transcript, units = "est_counts", color_by = "condition")
    ggsave("bootstrap_plot.png", plot = bootstrap_plot)
    print("Saved bootstrap plot to: bootstrap_plot.png")
  } else {
    print("No significant transcripts with bootstraps found. Skipping bootstrap plot.")
  }

} else {
  print("No bootstraps found in `so$bs_quants`. Skipping bootstrap analysis.")
}
print("Analysis complete. Output files: sleuth_lrt_results.tsv, sleuth_wald_results.tsv, pca_plot.png, heatmap_plot.png, transcript_heatmap_plot.png, bootstrap_plot.png")