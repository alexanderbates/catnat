% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getsynapses.R
\name{get.synapses}
\alias{get.synapses}
\alias{get.synapses.neuron}
\alias{get.synapses.neuronlist}
\title{Get 3D coordinates of synapse (not connector) positions}
\usage{
get.synapses(x, target = c("BOTH", "PRE", "POST"), polypre = T, ...)

\method{get.synapses}{neuron}(x, target = c("BOTH", "PRE", "POST"), polypre = T, ...)

\method{get.synapses}{neuronlist}(x, target = c("BOTH", "PRE", "POST"), polypre = T, ...)
}
\arguments{
\item{x}{a neuronlist or neuron object}

\item{target}{whether post or presynapse are ot be returned, or both}

\item{polypre}{whether to consider the number of presynapses as a multiple of the numbers of connections each makes}

\item{...}{additional arguments passed to methods.}
}
\value{
Anatomically accurate synapse position (i.e. not just connector positions) as 3D coordinates
}
\description{
Get 3D coordinates of synapse (not connector) positions
}
\seealso{
\code{\link{clusterbysynapses}} \code{\link{flow.centrality}}
}
