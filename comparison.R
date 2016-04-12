# Gene selection box --------------------------------------------------
output$g1 = renderUI({
  
  # Pull out the names of the filtered genes.
  selGenes = filterData() %>% 
    mutate(fullName = paste0(gene, ' (', transcript, ')'))
  
  selGenes = unique(as.character(selGenes$fullName)) # shortName is factorized...
  
  selectizeInput('compRef', label = 'ref. transcript',
                 choices = selGenes,
                 width = '200px')
})



# Comparison plot  ------------------------------------------------------

output$compPlot = renderPlot({
  
  
  # filter data
  filteredData = filterData() %>% 
    mutate(fullName = paste0(gene, ' (', transcript, ')'))
  
  
  # pull out the data for the reference gene
  refGene = input$compRef
  
  refExpr = filteredData %>% 
    filter(fullName == refGene) %>% 
    mutate(refExpr = expr) %>% 
    select(tissue, refExpr)
  
  # Combine the reference data with the normal data.
  # Remove the reference tissue.
  # Calculate the fold change
  filteredData = left_join(filteredData, refExpr, by = 'tissue') %>% 
    filter(fullName != input$compRef) %>% 
    mutate(FC = expr / refExpr,
           logFC = log10(FC))
  
  
  # Calculate correlation coefficient ---------------------------------------
  
  # pairwise = spread(filteredData %>% select(tissue, transcript, expr, refExpr),
  #                   transcript, expr) %>% 
  #   select(-tissue)
  # 
  # correl = data.frame(cor(pairwise)) %>% 
  #   select(corr = refExpr) 
  # 
  # correl = correl %>%
  #   mutate(transcript = row.names(correl)) %>% 
  #   filter(transcript != 'refExpr')
  # 
  # filteredData = left_join(filteredData, correl, by = "transcript", copy = TRUE) %>% 
  #   mutate(transFacet = paste0(gene, '(', transcript, ')'))
  
  
  # Calculate limits for the plot
  yMax = max(abs(filteredData$logFC))
  
  glimpse(filteredData)
  
  # Refactorize -------------------------------------------------------------
  
  # Reverse tissue names
  filteredData$tissue = factor(filteredData$tissue, levels = rev(levels(filteredData$tissue)))
  
  
  
  # Plot --------------------------------------------------------------------
  
  ggplot(filteredData,
         aes(x = logFC, xend = 0, y = tissue, yend = tissue,
             fill = logFC)) +
    geom_segment(colour = grey40K, size = 0.25) +
    geom_vline(xintercept = 0, colour = grey90K, size = 0.25) +
    geom_point(size = 4, colour = grey70K,
               shape = 21) +
    scale_fill_gradientn(colours = brewer.pal(10, 'RdYlBu'),
                         limits = c(-yMax, yMax)) +
    theme_xgrid() +
    theme(rect = element_rect(colour = grey90K, size = 0.25, fill = NA),
          panel.border = element_rect(colour = grey90K, size = 0.25, fill = NA)) +
    facet_wrap(~fullName) +
    xlab('log(fold change)')
  
})


