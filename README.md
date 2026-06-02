# Phylogenetic Pipeline for macOS

A complete pipeline for phylogenetic tree construction using IQ-TREE on macOS, including sequence alignment, trimming, model selection, and tree building.

## Overview

This pipeline automates the process of:
1. **Sequence alignment** (using MAFFT)
2. **Alignment trimming** (using trimAl)
3. **Best substitution model selection** (using IQ-TREE ModelFinder)
4. **Phylogenetic tree construction** (using IQ-TREE)
5. **Visualization preparation** (for iTOL)

## Prerequisites

- macOS operating system
- Homebrew (recommended for installation)
- Basic terminal knowledge

## Quick Start

```bash
# Clone the repository
git clone https://github.com/alexander-maldonado-orbe/phylogenetic-pipeline.git
cd phylogenetic-pipeline

# Make scripts executable
chmod +x pipeline.sh scripts/*.sh

# Run the pipeline with your data
./pipeline.sh -i test/test_sequences.fasta -o my_results
```

## Step 1: Installation
Install all dependencies:

### MAFFT (alignment)

### trimAl (trimming)

### IQ-TREE (phylogenetics)

## Step 2: Prepare your sequences
Input file must be in FASTA format.

## Step 3: Run the pipeline
```bash
./pipeline.sh -i your_sequences.fasta -o output_directory
```

