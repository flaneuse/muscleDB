output$downloadTable <- downloadHandler(
  filename = function() {
    paste('data-', Sys.Date(), '.csv', sep='')
  },
  content = function(file) {
    filteredData = filterData()
    
    filteredData = filteredData %>% 
      select(transcript, id, tissue, 
             expr, SE, contains ('_q')) %>% 
      spread(tissue, expr) %>% 
      select(-id)    
    
    write.csv(filteredData, file)
  }
)