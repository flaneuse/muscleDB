output$plot1 <- renderPlot({

  
  filteredData = filterData() %>% 
    select(contains("mean")) %>% 
    slice(1)
  
  filteredData = data.frame(val = t(filteredData))
  # row.names(filteredData) = c("aor", "atr")
  
#   filteredData = mtcars
#   filteredData %>% 
#     ggvis(x = 1:8, y = ~mpg) %>% formatPlot() 
  
  ggplot(filteredData, aes(x= 1:8, y=val)) + geom_bar(stat = "identity")
})