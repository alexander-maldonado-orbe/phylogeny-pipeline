#!/bin/bash
# Separate protocols for individual steps
# Usage: ./separate_protocols.sh

# Function to display protocol menu
show_menu() {
    echo "====================================="
    echo "Separate Protocols Menu"
    echo "====================================="
    echo "1. MAFFT Alignment only"
    echo "2. trimAl Trimming only"
    echo "3. IQ-TREE ModelFinder only"
    echo "4. IQ-TREE Tree building only"
    echo "5. Complete pipeline (all steps)"
    echo "6. Show IQ-TREE help"
    echo "7. Exit"
    echo "====================================="
}

# Function for MAFFT alignment
run_mafft() {
    echo "Enter input FASTA file:"
    read INPUT
    echo "Enter output file name:"
    read OUTPUT
    echo "Enter threads (or press Enter for AUTO):"
    read THREADS
    if [ -z "$THREADS" ]; then
        mafft --auto "$INPUT" > "$OUTPUT"
    else
        mafft --auto --thread "$THREADS" "$INPUT" > "$OUTPUT"
    fi
    echo "Alignment complete: $OUTPUT"
}

# Function for trimAl trimming
run_trimal() {
    echo "Enter input alignment file:"
    read INPUT
    echo "Enter output file name:"
    read OUTPUT
    echo "Select trimming method (1: gappyout, 2: automated1, 3: strict, 4: stringent):"
    read METHOD
    case $METHOD in
        1) trimal -in "$INPUT" -out "$OUTPUT" -gappyout ;;
        2) trimal -in "$INPUT" -out "$OUTPUT" -automated1 ;;
        3) trimal -in "$INPUT" -out "$OUTPUT" -strict ;;
        4) trimal -in "$INPUT" -out "$OUTPUT" -stringent ;;
        *) echo "Invalid method" ;;
    esac
    echo "Trimming complete: $OUTPUT"
}

# Function for IQ-TREE ModelFinder
run_modelfinder() {
    echo "Enter alignment file:"
    read INPUT
    echo "Enter threads (or press Enter for AUTO):"
    read THREADS
    if [ -z "$THREADS" ]; then
        iqtree2 -s "$INPUT" -m MF
    else
        iqtree2 -s "$INPUT" -m MF -nt "$THREADS"
    fi
    echo "ModelFinder complete"
}

# Function for IQ-TREE tree building
run_tree_building() {
    echo "Enter alignment file:"
    read INPUT
    echo "Enter model (or press Enter to auto-detect):"
    read MODEL
    echo "Enter bootstrap replicates (default 1000):"
    read BOOTSTRAP
    BOOTSTRAP=${BOOTSTRAP:-1000}
    echo "Enter threads (or press Enter for AUTO):"
    read THREADS
    
    if [ -z "$MODEL" ]; then
        if [ -z "$THREADS" ]; then
            iqtree2 -s "$INPUT" -bb "$BOOTSTRAP"
        else
            iqtree2 -s "$INPUT" -bb "$BOOTSTRAP" -nt "$THREADS"
        fi
    else
        if [ -z "$THREADS" ]; then
            iqtree2 -s "$INPUT" -m "$MODEL" -bb "$BOOTSTRAP"
        else
            iqtree2 -s "$INPUT" -m "$MODEL" -bb "$BOOTSTRAP" -nt "$THREADS"
        fi
    fi
    echo "Tree building complete"
}

# Main loop
while true; do
    show_menu
    read -p "Select option (1-7): " OPTION
    case $OPTION in
        1) run_mafft ;;
        2) run_trimal ;;
        3) run_modelfinder ;;
        4) run_tree_building ;;
        5) 
            echo "Running complete pipeline..."
            echo "Enter input FASTA file:"
            read INPUT
            echo "Enter output directory:"
            read OUTPUT_DIR
            ./pipeline.sh -i "$INPUT" -o "$OUTPUT_DIR"
            ;;
        6)
            export PATH=$PATH:/Applications/iqtree-2.4.0-macOS/bin
            iqtree2 -h
            ;;
        7) 
            echo "Exiting..."
            exit 0
            ;;
        *) echo "Invalid option" ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
