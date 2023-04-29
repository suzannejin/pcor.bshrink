#!/usr/bin/env Rscript

# ===================================================================
# Helper functions to ALR or CLR transform the data
# ===================================================================

# get logratios
# it calls get_clr() or get_alr()
get_lr <- function(count, transf=c('clr','alr')){
    if (transf == 'clr'){
        lr = get_clr(count)
    }else if (transf == 'alr'){
        lr = get_alr(count)
    }
    return(lr)
}

# CLR transform
get_clr <- function(count){
    lgm = apply(log(count),1,mean)
    clr = log(count) - lgm
    return(clr)
}

# ALR transform, with the last variable as reference
get_alr <- function(count){
    alr = log(count)-log(count[,ncol(count)])
    alr = alr[,-ncol(count)]
    return(alr)
}
