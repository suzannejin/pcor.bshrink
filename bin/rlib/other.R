#!/usr/bin/env Rscript

# ===================================================================
# Helper functions to organize the generated benchmark data
# ===================================================================


get_cor_name <- function(name){
    if (name %in% c('cov', 'cov.shrink', 'cov.basis')){
        'covariance'
    }else if (name %in% c('pcor', 'pcor.shrink', 'pcor.basis')){
        'partial correlation'
    }
}

# Specify shrinkage approach
get_shrink_name <- function(name){
    if (name %in% c('cov', 'pcor')){
        'no shrinkage'
    }else if (name %in% c('cov.shrink', 'pcor.shrink')){
        'shrink std'
    }else if (name %in% c('cov.basis', 'pcor.basis')){
        'shrink basis'
    }
}
