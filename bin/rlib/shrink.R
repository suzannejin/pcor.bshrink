#!/usr/bin/env Rscript

# ===================================================================
# Helper functions to calculate covariance, and partial 
# correlation matrices, with different shrinkage schemes
# ===================================================================



# calculate covariance and partial correlation 
# without shrinkage
noShrink <- function(M){
    Cov = cov(M) 
    PC  = cor2pcor(Cov)

    C = list(Cov,PC)
    names(C) = c('cov', 'pcor')
    return(C)
}


# calculate covariance and partial correlation
# with direct shrinkage
dShrink <- function(M){
    Cov = cov.shrink(M,verbose=FALSE)  
    PC  = cor2pcor(Cov)
    
    C = list(Cov,PC)
    names(C) = c('cov.shrink', 'pcor.shrink')
    return(C)
}


# calculate covariance and partial correlation
# with basis shrinkage
# @M : input data matrix
# @intype: 'logp' if input data = log compositions,
#          'alr' if input data was alr-transformed,
#          'clr' if input data was clr-transformed
# @outtype: 'clr' or 'alr'
bShrink <- function(M, intype, outtype="clr"){
    if (intype == "alr"){
        D = ncol(M)+1
    } else{
        D = ncol(M)
    }
    N = nrow(M)
    
    # convert the input data into log compositions -> the empirical basis
    if (intype == 'logp'){
        B = M
    }else if (intype == "alr"){
        P = exp(M)/(1+apply(exp(M),1,sum))
        P = cbind(P,1-apply(P,1,sum))
        B = log(P)
    } else if (intype=="clr"){
        f = log(apply(exp(M),1,sum)) 
        B = M-f
    }else{
        stop("please provide a valid input data")
    }
    
    # shrink covariance matrix
    Cb = cov.shrink(B,verbose=FALSE)  
    if (outtype == "alr"){
        F   = cbind(diag(rep(1,D-1)),rep(-1,D-1))
        Cov = F%*%Cb%*%t(F)
    } else if (outtype=="clr"){
        G   = diag(rep(1,D))-matrix(1/D,D,D)
        Cov = G%*%Cb%*%G
    } else{
        die("outtype unsupported")
    }

    # calculate partial correlations
    PC  = cor2pcor(Cov)
    
    # output
    C = list(Cov,PC)
    names(C) = c('cov.basis', 'pcor.basis')
    return(C)
    
}
