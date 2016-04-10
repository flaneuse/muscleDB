calcPCA <- reactive({
  filteredData = filterData() %>% 
    select(transcript, tissue, expr) %>% 
    spread(tissue, expr) %>% 
    select(-transcript)
  
  PCA = prcomp(filteredData, scale = TRUE, center = TRUE)
  
})