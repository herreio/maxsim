#' Search for Items Most Likely Associated with Topic of Query
#'
#' @param query Query for topic inference.
#' @param n Number of items to return.
#' @importFrom stats predict
#' @import BTM
#' @export
search_topic_items <- function(query="information retrieval", n=10) {
  if(!exists("model")) {
    cat("load topic model!\n")
    data(model, package="simtitle")
  }
  # /// infer theta for query /// #
  query_corpus <- topmodelr::corpus_create(query)
  query_corpus <- topmodelr::corpus_prep(query_corpus)
  query_corpus <- topmodelr::prepare_bi_corpus(query_corpus)
  query_theta <- predict(model, newdata=query_corpus)
  # /// consider only topic of query with highest probability /// #
  query_topic <- which.max(query_theta)
  # /// get the n most likely publications for given topic /// #
  query_items <- topic_items_prob(topic=query_topic, n=n)
  if(!exists("sel_items")) {
    cat("load publication data!\n")
    data(sel_items, package="maxplanckr")
  }
  # /// return items most likely for given topic /// #
  items_subset(sel_items, query_items)[,c("Id", "Label")]
}

#' Search for Items by Topic Similarity of Query and Subset of Closest Items
#'
#' @param query Query for topic inference.
#' @param compare Number of items to compare.
#' @param n Number of items to return.
#' @importFrom stats predict
#' @import BTM
#' @export
search_dist_items <- function(query="information retrieval", compare=100, n=10) {
  if(!exists("model")) {
    cat("load topic model!\n")
    data(model, package="maxsim")
  }
  # /// infer theta for query /// #
  query_corpus <- topmodelr::corpus_create(query)
  query_corpus <- topmodelr::corpus_prep(query_corpus)
  query_corpus <- topmodelr::prepare_bi_corpus(query_corpus)
  query_theta <- predict(model, newdata=query_corpus)
  # /// consider only topic of query with highest probability /// #
  query_topic <- which.max(query_theta)
  # /// get items to compare by likeliness for given topic /// #
  query_items <- topic_items_prob(topic=query_topic, n=compare)
  if(!exists("sel_items")) {
    cat("load publication data!\n")
    data(sel_items, package="maxplanckr")
  }
  query_items <- items_subset(sel_items, query_items)[,c("Id", "Label")]
  # /// compute JSD for query and theta of item subset /// #
  if(!exists("theta")) {
    cat("load theta of publications!\n")
    data(theta, package="maxsim")
  }
  query_items_theta <- theta[query_items$Id,]
  query_n <- length(rownames(query_items_theta))
  query_dist <- philentropy::JSD(rbind(query_items_theta, query_theta))
  # /// rank items of item subset by JSD values /// #
  query_res <- sort(query_dist[query_n+1,], decreasing = FALSE)
  query_res_probs <- as.double(query_res)
  query_res_items <- query_items$Id[as.integer(gsub("v","",names(query_res)))]
  # /// exclude query from results /// #
  query_exclude <- is.na(query_res_items)
  query_res_probs <- query_res_probs[!query_exclude]
  query_res_items <- query_res_items[!query_exclude]
  # /// sort item subset by ascending distance /// #
  res_items <- query_items[match(query_res_items, query_items$Id),][c("Id","Label")]
  res_items <- tibble::add_column(res_items, "Dist"=query_res_probs)
  # /// only return the first n items /// #
  res_items[1:n,]
}


#' Search for Items by Topic Similarity of Query and Items Sharing the Most Likely Topic
#'
#' @param query Query for topic inference.
#' @param n Number of items to return.
#' @param limit If vector size should be limited
#' @importFrom stats predict
#' @import BTM
#' @export
search_topic_items_dist <- function(query="information retrieval", n=10, limit=TRUE) {
  if(!exists("model")) {
    cat("load topic model!\n")
    data(model, package="maxsim")
  }
  # /// infer theta for query /// #
  query_corpus <- topmodelr::corpus_create(query)
  query_corpus <- topmodelr::corpus_prep(query_corpus)
  query_corpus <- topmodelr::prepare_bi_corpus(query_corpus)
  query_theta <- predict(model, newdata=query_corpus)
  # /// consider only topic of query with highest probability /// #
  query_topic <- which.max(query_theta)
  # /// consider only items with the same most probable topic of query /// #
  query_items <- topic_items(topic=query_topic)
  # /// check if vector size is reasonable to be computed by jsd /// #
  if(length(query_items$Id) > 5000) {
    if(limit) {
      mssg <- paste0("\nnumber of vectors exceeds reasonable size for similarity calculation.\n")
      mssg <- paste0(mssg, "if you really want to compare ",length(query_items$Id),
                     " vectors, run the function with limit=FALSE !\n\n")
      return(cat(mssg))
    }
  }
  # /// compute JSD for query and theta of topic items /// #
  if(!exists("theta")) {
    cat("load theta of publications!\n")
    data(theta, package="maxsim")
  }
  query_items_theta <- theta[query_items$Id,]
  query_n <- length(rownames(query_items_theta))
  query_dist <- philentropy::JSD(rbind(query_items_theta, query_theta))
  # /// rank items of item subset by JSD values /// #
  query_res <- sort(query_dist[query_n+1,], decreasing = FALSE)
  query_res_probs <- as.double(query_res)
  query_res_items <- query_items$Id[as.integer(gsub("v","",names(query_res)))]
  # /// exclude query from results /// #
  query_exclude <- is.na(query_res_items)
  query_res_probs <- query_res_probs[!query_exclude]
  query_res_items <- query_res_items[!query_exclude]
  # /// sort item subset by ascending distance /// #
  res_items <- query_items[match(query_res_items, query_items$Id),][c("Id","Label")]
  res_items <- tibble::add_column(res_items, "Dist"=query_res_probs)
  # /// only return the first n items /// #
  res_items[1:n,]
}

topic_items_prob <- function(topic=1, n=10) {
  if(!exists("theta")) {
    cat("load theta of publications!\n")
    data(theta, package="maxsim")
  }
  topic_theta <- theta[,topic]
  topic_theta <- sort(topic_theta, decreasing=TRUE)
  names(topic_theta)[1:n]
}

topic_items <- function(topic=1) {
  if(!exists("items")) {
      cat("load item topic table!\n")
      data(items, package="maxsim")
  }
  topic_items <- items[items$Topic==topic,]$Id
  if(!exists("sel_items")) {
    cat("load publication data!\n")
    data(sel_items, package="maxplanckr")
  }
  items_subset(sel_items, topic_items)
}

items_subset <- function(data, items) {
  data[data$Id %in% items,]
}
