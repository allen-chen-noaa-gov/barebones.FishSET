logit_c_estscale <- function(starts3, dat, otherdat, alts) {
    #' Conditional logit likelihood
    #'
    #' Conditional logit likelihood
    #'
    #' @param starts3 Starting values as a vector (num). For this likelihood,
    #'     the order takes: c([alternative-specific parameters],
    #'     [travel-distance parameters]). \cr \cr
    #'     The alternative-specific parameters and travel-distance parameters
    #'     are of length (# of alternative-specific variables) and (# of
    #'     travel-distance variables) respectively.
    #' @param dat Data matrix, see output from shift_sort_x, alternatives with
    #'     distance.
    #' @param otherdat Other data used in model (as a list containing objects
    #'     `intdat` and `griddat`). \cr \cr
    #'     For this likelihood, `intdat` are "travel-distance variables", which
    #'     are alternative-invariant variables that are interacted with travel
    #'     distance to form the cost portion of the likelihood. Each variable
    #'     name therefore corresponds to data with dimensions (number of
    #'     observations) by (unity), and returns a single parameter. \cr \cr
    #'     In `griddat` are "alternative-specific variables", that vary across
    #'     alternatives, e.g. catch rates. Each variable name therefore
    #'     corresponds to data with dimensions (number of observations) by
    #'     (number of alternatives), and returns a single parameter for each
    #'     variable (e.g. the marginal utility from catch). \cr \cr
    #'     For both objects any number of variables are allowed, as a list of
    #'     matrices. Note the variables (each as a matrix) within `griddat` and
    #'     `intdat` have no naming restrictions. "Alternative-specific
    #'     variables" may correspond to catches that vary by location, and
    #'     "travel-distance variables" may be vessel characteristics that affect
    #'     how much disutility is suffered by traveling a greater distance. Note
    #'     in this likelihood "alternative-specific variables" vary across
    #'     alternatives because each variable may have been estimated in a
    #'     previous procedure (i.e. a construction of expected catch). \cr \cr
    #'     If there are no other data, the user can set `griddat` as ones with
    #'     dimension (number of observations) by (number of alternatives) and
    #'     `intdat` variables as ones with dimension (number of observations) by
    #'     (unity).
    #' @param alts Number of alternative choices in model as length equal to
    #'     unity (as a numeric vector).
    #' @return ld: negative log likelihood
    #' @export
    #' @examples
    #' data(zi)
    #' data(catch)
    #' data(choice)
    #' data(distance)
    #' data(si)
    #'
    #' optimOpt <- c(1000,1.00000000000000e-08,1,0)
    #'
    #' methodname <- 'BFGS'
    #'
    #' kk <- 4
    #'
    #' si2 <- matrix(sample(1:5,dim(si)[1]*kk,replace=TRUE),dim(si)[1],kk)
    #' zi2 <- sample(1:10,dim(zi)[1],replace=TRUE)
    #'
    #' otherdat <- list(griddat=list(predicted_catch=as.matrix(predicted_catch),
    #'     si2=as.matrix(si2)), intdat=list(zi=as.matrix(zi),
    #'     zi2=as.matrix(zi2)))
    #'
    #' initparams <- c(2.5, 2, -1, -2)
    #'
    #' func <- logit_c
    #'
    #' results <- discretefish_subroutine(catch,choice,distance,otherdat,
    #'     initparams,optimOpt,func,methodname)
    #'
    #' @section Graphical examples: 
    #' \if{html}{
    #' \figure{logit_c_grid.png}{options: width="40\%" 
    #' alt="Figure: logit_c_grid.png"}
    #' \cr
    #' \figure{logit_c_travel.png}{options: width="40\%" 
    #' alt="Figure: logit_c_travel.png"}
    #' }
    #'
        
    griddat <- as.matrix(do.call(cbind, otherdat$griddat))
    intdat <- as.matrix(do.call(cbind, otherdat$intdat))
    
    gridnum <- dim(griddat)[2]/alts
    intnum <- dim(intdat)[2]
    # get number of variables
    
    obsnum <- dim(griddat)[1]
    
    starts3 <- as.matrix(starts3)
    gridcoef <- as.matrix(starts3[1:gridnum, ])
    sigmac <- as.matrix(starts3[((gridnum + intnum) - intnum + 1):
        (gridnum + intnum), ])
    # split parameters for grid and interactions
    
    intcoef <- -1
    
    gridbetas <- (matrix(rep(gridcoef, each = alts), obsnum, alts * gridnum,
        byrow = TRUE) * griddat)
    dim(gridbetas) <- c(nrow(gridbetas), alts, gridnum)
    gridbetas <- rowSums(gridbetas, dim = 2)
    
    intbetas <- .rowSums(intdat * matrix(intcoef, obsnum, intnum, byrow = TRUE),
        obsnum, intnum)
    
    betas <- matrix(c(gridbetas, intbetas), obsnum, (alts + 1))
    
    djztemp <- betas[1:obsnum, rep(1:ncol(betas), each = alts)] *
        dat[, 3:(dim(dat)[2])]
    dim(djztemp) <- c(nrow(djztemp), ncol(djztemp)/(alts + 1), alts + 1)
    
    prof <- rowSums(djztemp, dim = 2)
    profx <- prof - prof[, 1]
    
    exb <- exp(profx/matrix(sigmac, dim(prof)[1], dim(prof)[2]))
    
    ldchoice <- (-log(rowSums(exb)))
    
    ld <- -sum(ldchoice)
    
    if (is.nan(ld) == TRUE) {
        ld <- .Machine$double.xmax
    }
    
    ldsumglobalcheck <- ld
    assign("ldsumglobalcheck", value = ldsumglobalcheck, pos = 1)
    paramsglobalcheck <- starts3
    assign("paramsglobalcheck", value = paramsglobalcheck, pos = 1)
    ldglobalcheck <- unlist(as.matrix(ldchoice))
    assign("ldglobalcheck", value = ldglobalcheck, pos = 1)
    
    return(ld)
    
}
