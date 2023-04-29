#!/usr/bin/env Rscript

library(argparse)
library(corpcor)
library(data.table)


# parse arguments
parser = ArgumentParser(description='Benchmark shrinkage and imputation')
parser$add_argument('-i1', '--input1', type='character', help="Input sample count data - truth")
parser$add_argument('-i2', '--input2', type='character', help="Input sample count data - bench")
parser$add_argument('-o', '--output', type='character', help="Output mse")
parser$add_argument('--transf', type='character', help='clr or alr')
parser$add_argument('--rlib', type='character', default='./rlib', help="Directory to local r helper functions")
parser = parser$parse_args()


# load local functions
source(paste0(parser$rlib, "/shrink.R"))
source(paste0(parser$rlib, "/mse.R"))
source(paste0(parser$rlib, "/lr.R"))
source(paste0(parser$rlib, "/other.R"))


# read input count data -----------------------------------------------------------------

# count data
count_truth = as.matrix(fread(parser$input1))
count_bench = as.matrix(fread(parser$input2))

# log ratio
lr_truth = get_lr(count_truth, transf=parser$transf)
lr_bench = get_lr(count_bench, transf=parser$transf)

print(dim(count_truth))
print(dim(count_bench))


# benchmark -----------------------------------------------------------------------------

# ground truth
bcor_truth = noShrink(lr_truth)

# without shrinkage
bcor_bench = noShrink(lr_bench)

# direct shrinkage on clr/alr covariance matrix
bcor_bench = c(bcor_bench, dShrink(lr_bench))

# basis shrinkage
bcor_bench = c(bcor_bench, bShrink(log(count_bench/rowSums(count_bench)), 'logp', parser$transf))

# calculate mse
tmp = calculate_mse(bcor_truth, bcor_bench)

# organize and save output data frame
df = data.frame(mse=numeric(), corr=character(), shrink=character())
for (method in names(tmp)){
    row = data.frame(mse=tmp[[method]], corr=get_cor_name(method), shrink=get_shrink_name(method))
    df  = rbind(df, row)
}
write.csv(df, parser$output, row.names=F, quote=F)
