# BayesPrism has a built in function to run NMF and try and find distinct transcriptional
# programs within the cancer fraction, once the stromal fraction has been computationally
# removed. Once you've decided on a value of k using choose_k_for_embeddings.R, this
# script runs NMF and plots the expression of each transcriptional program across each
# sample. This is based off the BayesPrism tutorial:
# https://github.com/Danko-Lab/BayesPrism/blob/main/tutorial_embedding_learning.html

suppressPackageStartupMessages({
  library(data.table)
  library(SingleCellExperiment)
  library(dplyr)
  library(curatedOvarianData)
  library(yaml)
  library(stringr)
  library(ggplot2)
  library(ggrepel)
  library(BayesPrism)
})


params <- read_yaml("../../config.yml")
data_path <- params$data_path
local_data_path <- params$local_data_path
plot_path <- params$plot_path

# Current options for dataset are TCGA (for RNA-seq), microarray, and tothill
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 2) {
  print(args)
  dataset <- args[1]
  k <- as.integer(args[2])
} else {
  stop("Need to input a dataset and a number of latent factors k")
}

# Load bayesprism object
bp <- readRDS(paste(local_data_path, "/deconvolution_output/", dataset,
                    "_default_bayesprism_results_full.rds", sep = ""))

# BP function to run embeddings, this is the part that takes ~1 day
ebd.res <- learn.embedding.nmf(bp = bp, K = k, cycle = 40)

# Save data
embedding_file <- paste(local_data_path, "/embeddings/", dataset,
                        "_k", k, "_embeddings.rds", sep = "")
saveRDS(ebd.res, embedding_file)

weights <- ebd.res$omega
weights_file <- paste(local_data_path, "/embeddings/", dataset,
                      "_k", k, "_program_weights.tsv", sep = "")
write.table(weights, weights_file, sep = "\t", quote = FALSE)
