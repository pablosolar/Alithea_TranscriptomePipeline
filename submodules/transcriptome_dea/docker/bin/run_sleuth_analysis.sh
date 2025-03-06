#!/bin/bash

# Generate metadata for Sleuth
echo "Generating metadata file for Sleuth"
mkdir -p transcriptome_dea  # Create directory to store the output

# Define metadata output path INSIDE the container
METADATA_FILE="/scripts/sleuth_metadata.tsv"

# Initialize metadata file with headers
echo -e "sample\tcondition\tpath" > "$METADATA_FILE"

# Process all abundance.h5 files passed to the script (passed as arguments)
for file in "$@"; do
    SAMPLE=$(basename "$file" | sed 's/_abundance.h5//')

    # Detect condition based on sample name
    if echo "$SAMPLE" | grep -iq "untreated"; then
        CONDITION="untreated"
    elif echo "$SAMPLE" | grep -iq "treated"; then
        CONDITION="treated"
    else
        echo "⚠WARNING: Could not determine condition for $SAMPLE, defaulting to 'unknown'"
        CONDITION="unknown"
    fi

    ABS_PATH=$(realpath "$file")  # Get absolute path
    echo -e "$SAMPLE\t$CONDITION\t$ABS_PATH" >> "$METADATA_FILE"

    # Debugging step
    echo "Assigned condition: $SAMPLE -> $CONDITION"
done

echo "Metadata file created at: $METADATA_FILE"
ls -lh "$METADATA_FILE"  # Debugging step

# Run Sleuth analysis with correct path
if [ -s "$METADATA_FILE" ]; then
    echo "Running Sleuth analysis..."
    Rscript /scripts/sleuth_dea.R "$METADATA_FILE"
else
    echo "Skipping DEA: No valid input files found."
fi