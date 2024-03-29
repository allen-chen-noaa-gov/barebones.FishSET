% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/discretefish_subroutine.r
\name{discretefish_subroutine}
\alias{discretefish_subroutine}
\title{discretefish_subroutine}
\usage{
discretefish_subroutine(
  catch,
  choice,
  distance,
  otherdat,
  initparams,
  optimOpt,
  func,
  methodname
)
}
\arguments{
\item{catch}{Data corresponding to actual zonal choice}

\item{choice}{Data corresponding to actual catch}

\item{distance}{Data corresponding to distance}

\item{otherdat}{Other data (as a list)}

\item{initparams}{Initial parameter estimates for
revenue/location-specific covariates then cost/distance}

\item{optimOpt}{Optimization options [max iterations, (reltol) tolerance
of x, report frequency, whether to report]}

\item{func}{Name of likelihood function}

\item{methodname}{Optimization method (see optim options)}
}
\value{
OutLogit: [outmat1 se1 tEPM2] (coefs, ses, tstats) \cr
optoutput: optimization information \cr
seoumat2: ses \cr
MCM: Model Comparison metrics \cr
H1: inverse hessian \cr
}
\description{
Subroutine to run chosen discrete choice model
}
