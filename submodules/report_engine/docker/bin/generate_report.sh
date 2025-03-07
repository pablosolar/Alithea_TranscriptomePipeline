#!/bin/bash

#!/bin/bash

echo $@

# Initialize arguments list with required parameters
args="--index-info ${1} --transcriptome-counts ${2}"

# Check Single-End files
if [[ -n "${4}" ]]; then
    args+=" --se-metadata ${4}"
    args+=" --se-lrt-results ${5}"
    args+=" --se-wald-results ${6}"
    args+=" --se-pca ${7}"
    args+=" --se-heatmap ${8}"
    args+=" --se-transcript-heatmap ${9}"
    args+=" --se-bootstrap ${10}"
fi

# Ceeck Paired-End files
if [[ -n "${11}" ]]; then
    args+=" --pe-metadata ${11}"
    args+=" --pe-lrt-results ${12}"
    args+=" --pe-wald-results ${13}"
    args+=" --pe-pca ${14}"
    args+=" --pe-heatmap ${15}"
    args+=" --pe-transcript-heatmap ${16}"
    args+=" --pe-bootstrap ${17}"
fi

# Check if SE and PE exist appending boxplot
if [[ -n "${4}" && -n "${11}" ]]; then
    args+=" --boxplot ${3}"
fi

# Debugging: print final args
echo "Final args: $args"

# Run the Python script
python3 /bin/generate_report.py $args
