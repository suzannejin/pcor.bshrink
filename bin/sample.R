#!/usr/bin/env Rscript


# This script randomly samples <ngene> genes and parses the input data to
#    1. The ground truth matrix --> [n_nozero_cell x ngene]
#    2. Downsampled matrix with <ncell> cells chosen from the subset of cells that do not contain zeros --> [ncell x ngene]
#    3. Downsampled matrix with <ncell> cells chosen from the full set of cells  -->  [ncell x ngene]


library(argparse)
library(data.table)

# parse arguments
parser = ArgumentParser(description='Parse and sample input data')
parser$add_argument('-i', '--input', type='character', help="Input count data with all cells")
parser$add_argument('-o1', '--output1', type='character', help="Output sample - truth")
parser$add_argument('-o2', '--output2', type='character', help="Output sample - bench with no zero")
parser$add_argument('-o3', '--output3', type='character', help="Output sample - bench with zeros")
parser$add_argument('--ncell', type='integer', nargs='+', help='Number of cells considered')
parser$add_argument('--ngene', type='integer', help='Number of genes considered')
parser = parser$parse_args()


# read input files ----------------------------------------------------------------------

count   = fread(parser$input)
count   = as.matrix(count)

# sample --------------------------------------------------------------------------------

gsamp               = sample(1:ncol(count), parser$ngene)
pos                 = which(rowSums(count==0) == 0)
samp_truth          = count[pos,gsamp]
csamp_nozero        = sample(1:nrow(samp_truth), parser$ncell)
csamp_withzero      = sample(1:nrow(count), parser$ncell)
samp_bench_nozero   = samp_truth[csamp_nozero,]
samp_bench_withzero = count[csamp_withzero,gsamp]

message("sampled to")
print(dim(samp_truth))
print(dim(samp_bench_nozero))
print(dim(samp_bench_withzero))
message("sample with zeros: ", sum(samp_bench_withzero == 0), "[", mean(samp_bench_withzero == 0), "]")

# save sample
fwrite(
    samp_truth, 
    file=parser$output1, 
    quote=F, sep=",", row.names=F, col.names=F, compress="gzip"
    )
fwrite(
    samp_bench_nozero, 
    file=parser$output2, 
    quote=F, sep=",", row.names=F, col.names=F, compress="gzip"
    )
fwrite(
    samp_bench_withzero, 
    file=parser$output3, 
    quote=F, sep=",", row.names=F, col.names=F, compress="gzip"
    )
