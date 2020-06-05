cat("init share\n")

library(maxsim)

tts <- function(query, compare, result) {
  publications <- maxsim::search_dist_items(query, compare, result)
  cat("done comparing query to publications!\n")
  return(publications)
}
