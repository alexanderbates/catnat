% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/neuronlist.R
\name{primary.neurite}
\alias{primary.neurite}
\alias{primary.neurite.neuron}
\alias{primary.neurite.neuronlist}
\alias{starting.neurite}
\alias{starting.neurite.neuron}
\alias{starting.neurite.neuronlist}
\title{Returns the primary neurite of a neuron}
\usage{
primary.neurite(x, resample = 1, keep.pnt = T, ...)

\method{primary.neurite}{neuron}(x, resample = 1, keep.pnt = T, ...)

\method{primary.neurite}{neuronlist}(x, resample = 1, keep.pnt = T, ...)

starting.neurite(x, k, ...)

\method{starting.neurite}{neuron}(x, k = 100, ...)

\method{starting.neurite}{neuronlist}(x, k = 100, ...)
}
\arguments{
\item{x}{a neuron or neuronlist object}

\item{resample}{The new spacing with which to evenly resample each neuron. Can be set to F to prevent resampling.}

\item{keep.pnt}{whether to keep just the primary neurite tract of the skeleton, or remove it and keep the neuron's arbour instead}

\item{...}{additional arguments passed to methods}

\item{k}{the number of nodes from the soma to include}
}
\value{
A neuron pruned to its primary dendrite
}
\description{
Returns the primary neurite of a neuron, defined as the cable between soma and first branch point
}
