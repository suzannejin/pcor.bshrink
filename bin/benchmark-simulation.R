#!/usr/bin/env Rscript

library(argparse)
library(corpcor)
library(data.table)
library(ggplot2)
library(ggpubr)
library(MASS)
library(propr)

# parse arguments
parser = ArgumentParser(description='Benchmark shrinkage')
parser$add_argument('-i', '--input', type='character', help="Input count data")
parser$add_argument('-o', '--outdir', type='character', help="Output directory")
parser$add_argument('--ngene', type='integer', help='Number of genes considered')
parser$add_argument('--ncell', type='integer', help='Number of cells considered')
parser$add_argument('--nsamp', type='integer', default=200, help='Number of samples')
parser$add_argument('--rlib', type='character', help="rlib folder")
parser = parser$parse_args()


# read input files ----------------------------------------------------------------------

count = fread(parser$input)
count = as.matrix(count)

print(dim(count))
print(sum(count==0))

if (!file.exists(parser$outdir)){
    dir.create(parser$outdir, recursive = TRUE)
}

# functions -----------------------------------------------------------------------------

source(paste0(parser$rlib, "/shrink.R"))
source(paste0(parser$rlib, "/mse.R"))
source(paste0(parser$rlib, "/lr.R"))
source(paste0(parser$rlib, "/other.R"))

simulate_lr <- function(count, ncell){
    alr= get_alr(count)
    S  = cov(alr) 
    m  = apply(alr, 2, mean)
    al = mvrnorm(n = ncell, mu=m, Sigma=S)  # alr samples
    P  = exp(al)/(1+apply(exp(al),1,sum))
    P  = cbind(P,1-apply(P,1,sum))          # sampled compositions
    lg = apply(log(P),1,mean)
    cl = log(P)-lg                          # clr samples
    return(list(cl, al))
}


# benchmark -----------------------------------------------------------------------------
df = list()
df[['clr']] = data.frame(mse=numeric(), corr=character(), shrink=character())
df[['alr']] = data.frame(mse=numeric(), corr=character(), shrink=character())
for (i in 1:parser$nsamp){
    
    # sample genes
    gsamp  = sample(1:ncol(count), parser$ngene)
    dat    = count[,gsamp]

    # clr/alr ground truth
    lr_truth = list()
    lr_truth[['clr']] = get_clr(dat)
    lr_truth[['alr']] = get_alr(dat)

    # simulate data
    lr_bench = list()
    lr = simulate_lr(dat, parser$ncell)
    lr_bench[['clr']] = lr[[1]]
    lr_bench[['alr']] = lr[[2]]

    bcor_truth = list(); bcor_bench = list()
    for (transf in c('clr', 'alr')){
        # compute correlation
        bcor_truth[[transf]] = noShrink(lr_truth[[transf]])
        bcor_bench[[transf]] = noShrink(lr_bench[[transf]])
        bcor_bench[[transf]] = c(bcor_bench[[transf]], dShrink(lr_bench[[transf]]))
        bcor_bench[[transf]] = c(bcor_bench[[transf]], bShrink(lr_bench[[transf]], transf, transf))

        # calculate mse
        tmp = calculate_mse(bcor_truth[[transf]], bcor_bench[[transf]])
        for (method in names(tmp)){
            row = data.frame(mse=tmp[[method]], corr=get_cor_name(method), shrink=get_shrink_name(method))
            df[[transf]] = rbind(df[[transf]], row)
        }
    }
}
for (transf in c('clr','alr')){
    out = paste0(parser$outdir, '/mse_', parser$ncell, '_', parser$ngene, '_', parser$nsamp, '_', transf, '.csv')
    write.csv(df[[transf]],out, row.names=F, quote=F)
}