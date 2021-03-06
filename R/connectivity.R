#' Retrieving CATMAID neuron skeletons connected to query skeletons
#'
#' @description Gets neurons downstream/upstream of a query set of skeletons from a CATMAID database
#'
#' @param someneuronlist a 3D shape, neuronlist or neuron object that has been plotted in 3D whose coordinates can be accessed with nat::xyzmatrix()
#' @param X The upper and lower bounds for acceptable X coordinates
#' @param Y The upper and lower bounds for acceptable Y coordinates
#' @param Z The upper and lower bounds for acceptable Z coordinates
#' @param min_nodes Minimum number of nodes wanted in returned neuronlist
#' @param max_nodes Maximum number of nodes wanted in returned neuronlist
#' @param min_synapses Minimum number of synapses required from/to any neuron of the query group
#' @param prepost Whether to return downstream neurons (0), upstream neurons (1) or both (NULL)
#' @param soma Whether returned neurons must have a soma or not. Defaults to T.
#' @param exclude.skids skids of neurons
#' @param ... additional arguments passed to methods.
#'
#' @details CATMAID access required.
#'
#' @return A neuronlist object
#' @export
#' @seealso \code{\link{skeleton_connectivity_matrix}}
get_connected_skeletons <- function(someneuronlist, X = c(upper = 100000000, lower = 0), Y = c(upper = 100000000, lower = 0), Z = c(upper = 100000000, lower = 0), min_nodes = 1000, max_nodes = NULL, min_synapses = 4, prepost = NULL, soma = T, exclude.skids = NULL, ...){
  dlconns=subset(catmaid::connectors(someneuronlist), x<ifelse(is.null(X[1]),100000000,X[1]) & y<ifelse(is.null(Y[1]),100000000,Y[1]) & z < ifelse(is.null(Z[1]),100000000,Z[1])) # Remove synapses above greater than xyz
  dlconns=subset(dlconns, x>ifelse(is.null(X[2]),0,X[2]) & y>ifelse(is.null(Y[2]),0,Y[2]) & z > ifelse(is.null(Z[2]),0,Z[2])) # Remove synapses above lower than xyz
  if (is.null(prepost)){dlconns=subset(dlconns, prepost==prepost)}
  someneuronlist_all_connected=catmaid::catmaid_get_connectors_between(names(someneuronlist))
  someneuronlist_dl_connected=subset(someneuronlist_all_connected, connector_id%in%dlconns$connector_id)
  someneuronlist_dl_connected_skids=unique(someneuronlist_dl_connected$post_skid)
  skids=as.integer(catmaid::catmaid_fetch(paste("/1/skeletons/?nodecount_gt=",min_nodes,sep="")))
  if (!is.null(max_nodes)){
    skids.big=as.integer(catmaid::catmaid_fetch(paste("/1/skeletons/?nodecount_gt=",max_nodes,sep="")))
    skids = skids[!skids%in%skids.big]
  }
  someneuronlist_dl_connected_1k_skids=intersect(skids, someneuronlist_dl_connected_skids)
  someneuronlistc=catmaid::catmaid_query_connected(someneuronlist[,'skid'])
  # Get skids in a certain direction, at a certain synapse threshold
  if (!is.null(prepost)){
    if (prepost == 0){
      someneuronlistdfgt4=subset(someneuronlist_dl_connected_1k_skids, someneuronlist_dl_connected_1k_skids%in%subset(someneuronlistc$outgoing,syn.count>=min_synapses)$partner)
    }else if (prepost == 1){
      someneuronlistdfgt4=subset(someneuronlist_dl_connected_1k_skids, someneuronlist_dl_connected_1k_skids%in%subset(someneuronlistc$incoming,syn.count>=min_synapses)$partner)
    }
  }else{someneuronlistdfgt4=subset(someneuronlist_dl_connected_1k_skids, someneuronlist_dl_connected_1k_skids%in%subset(rbind(someneuronlistc$outgoing,someneuronlistc$incoming),syn.count>=min_synapses)$partner)}
  if (!is.null(exclude.skids)){someneuronlistdfgt4=someneuronlistdfgt4[!someneuronlistdfgt4%in%exclude.skids]}
  someneuronlistds=read.neurons.catmaid(someneuronlistdfgt4)
  # check for soma
  if (soma==T){
    has_soma=sapply(someneuronlistds, function(x) !is.null(somaid))
    someneuronlistds = someneuronlistds[has_soma]
  }
}

#' Generate connectivity matrix
#'
#' @description Generate a connectivity matrix from neuronlist skeleton data. Can also be used with fragmented neurons, i.e. those generated using the flow.centrality() and neurites() functions.
#'
#' @param pre skeletons from which connections are to be included
#' @param post skeletons to which connections from the pre group are to be included. Defaults to the pre group.
#' @param data a connectivity matrix
#' @param ... additional arguments passed to methods.
#'
#' @details CATMAID access required.
#'
#' @return A connectivity matrix. The values are synaptic weights, row and column names are neuron names from CATMAID.
#' @export
#' @rdname connectivity_matrix
#' @seealso \code{\link{get_connected_skeletons}} \code{\link{neurites}} \code{\link{flow.centrality}}
skeleton_connectivity_matrix <- function(pre, post = NULL, ...){
  outs = nlapply(pre, function(x)subset(x$connectors$connector_id, x$connectors$prepost==0))
  if (is.null(post)){
    ins = nlapply(pre, function(x)subset(x$connectors$connector_id, x$connectors$prepost==1))
  }else{ins = nat::nlapply(post, function(x)subset(x$connectors$connector_id, x$connectors$prepost==1))}
  m = matrix(0,nrow = length(pre), ncol = length(post))
  rownames(m) <- pre[,"name"]
  colnames(m) <- post[,"name"]
  for (skel in 1:length(pre)){
    for (skel2 in 1:length(post)){
      syns = sum(ins[[skel2]]%in%outs[[skel]])
      m[skel,skel2] <- syns
    }
  }
  m
}

#' @export
#' @rdname connectivity_matrix
connectivity_matrix <- function(pre, post = pre, ...){
  if(is.neuronlist(pre)){pre = names(pre)}
  if(is.neuronlist(post)){pre = names(post)}
  outputs = catmaid_query_connected(pre)$outgoing
  outputs = outputs[outputs$partner%in%post,]
  m = matrix(0,nrow = length(pre), ncol = length(post))
  rownames(m) = catmaid_get_neuronnames(pre)
  colnames(m) = catmaid_get_neuronnames(post)
  for (skel in 1:length(pre)){
    for (skel2 in 1:length(post)){
      syns = outputs[outputs$skid==pre[skel]&outputs$partner==post[skel2],][,"syn.count"]
      m[skel,skel2] = ifelse(length(syns)==0, 0, syns)
    }
  }
  m
}

#' @export
#' @rdname connectivity_matrix
neuron.heatmap <- function(data,  ...){
  if (!requireNamespace("gplots", quietly = TRUE))
    stop("You must install suggested package gplots!")
    gplots::heatmap.2(data,col = colorRampPalette(c('navy','cyan','yellow','red')), notecex = 0.7, keysize = 1.5, cexCol = 0.3, cexRow = 0.3, margins = c(5,9), breaks = c(seq(0,0.4,length=100), seq(0.5,3,length=100), seq(4,6,length=100), seq(7,20,length=100)),...)
}


