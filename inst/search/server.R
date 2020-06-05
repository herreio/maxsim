cat("start server\n")
source("share.R", local = TRUE)

server <- function(input, output) {
  cat("start server routine\n")
  res <- eventReactive(input$button, {
    tts(
      input$search,
      input$compare,
      input$result)
  })
  output$table <- renderTable(res())
}
