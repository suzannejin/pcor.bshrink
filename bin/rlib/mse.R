#!/usr/bin/env Rscript

# ===================================================================
# Helper functions to estimate the mean squared error between
# the covariance/partial correlation matrices computed
# on the ground truth and the ones computed on a subsample
# ===================================================================

# @true: list of covariance/partial correlation matrices computed on ground truth data
# @pred: list of covariance/partial correlation matrices computed on a subsampled data
# return @l: list of mean squared errors
calculate_mse <- function(true, pred){
    l = list()
    for (i in c('cov', 'cov.shrink', 'cov.basis')){
        l[[i]] = mse(true[['cov']], pred[[i]])
    }
    for (i in c('pcor', 'pcor.shrink', 'pcor.basis')){
        l[[i]] = mse(true[['pcor']], pred[[i]])
    }
    return(l)
}
# @true: a covariance/partial correlation matrix computed on ground truth data
# @pred: a covariance/partial correlation matrix computed on a subsampled data
# return mean squared error
mse <- function(true, pred){
    true = true[lower.tri(true)]
    pred = pred[lower.tri(pred)]
    return( mean((true-pred)^2) )
}