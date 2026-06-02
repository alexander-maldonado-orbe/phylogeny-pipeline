#!/usr/bin/env Rscript
# R script to prepare tree for iTOL visualization

# Usage: Rscript visualize_itol.R <tree_file.nwk> [output_prefix]

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
    stop("Usage: Rscript visualize_itol.R <tree_file.nwk> [output_prefix]")
}

tree_file <- args[1]
output_prefix <- ifelse(length(args) >= 2, args[2], "itol_ready")

# Check if required packages are installed
if (!require("ape", quietly = TRUE)) {
    install.packages("ape", repos = "https://cloud.r-project.org")
    library(ape)
}

if (!require("phytools", quietly = TRUE)) {
    install.packages("phytools", repos = "https://cloud.r-project.org")
    library(phytools)
}

# Read tree
tree <- read.tree(tree_file)

cat("Tree loaded successfully!\n")
cat("Number of tips:", length(tree$tip.label), "\n")
cat("Number of nodes:", tree$Nnode, "\n")

# Create iTOL annotation file
annotation_file <- paste0(output_prefix, "_itol_annotations.txt")

# Write annotation template
writeLines(c(
    "LABELS",
    "SEPARATOR TAB",
    "DATASET_COLORSTRIP",
    "COLOR\t#ff0000",
    paste0("TREE\t", tree_file),
    "DATA"
), annotation_file)

cat("\nAnnotation template created:", annotation_file, "\n")
cat("\nTo visualize in iTOL:\n")
cat("1. Go to https://itol.embl.de/\n")
cat("2. Upload", tree_file, "\n")
cat("3. Drag and drop", annotation_file, "for annotations\n")
