#!/bin/bash
# Alignment and trimming script

# Usage: ./align_and_trim.sh <input_fasta> <output_dir> [threads]

INPUT_FASTA=$1
OUTPUT_DIR=$2
THREADS=${3:-AUTO}

if [ -z "$INPUT_FASTA" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <input_fasta> <output_dir> [threads]"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Alignment
echo "Aligning sequences..."
ALIGNED="$OUTPUT_DIR/aligned.fasta"
mafft --auto --thread $THREADS "$INPUT_FASTA" > "$ALIGNED"

# Trimming
echo "Trimming alignment..."
TRIMMED="$OUTPUT_DIR/aligned_trimmed.fasta"
trimal -in "$ALIGNED" -out "$TRIMMED" -automated1

echo "Alignment and trimming complete!"
echo "Aligned: $ALIGNED"
echo "Trimmed: $TRIMMED"
