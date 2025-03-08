#!/bin/bash

# Ensure at least two arguments are provided (files + prefix)
if [ "$#" -lt 2 ]; then
    echo "Error: No input files or missing prefix. Provide .h5 files and a prefix (se/pe)."
    exit 1
fi

# Extract prefix from the last argument
TYPE="${!#}"  # Last argument (should be "se" or "pe")
FILES=("${@:1:$#-1}")  # All arguments except the last one (the files)

# Ensure prefix is valid
if [[ "$TYPE" != "se" && "$TYPE" != "pe" ]]; then
    echo "Error: Invalid prefix '$TYPE'. Expected 'se' or 'pe'."
    exit 1
fi

# Define metadata file path (with prefix)
METADATA_FILE="/scripts/${TYPE}_sleuth_metadata.tsv"

# Initialize metadata file with headers
echo -e "sample\tcondition\tpath" > "$METADATA_FILE"

# Sort files by sample name
IFS=$'\n' sorted_files=($(printf "%s\n" "${FILES[@]}" | sort -k1,1))
unset IFS

# Process sorted files
for file in "${sorted_files[@]}"; do
    SAMPLE=$(basename "$file" | sed 's/_abundance.h5//')

    # Detect condition
    if echo "$SAMPLE" | grep -iq "untreated"; then
        CONDITION="untreated"
    elif echo "$SAMPLE" | grep -iq "treated"; then
        CONDITION="treated"
    else
        echo "Warning: Could not determine condition for $SAMPLE, defaulting to 'unknown'"
        CONDITION="unknown"
    fi

    # Get absolute path
    ABS_PATH=$(realpath "$file")

    # Append to metadata file
    echo -e "$SAMPLE\t$CONDITION\t$ABS_PATH" >> "$METADATA_FILE"

    # Debugging step
    echo "Assigned condition: $SAMPLE -> $CONDITION"
done

# Sort metadata by condition and sample name, ensuring the header remains
{
    head -n 1 "$METADATA_FILE"  # Keep the header
    tail -n +2 "$METADATA_FILE" | sort -k2,2 -k1,1  # Sort the rest
} > tmp_metadata.tsv
mv tmp_metadata.tsv "$METADATA_FILE"

echo "Metadata file:"
cat "$METADATA_FILE"

echo "Metadata file created at: $METADATA_FILE"
ls -lh "$METADATA_FILE"  # Debugging step

# Run Sleuth analysis with metadata file and dataset type (SE/PE)
echo "Running Sleuth analysis..."
Rscript /scripts/sleuth_dea.R "$METADATA_FILE" "$TYPE"

echo "Sleuth analysis complete!"