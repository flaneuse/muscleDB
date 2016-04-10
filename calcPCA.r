calcPCA <- reactive({
  filteredData = filterData() %>% 
    select(transcript, tissue, expr) %>% 
    spread(tissue, expr)
  
  row.names(filteredData) = filteredData$transcript
  
  filteredData  = filteredData %>% 
    select(-transcript)
  
  PCA = prcomp(filteredData, scale = TRUE, center = TRUE)
  
})