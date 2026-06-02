#!/bin/bash
# Phylogenetic Pipeline - Ultrafast Bootstrap with SH-aLRT and aBayes
# Reference: iqtree2 -s alignment.fasta -m TNe+I+R3 -bb 20000 -nt AUTO -alrt 20000 -abayes -redo

set -e

# Default values
INPUT_FILE=""
OUTPUT_DIR="results_$(date +%Y%m%d_%H%M%S)"
THREADS="AUTO"
TRIMMING_METHOD="gappyout"
BOOTSTRAP_REPLICATES=10000
ALRT_REPLICATES=10000
USE_ABAYES=true
MODEL="AUTO"
REDO_FLAG=""
IQTREE_PATH="/Applications/iqtree-2.4.0-macOS/bin"

# Function to display help
show_help() {
    cat << EOF
Phylogenetic Pipeline - Ultrafast Bootstrap with SH-aLRT and aBayes
================================================================

Usage: $0 -i INPUT_FILE [OPTIONS]

REQUIRED:
    -i | --input      Input FASTA file

OPTIONS:
    -o | --output     Output directory (default: results_timestamp)
    -t | --threads    Number of threads (default: AUTO)
    -m | --trim       Trimming method: gappyout, automated1, strict, stringent (default: gappyout)
    -b | --bootstrap  Bootstrap replicates (default: 20000)
    -a | --alrt       SH-aLRT replicates (default: 20000)
    --no-abayes       Disable aBayes test (enabled by default)
    -f | --force      Force redo analysis (overwrite existing files)
    -h | --help       Show this help message

EXAMPLE:
    ./pipeline.sh -i test.fasta -o my_analysis -t 4 -b 20000

OUTPUT FILES:
    - final_tree.nwk                 : Tree with bootstrap values (ready for iTOL)
    - trimmed_alignment.fasta.contree: Consensus tree with bootstrap supports
    - trimmed_alignment.fasta.treefile: Maximum likelihood tree
    - trimmed_alignment.fasta.iqtree : IQ-TREE report file
    - best_model.txt                 : Best substitution model
    - summary_report.txt             : Analysis summary
    - pipeline.log                   : Complete execution log

CITATION:
    If you use this pipeline, please cite:
    - IQ-TREE: Minh et al. (2020) Mol. Biol. Evol.
    - MAFFT: Katoh & Standley (2013) Mol. Biol. Evol.
    - trimAl: Capella-Gutiérrez et al. (2009) Bioinformatics
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input) INPUT_FILE="$2"; shift 2 ;;
        -o|--output) OUTPUT_DIR="$2"; shift 2 ;;
        -t|--threads) THREADS="$2"; shift 2 ;;
        -m|--trim) TRIMMING_METHOD="$2"; shift 2 ;;
        -b|--bootstrap) BOOTSTRAP_REPLICATES="$2"; shift 2 ;;
        -a|--alrt) ALRT_REPLICATES="$2"; shift 2 ;;
        --no-abayes) USE_ABAYES=false; shift ;;
        -f|--force) REDO_FLAG="-redo"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Error: Unknown option $1"; show_help; exit 1 ;;
    esac
done

# Validate input
if [ -z "$INPUT_FILE" ]; then
    echo "Error: Input file is required"
    show_help
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Validate trimming method
case $TRIMMING_METHOD in
    gappyout|automated1|strict|stringent)
        ;;
    *)
        echo "Error: Invalid trimming method. Use: gappyout, automated1, strict, or stringent"
        exit 1
        ;;
esac

# Create output directory
mkdir -p "$OUTPUT_DIR"
export PATH=$PATH:$IQTREE_PATH

# Setup logging
LOG_FILE="$OUTPUT_DIR/pipeline.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "====================================="
echo "Phylogenetic Pipeline Starting"
echo "====================================="
echo "Input file: $INPUT_FILE"
echo "Output directory: $OUTPUT_DIR"
echo "Threads: $THREADS"
echo "Trimming method: $TRIMMING_METHOD"
echo "Bootstrap replicates: $BOOTSTRAP_REPLICATES"
echo "SH-aLRT replicates: $ALRT_REPLICATES"
echo "aBayes test: $USE_ABAYES"
echo "Start time: $(date)"
echo "====================================="

# Step 1: MAFFT Alignment
echo ""
echo "Step 1: Multiple sequence alignment with MAFFT"
ALIGNED="$OUTPUT_DIR/aligned.fasta"

if [ "$THREADS" == "AUTO" ]; then
    mafft --auto "$INPUT_FILE" > "$ALIGNED"
else
    mafft --auto --thread "$THREADS" "$INPUT_FILE" > "$ALIGNED"
fi

if [ -f "$ALIGNED" ] && [ -s "$ALIGNED" ]; then
    echo "✓ Alignment complete: $ALIGNED"
else
    echo "✗ Error: Alignment failed"
    exit 1
fi

# Step 2: trimAl Trimming
echo ""
echo "Step 2: Alignment trimming with trimAl"
TRIMMED="$OUTPUT_DIR/trimmed_alignment.fasta"
trimal -in "$ALIGNED" -out "$TRIMMED" -$TRIMMING_METHOD

