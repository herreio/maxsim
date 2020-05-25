#' Scientific Publications and its Topics
#'
#' A data.frame (tibble) with publication identifiers and related topics.
#'
#' @docType data
#'
#' @usage data(items)
#'
#' @import dplyr
#'
#' @format An object of class \code{"tbl_df"}
#'
#' @source \url{https://github.com/dh-thesis/maxmodelr}
"items"

#' Topic Model of Scientific Publications
#'
#' A biterm topic model of english publications from the Max Planck Society.
#'
#' @docType data
#'
#' @usage data(model)
#'
#' @import BTM
#'
#' @format An object of class \code{"BTM"}
#'
#' @source \url{https://github.com/dh-thesis/maxmodelr}
"model"

#' Topic Distributions of Scientific Publications
#'
#' A matrix with publications as rows and topic distributions as columns.
#'
#' @docType data
#'
#' @usage data(theta)
#'
#' @format An object of class \code{"matrix"}
#'
#' @source \url{https://github.com/dh-thesis/maxmodelr}
"theta"
