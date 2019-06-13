logit_c_v <- function(starts3, dat, otherdat, alts) {
    #' logit_c_v
    #'
    #' Conditional logit likelihood vectorised
    #'
    #' @param starts3 Starting values. e.g. c([grid-varying variables], [interaction variables]).
    #' @param dat Data matrix, see output from shift_sort_x, alternatives with distance by column bind
    #' @param otherdat Other data used in model (as list). Any number of grid-varying variables (e.g. expected catch that varies by location) or 
    #' interaction variables (e.g. vessel characteristics that affect how much disutility is suffered by traveling a greater distance) are allowed. \cr \cr
    #' However, the user must place these in `otherdat` as list objects named `griddat` and `intdat` respectively. Note the variables 
    #' within `griddat` and `intdat` have no naming restrictions. \cr \cr
    #' Also note that `griddat` variables are dimension *(number of observations) x (number of alternatives)*, while `intdat` variables are 
    #' dimension *(number of observations) x 1*, to be interacted with the distance to each alternative. \cr \cr
    #' If there are no other data, the user can set `griddat` as ones with dimension *(number of observations) x (number of alternatives)*
    #' and `intdat` variables as ones with dimension *(number of observations) x 1*.
    #' @param alts Number of alternative choices in model
    #' @param project Name of project
    #' @param expname Expected catch table
    #' @param mod.name Name of model run for model result output table
    #' @return ld - negative log likelihood
    #' @export
    #' @examples
    #'
    
	griddat <- as.matrix(do.call(cbind, otherdat$griddat))
    intdat <- as.matrix(do.call(cbind, otherdat$intdat))
	
	gridnum <- dim(griddat)[2]/alts
	intnum <- dim(intdat)[2]
	#get number of variables
	
	obsnum <- dim(griddat)[1]
	
    starts3 <- as.matrix(starts3)
    gridcoef <- as.matrix(starts3[1:gridnum, ])
    intcoef <- as.matrix(starts3[((gridnum + intnum) - 
				intnum + 1):(gridnum + intnum), ])
    #split parameters for grid and interactions
	
	#############################################

	gridbetas <- (matrix(rep(gridcoef,each=alts),obsnum,alts*gridnum,byrow=TRUE)*griddat)
	dim(gridbetas) <- c(nrow(gridbetas), alts, gridnum)
	gridbetas <- rowSums(gridbetas,dim=2)
	
	intbetas <- .rowSums(intdat*matrix(intcoef,obsnum,intnum,byrow=TRUE),obsnum,intnum)
	
	betas <- matrix(c(gridbetas, intbetas),obsnum,(alts+1))

	djztemp <- betas[1:obsnum,rep(1:ncol(betas), each = alts)]*dat[, 3:(dim(dat)[2])]
	dim(djztemp) <- c(nrow(djztemp), ncol(djztemp)/(alts+1), alts+1)

	prof <- rowSums(djztemp,dim=2)
	profx <- prof - prof[,1]

	exb <- exp(profx)

	ldchoice <- (-log(rowSums(exb)))

	#############################################
    
	ld <- -sum(ldchoice)

    if (is.nan(ld) == TRUE) {
        ld <- .Machine$double.xmax
    }
	
    ldsumglobalcheck <- ld
    assign('ldsumglobalcheck', value = ldsumglobalcheck, pos = 1)
    paramsglobalcheck <- starts3
    assign('paramsglobalcheck', value = paramsglobalcheck, pos = 1)
    ldglobalcheck <- unlist(as.matrix(ld1))
    assign('ldglobalcheck', value = ldglobalcheck, pos = 1)

    return(ld)

}
