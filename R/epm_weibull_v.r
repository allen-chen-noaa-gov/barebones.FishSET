epm_weibull_v <- function(starts3, dat, otherdat, alts) {
    #' epm_weibull_v
    #'
    #' Expected profit model weibull catch function
    #'
    #' @param starts3 Starting values. e.g. c([grid-varying variables], [interaction variables], [catch variance], [scale parameter]).
    #' @param dat Data matrix, see output from shift_sort_x, alternatives with distance by column bind
    #' @param otherdat Other data used in model (as list). Any number of grid-varying variables (e.g. expected catch that varies by location) or 
    #' interaction variables (e.g. vessel characteristics that affect how much disutility is suffered by traveling a greater distance) are allowed. \cr \cr
    #' However, the user must place these in `otherdat` as list objects named `griddat` and `intdat` respectively. Note the variables #' within `griddat` 
    #' and `intdat` have no naming restrictions. \cr \cr
    #' Also note that `griddat` variables are  dimension *(number of observations) x #' (number of alternatives)*, while `intdat` variables are 
    #' dimension *(number of observations) x 1*, to be interacted with the distance to each #' alternative. \cr \cr
    #' If there are no other data, the user can set `griddat` as ones with dimension *(number of observations) x (number of alternatives)*
    #' and `intdat` variables as ones with dimension *(number of observations) x 1*.
    #' @param alts Number of alternative choices in model
    #' @param project Name of project
    #' @param expname Expected catch table
    #' @param mod.name Name of model run for model result output table
    #' @return ld - negative log likelihood
    #' @export

    ld1 <- list()
	intdat <- as.matrix(unlist(otherdat$intdat))
    griddat <- as.matrix(unlist(otherdat$griddat))
    
	gridnum <- dim(griddat)[2]
	intnum <- dim(intdat)[2]
	obsnum <- dim(otherdat$griddat[[1]])[1]
	
	intdat <- matrix(intdat, obsnum, dim(intdat)[1]/obsnum)
    griddat <- matrix(griddat, obsnum, dim(griddat)[1]/obsnum)
	
    pricedat <-  as.matrix(unlist(otherdat$pricedat))
	
    starts3 <- as.matrix(starts3)
    gridcoef <- as.matrix(starts3[1:(gridnum * alts), ])
    
	intcoef <- as.matrix(starts3[(((gridnum * alts) + intnum) - 
        intnum + 1):((gridnum * alts) + intnum), 
        ])
    
    if ((dim(starts3)[1] - ((gridnum * alts) + intnum + 
        1)) == alts) {
        k <- as.matrix(starts3[((gridnum * alts) + intnum + 
            1):((gridnum * alts) + intnum + alts), ])
        signum <- alts
    } else {
        k <- as.matrix(starts3[((gridnum * alts) + intnum + 
            1), ])
        signum <- 1
    }
	
    k <- sqrt(k^2)
    
    sigmac <- as.matrix(starts3[((gridnum * alts) + intnum + 
        1 + signum), ])  #end of vector
    
    #############################################
	
    gridmu <- (matrix(gridcoef[1:alts,],obsnum,alts,byrow=TRUE)*griddat)
    gridmu <- sqrt(gridmu^2)
        
    expgridcoef <- gridmu * matrix(gamma(1 + (1/k)), obsnum, alts)
		
	betas <- matrix(c((expgridcoef*matrix(pricedat,obsnum,alts)), intdat*rep(intcoef,obsnum)),obsnum,(alts*gridnum)+intnum)
        
	djztemp <- betas[1:obsnum,rep(1:ncol(betas), each = alts)]*dat[, 3:(dim(dat)[2])]
	dim(djztemp) <- c(nrow(djztemp), ncol(djztemp)/(alts+1), alts+1)

	prof <- rowSums(djztemp,dim=2)
	profx <- prof - prof[,1]

	exb <- exp(profx/matrix(sigmac, dim(prof)[1], dim(prof)[2]))

	ldchoice <- (-log(rowSums(exb)))

	#############################################

	yj <- dat[, 1]
	cj <- dat[, 2]
	
    if (signum == 1) {
		empk <- k
    } else {
		empk <- k[cj]
    }
        
	empgridmu <- (matrix(gridcoef[cj],obsnum,1,byrow=TRUE)*griddat[,1])	
	empgridmu <- sqrt(empgridmu^2)

	ldcatch <- (matrix((log(empk)),obsnum)) + (matrix((-(empk)),obsnum)*log(empgridmu)) + (matrix((empk - 1),obsnum)*log(yj)) +
			(-((yj/empgridmu)^(matrix(empk,obsnum))))
			
	ld1 <- ldcatch + ldchoice
	
	#############################################
	
	ld <- -sum(ld1)
    
    if (is.nan(ld) == TRUE) {
        ld <- .Machine$double.xmax
    }
    
    ldsumglobalcheck <- ld
    #assign('ldsumglobalcheck', value = ldsumglobalcheck, pos = 1)
    paramsglobalcheck <- starts3
    #assign('paramsglobalcheck', value = paramsglobalcheck, pos = 1)
    ldglobalcheck <- unlist(as.matrix(ld1))
    #assign('ldglobalcheck', value = ldglobalcheck, pos = 1)
    
    # ldglobalcheck <- list(model=paste0(project, expname, mod.name), ldsumglobalcheck=ldsumglobalcheck,
                          # paramsglobalcheck=paramsglobalcheck, ldglobalcheck=ldglobalcheck)
    #assign("ldglobalcheck", value = ldglobalcheck, pos = 1)
    
    return(ld)
    
}