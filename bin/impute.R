#!/usr/bin/env Rscript

library(argparse)
library(data.table)

# parse arguments
parser = ArgumentParser(description='Impute zeros from count data')
parser$add_argument('-i', '--input', type='character', help="Input count data")
parser$add_argument('-o', '--output', type='character', help="Output imputed count data")
parser$add_argument('--method', type='character', help="Imputation method. Choices = [CZM, GBM, lrSVD, freqshrink]")
parser = parser$parse_args()


# read input files ----------------------------------------------------------------------

message("reading input data")
count = fread(parser$input)
count = as.matrix(count)

# handle zeros --------------------------------------------------------------------------

freqshrink=function(n){
        N=sum(n)
        q=n/N       
        
        D=length(n)
        T=rep(1/D,D)
        l=(1-sum(q^2))/((N-1)*sum((T-q)^2))
        if (l<0){
            l=0
        }
        if(l>1){
            l=1
        }
        qs=l/D+(1-l)*n/N
        
}

message("imputing using method ", parser$method)
if (parser$method %in% c('CZM', 'GBM')){
    require(zCompositions)
    count = cmultRepl(count, method=parser$method, label=0, output='p-counts')
}else if (parser$method == 'lrSVD'){
    require(zCompositions)
    count = lrSVD(count, label=0, dl=rep(1, ncol(count)))
}else if (parser$method == 'freqshrink'){
    count  = t(apply(t(count), 2, freqshrink))
}

# save output files ----------------------------------------------------------------------

message("saving imputed counts")
fwrite(count, file=parser$output, quote=F, sep=",", row.names=F, col.names=F, compress="gzip")
