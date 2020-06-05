#' Publication search interface
#'
#' @export
start_app <- function() {
  shiny::runApp(system.file("search", package="maxsim"), launch.browser = T)
}
