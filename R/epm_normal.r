epm_normal <- function(starts3, dat, otherdat, alts) {
    #' Expected profit model normal catch function
    #'
    #' Expected profit model normal catch function
    #'
    #' @param starts3 Starting values as a vector (num). For this likelihood,
    #'     the order takes: c([catch-function parameters], [travel-distance
    #'     parameters], [catch sigma(s)], [scale parameter]). \cr \cr
    #'     The catch-function and travel-distance parameters are of length (# of
    #'     catch-function variables)*(k) and (# of travel-distance variables)
    #'     respectively, where (k) equals the number of alternatives. The catch
    #'     sigma(s) are either of length equal to unity or length (k) if the
    #'     analyst is estimating location-specific catch sigma parameters. The
    #'     scale parameter is of length equal to unity.
    #' @param dat Data matrix, see output from shift_sort_x, alternatives with
    #'     distance.
    #' @param otherdat Other data used in model (as a list containing objects
    #'     `intdat`, `griddat`, and `prices`). \cr \cr
    #'     For this likelihood, `intdat` are "travel-distance variables", which
    #'     are alternative-invariant variables that are interacted with travel
    #'     distance to form the cost portion of the likelihood. Each variable
    #'     name therefore corresponds to data with dimensions (number of
    #'     observations) by (unity), and returns a single parameter. \cr \cr
    #'     In `griddat` are "catch-function variables" that are
    #'     alternative-invariant variables that are interacted with zonal
    #'     constants to form the catch portion of the likelihood. Each variable
    #'     name therefore corresponds to data with dimensions (number of
    #'     observations) by (unity), and returns (k) parameters where (k) equals
    #'     the number of alternatives. \cr \cr
    #'     For "catch-function variables" `griddat` and "travel-distance
    #'     variables" `intdat`, any number of variables are allowed, as a list
    #'     of matrices. Note the variables (each as a matrix) within `griddat`
    #'     `intdat` have no naming restrictions. "Catch-function variables" may
    #'     correspond to variables that impact catches by location, or
    #'     interaction variables may be vessel characteristics that affect how
    #'     much disutility is suffered by traveling a greater distance. Note in
    #'     this likelihood the "catch-function variables" vary across
    #'     observations but not for each location: they are allowed to impact
    #'     catches differently across alternatives due to the location-specific
    #'     coefficients. If there are no other data, the user can set `griddat`
    #'     as ones with dimension (number of observations) x (number of
    #'     alternatives) and `intdat` variables as ones with dimension (number
    #'     of observations) by (unity). \cr \cr
    #'     The variable `prices` is a matrix of dimension (number of
    #'     observations) by (unity), corresponding to prices.
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
    #' data(prices)
    #'
    #' optimOpt <- c(1000,1.00000000000000e-08,1,0)
    #'
    #' methodname <- 'BFGS'
    #'
    #' si2 <- sample(1:5,dim(si)[1],replace=TRUE)
    #' zi2 <- sample(1:10,dim(zi)[1],replace=TRUE)
    #'
    #' otherdat <- list(griddat=list(si=as.matrix(si),si2=as.matrix(si2)),
    #'     intdat=list(zi=as.matrix(zi),zi2=as.matrix(zi2)),
    #'     pricedat=list(prices=as.matrix(prices)))
    #'
    #' initparams <- c(0.5, 0.4, 0.3, 0.2, 0.55, 0.45, 0.35, 0.25, -0.3, -0.4,
    #'     3, 2, 3, 2, 1)
    #'
    #' func <- epm_normal
    #'
    #' results <- discretefish_subroutine(catch,choice,distance,otherdat,
    #'     initparams,optimOpt,func,methodname)
    #'
    #' @section Graphical examples: 
    #' \if{html}{
    #' \figure{epm_normal_grid.png}{options: width="40\%" 
    #' alt="Figure: epm_normal_grid.png"}
    #' \cr
    #' \figure{epm_normal_travel.png}{options: width="40\%" 
    #' alt="Figure: epm_normal_travel.png"}
    #' \cr
    #' \figure{epm_normal_sigma.png}{options: width="40\%" 
    #' alt="Figure: epm_normal_sigma.png"}
    #' }
    #'
        
    obsnum <- dim(griddat)[1]

    griddat <- as.matrix(do.call(cbind, otherdat$griddat))
    gridnum <- dim(griddat)[2]
    griddat <- matrix(apply(griddat, 2, function(x) rep(x,times=alts)), obsnum,
        gridnum*alts)
    intdat <- as.matrix(do.call(cbind, otherdat$intdat))
    intnum <- dim(intdat)[2]
    
    pricedat <- as.matrix(unlist(otherdat$pricedat))
    
    starts3 <- as.matrix(starts3)
    gridcoef <- as.matrix(starts3[1:(gridnum * alts), ])
    
    intcoef <- as.matrix(starts3[(((gridnum * alts) + intnum) - intnum + 1):
        ((gridnum * alts) + intnum), ])
    
    if ((dim(starts3)[1] - ((gridnum * alts) + intnum + 1)) == alts) {
    
        sigmaa <- as.matrix(starts3[((gridnum * alts) + intnum + 1):((gridnum *
            alts) + intnum + alts), ])
        signum <- alts
    
    } else {
    
        sigmaa <- as.matrix(starts3[((gridnum * alts) + intnum + 1), ])
        signum <- 1
    
    }
    
    sigmac <- as.matrix(starts3[((gridnum * alts) + intnum + 1 + signum), ])
    # end of vector
    
    gridbetas <- (matrix(gridcoef, obsnum, alts * gridnum, byrow = TRUE) *
        griddat)
    dim(gridbetas) <- c(nrow(gridbetas), alts, gridnum)
    gridbetas <- rowSums(gridbetas, dim = 2)
    
    intbetas <- .rowSums(intdat * matrix(intcoef, obsnum, intnum, byrow = TRUE),
        obsnum, intnum)
    
    betas <- matrix(c((gridbetas * matrix(pricedat, obsnum, alts)), intbetas),
        obsnum, (alts + 1))
    
    djztemp <- betas[1:obsnum, rep(1:ncol(betas), each = alts)] *
        dat[, 3:(dim(dat)[2])]
    dim(djztemp) <- c(nrow(djztemp), ncol(djztemp)/(alts + 1), alts + 1)
    
    prof <- rowSums(djztemp, dim = 2)
    profx <- prof - prof[, 1]
    
    exb <- exp(profx/matrix(sigmac, dim(prof)[1], dim(prof)[2]))
    
    ldchoice <- (-log(rowSums(exb)))
    
    yj <- dat[, 1]
    cj <- dat[, 2]
    
    if (signum == 1) {
        empsigmaa <- sigmaa
    } else {
        empsigmaa <- sigmaa[cj]
    }
    
    empgridbetas <- t(gridcoef)
    dim(empgridbetas) <- c(nrow(empgridbetas), alts, gridnum)
    
    empgriddat <- griddat
    dim(empgriddat) <- c(nrow(empgriddat), alts, gridnum)
    
    empcatches <- .rowSums(empgridbetas[, cj, ] * empgriddat[, 1, ], obsnum,
        gridnum)
    # note grid data same across all alternatives
    
    ldcatch <- (matrix((-(0.5) * log(2 * pi)), obsnum)) + (-(0.5) *
        log(matrix(empsigmaa, obsnum)^2)) + (-(0.5) * (((yj - empcatches)/
        (matrix(empsigmaa, obsnum)))^2))
    
    ld1 <- ldcatch + ldchoice
    
    ld <- -sum(ld1)
    
    if (is.nan(ld) == TRUE) {
        ld <- .Machine$double.xmax
    }
    
    ldsumglobalcheck <- ld
    assign("ldsumglobalcheck", value = ldsumglobalcheck, pos = 1)
    paramsglobalcheck <- starts3
    assign("paramsglobalcheck", value = paramsglobalcheck, pos = 1)
    ldglobalcheck <- unlist(as.matrix(ld1))
    assign("ldglobalcheck", value = ldglobalcheck, pos = 1)
    
    return(ld)
    
}
