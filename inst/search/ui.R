library(shiny)

cat("start ui\n")

ui <- fluidPage(
  titlePanel("Publication Search"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("compare", "Number of publications to compare",
        min = 100, max = 500, value = 100, step = 100),
      sliderInput("result", "Number of resulting publications to show",
        min = 10, max = 50, value = 10, step = 10),
      textInput("search", "Enter search query", "Bayesian Statistics"),
      actionButton("button", "Show")
    ),
    mainPanel(
      h4("Results"),
      tableOutput('table')
    )
  )
)
