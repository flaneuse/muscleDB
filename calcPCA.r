calcPCA <- reactive({
  filteredData = filterData() %>% 
    select(contains("mean"))
  
  PCA = prcomp(filteredData, scale = TRUE, center = TRUE)
})