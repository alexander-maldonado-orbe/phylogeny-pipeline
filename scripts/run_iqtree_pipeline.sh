#!/bin/bash
# Individual IQ-TREE pipeline steps

# Usage: ./run_iqtree_pipeline.sh <fasta_file> [threads]

FASTA_FILE=$1
THREADS=${2:-AUTO}

if [ -z "$FASTA_FILE" ]; then
    echo "Usage: $0 <fasta_file> [threads]"
    exit 1
fi

# Step 1: Run ModelFinder
echo "Running ModelFinder on $FASTA_FILE..."
iqtree2 -s "$FASTA_FILE" -m MF -nt $THREADS -redo

# Extract best model
BASENAME=$(basename "$FASTA_FILE" .fasta)
BEST_MODEL=$(grep "Best-fit model" ${BASENAME}.fasta.iqtree | awk -F': ' '{print $2}' | sed 's/ chosen according to BIC//')
echo "Best model: $BEST_MODEL"

# Step 2: Build tree with best model
echo "Building phylogenetic tree with $BEST_MODEL..."
iqtree2 -s "$FASTA_FILE" -m "$BEST_MODEL" -nt $THREADS -bb 1000 -redo

# Step 3: Create iTOL-ready file
cp "${BASENAME}.fasta.treefile" "final_${BASENAME}.nwk"
echo "Tree file ready: final_${BASENAME}.nwk"

echo "Pipeline complete! Check these files:"
echo "  - ${BASENAME}.fasta.iqtree (model and tree info)"
echo "  - final_${BASENAME}.nwk (tree for iTOL)"