if [ -f "$TRIMMED" ] && [ -s "$TRIMMED" ]; then
    echo "✓ Trimming complete: $TRIMMED"
else
    echo "✗ Error: Trimming failed"
    exit 1
fi

# Step 3: IQ-TREE Phylogenetic Analysis
echo ""
echo "Step 3: Phylogenetic analysis with IQ-TREE"
cd "$OUTPUT_DIR"

# Build IQ-TREE command
IQTREE_CMD="iqtree2 -s trimmed_alignment.fasta -nt $THREADS $REDO_FLAG"

if [ "$MODEL" = "AUTO" ]; then
    IQTREE_CMD="$IQTREE_CMD -m MFP"
else
    IQTREE_CMD="$IQTREE_CMD -m $MODEL"
fi

IQTREE_CMD="$IQTREE_CMD -bb $BOOTSTRAP_REPLICATES"
IQTREE_CMD="$IQTREE_CMD -alrt $ALRT_REPLICATES"

if [ "$USE_ABAYES" = true ]; then
    IQTREE_CMD="$IQTREE_CMD -abayes"
fi

echo "Executing: $IQTREE_CMD"
eval $IQTREE_CMD

if [ -f "trimmed_alignment.fasta.iqtree" ]; then
    echo "✓ IQ-TREE analysis complete"
else
    echo "✗ Error: IQ-TREE analysis failed"
    exit 1
fi

# Extract best model
BEST_MODEL=$(grep "Best-fit model" trimmed_alignment.fasta.iqtree | head -1 | sed 's/.*: //' | sed 's/ chosen.*//')
echo "✓ Best substitution model: $BEST_MODEL"
echo "$BEST_MODEL" > best_model.txt

# Step 4: Prepare final tree for iTOL
echo ""
echo "Step 4: Preparing final tree for iTOL visualization"

if [ -f "trimmed_alignment.fasta.contree" ]; then
    cp trimmed_alignment.fasta.contree final_tree.nwk
    echo "✓ Using consensus tree with bootstrap values (.contree)"
elif [ -f "trimmed_alignment.fasta.treefile" ]; then
    cp trimmed_alignment.fasta.treefile final_tree.nwk
    echo "✓ Using maximum likelihood tree (.treefile)"
else
    echo "✗ Error: No tree file found"
    ls -la
    exit 1
fi

echo "✓ Final tree saved: final_tree.nwk"

# Step 5: Generate summary report
echo ""
echo "Step 5: Generating analysis summary"

SEQ_COUNT=$(grep -c "^>" trimmed_alignment.fasta 2>/dev/null || echo "N/A")
ALIGN_LEN=$(awk '!/^>/ {print length($0); exit}' trimmed_alignment.fasta 2>/dev/null || echo "N/A")

cat > summary_report.txt << EOF
PHYLOGENETIC PIPELINE SUMMARY REPORT
=====================================
Analysis date: $(date)
Input file: $INPUT_FILE
Output directory: $OUTPUT_DIR

Parameters:
  - Threads: $THREADS
  - Trimming method: $TRIMMING_METHOD
  - Bootstrap replicates: $BOOTSTRAP_REPLICATES
  - SH-aLRT replicates: $ALRT_REPLICATES
  - aBayes test: $USE_ABAYES

Results:
  - Best substitution model: $BEST_MODEL
  - Number of sequences: $SEQ_COUNT
  - Alignment length (trimmed): $ALIGN_LEN

Output files:
  - final_tree.nwk: Tree with bootstrap values (for iTOL)
  - trimmed_alignment.fasta.contree: Consensus tree with bootstrap supports
  - trimmed_alignment.fasta.treefile: Maximum likelihood tree
  - trimmed_alignment.fasta.iqtree: IQ-TREE report
  - best_model.txt: Best substitution model
  - pipeline.log: Complete execution log

Command executed:
$IQTREE_CMD

Visualization instructions:
  1. Open https://itol.embl.de/ in your browser
  2. Upload $OUTPUT_DIR/final_tree.nwk
  3. Bootstrap values will appear as branch supports
  4. Customize tree appearance as desired
EOF

echo "✓ Summary report saved: summary_report.txt"

cd - > /dev/null

echo ""
echo "====================================="
echo "Pipeline Completed Successfully"
echo "====================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Key output files:"
echo "  - final_tree.nwk: Tree with bootstrap values (upload to iTOL)"
echo "  - trimmed_alignment.fasta.iqtree: Complete IQ-TREE report"
echo "  - best_model.txt: Best substitution model"
echo "  - summary_report.txt: Analysis summary"
echo "  - pipeline.log: Full execution log"
echo ""
echo "Visualize your tree:"
echo "  1. Go to https://itol.embl.de/"
echo "  2. Upload $OUTPUT_DIR/final_tree.nwk"
echo "  3. Explore bootstrap supports on branches"
echo ""
echo "End time: $(date)"
echo "====================================="