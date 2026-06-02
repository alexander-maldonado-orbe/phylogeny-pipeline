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
**Option 1: Homebrew**/
Open your Terminal and run the following command:
```bash
brew install mafft
```
**Alternative Installation Methods**
If you do not use Homebrew, you can use these other options depending on your system setup:
**Option 2: Conda or Mamba**
If you work with bioinformatics pipelines and use a conda environment (such as Miniconda or Anaconda):
```bash
conda install -c conda-forge mafft
```
**Option 3: MacPorts**
If you have MacPorts installed on your system:
```bash
sudo port install mafft
```
Test the installation by checking the version:
```bash
mafft -h
```

### trimAl (trimming)
**Option 1: Homebrew**
Open your Terminal and run the following command:
```bash
brew install trimal
```
**Option 2: Conda or Mamba**
```bash
conda install bioconda::trimal
```
Test the installation by checking the version:
```bash
trimal -v
```

### IQ-TREE (phylogenetics)
**Option 1: Homebrew**
Open your Terminal and run the following command:
```bash
brew install brewsci/bio/iqtree3
```
**Option 2: MacPorts**
```bash
sudo port install iqtree2
```
Test the installation by checking the version:
```bash
iqtree -version
```
**Option 3: Manual Download & Installation**
- If you prefer not to use a package manager:Go to the IQ-TREE GitHub Releases page (https://iqtree.github.io/doc/Quickstart).
- Download the latest macOS .zip file.
- Unzip the file.
- You will find the iqtree executable inside the extracted bin folder.
- Move the iqtree executable to a folder in your system path, or run it directly from the folder by navigating to it in your Terminal
- Open the Terminal.
- Go into IQ-TREE folder by entering (assuming you downloaded version 1.5.0) (assuming that IQ-TREE was downloaded into Downloads folder).
```bash
 cd Downloads/iqtree-1.5.0-MacOSX
```

## Step 2: Prepare your sequences
Input file must be in FASTA format.

## Step 3: Run the pipeline
```bash
./pipeline.sh -i your_sequences.fasta -o output_directory
```
## Step 4: Visualize results
Upload the final tree file (output_directory/final_tree.nwk) to iTOL (https://itol.embl.de/).

## Output Files
- alignment.fasta: Multiple sequence alignment
- alignment_trimmed.fasta: Trimmed alignment
- best_model.txt: Best substitution model selected
- treefile.nwk: Final phylogenetic tree (Newick format)
- iqtree.log: Complete IQ-TREE log file
- final_tree.nwk: Renamed final tree for iTOL

## Separate protocol
### MAFFT (alignment)
```bash
mafft --auto /path/to/your/input.fasta > /path/to/your/output.fasta
```

### trimAl (trimming)
```bash
trimal -in your_alignment.fasta -out trimmed_alignment.fasta -gappyout
```

### IQ-TREE (phylogenetics)
Start IQTREE ((assuming you downloaded version 2.4.0))
```bash
export PATH=$PATH:/Applications/iqtree-2.4.0-macOS/bin
iqtree2
```




## Testing
Run the test pipeline:
```bash
./pipeline.sh -i test/test_sequences.fasta -o test_output
```

## Citation
If you use this pipeline, please cite:
- IQ-TREE: Minh et al. (2020) Mol. Biol. Evol.
- MAFFT: Katoh & Standley (2013) Mol. Biol. Evol.
- trimAl: Capella-Gutiérrez et al. (2009) Bioinformatics
