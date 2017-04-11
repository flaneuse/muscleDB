
# themes ------------------------------------------------------------------

theme_XGrid = function (font_normal = "Lato", font_semi = "Lato", font_light = "Lato Light", 
          legend.position = "none", legend.direction = "horizontal", 
          panel_spacing = 3, font_axis_label = 12, font_axis_title = font_axis_label * 
            1.15, font_facet = font_axis_label * 1.15, font_legend_title = font_axis_label, 
          font_legend_label = font_axis_label * 0.8, font_subtitle = font_axis_label * 
            1.2, font_title = font_axis_label * 1.3, grey_background = FALSE, 
          background_colour = grey10K, projector = FALSE) 
{

  background_colour = ifelse(grey_background == TRUE, background_colour, 
                             NA)
  if (grey_background == TRUE) {
    plot_margin = margin(t = 5, r = 15, b = 5, l = 5, unit = "pt")
  }
  else {
    plot_margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt")
  }
  theme(title = element_text(size = font_title, colour = "#414042", 
                             family = font_normal), plot.subtitle = element_text(size = font_subtitle, 
                                                                                 colour = "#636466", family = font_semi), text = element_text(family = font_light, 
                                                                                                                                                    colour = "#6d6e71", hjust = 0.5), axis.line = element_blank(), 
        axis.ticks.x = element_blank(), axis.line.y = element_blank(), 
        axis.ticks.y = element_blank(), axis.text.x = element_text(size = font_axis_label, 
                                                                   colour = "#6d6e71", family = font_light), axis.title.x = element_text(size = font_axis_title, 
                                                                                                                                           colour = "#6d6e71", family = font_semi), axis.text.y = element_text(size = font_axis_label, 
                                                                                                                                                                                                                 colour = "#6d6e71", family = font_light), axis.title.y = element_blank(), 
        legend.position = legend.position, legend.title = element_text(size = font_legend_title, 
                                                                       colour = "#6d6e71", family = font_semi), legend.text = element_text(size = font_legend_label, 
                                                                                                                                             colour = "#6d6e71", family = font_semi), legend.direction = legend.direction, 
        panel.background = element_rect(fill = "white", colour = NA, 
                                        size = NA), plot.background = element_rect(fill = background_colour, 
                                                                                   colour = NA, size = NA, linetype = 1), panel.spacing = unit(panel_spacing, 
                                                                                                                                               "lines"), panel.grid.minor.x = element_blank(), panel.grid.major.x = element_line(size = 0.1, 
                                                                                                                                                                                                                                 colour = "#6d6e71"), panel.grid.minor.y = element_blank(), 
        panel.grid.major.y = element_blank(), panel.border = element_blank(), 
        plot.margin = plot_margin, 
        strip.text = element_text(size = font_facet, colour = "#636466", hjust = 0.025), strip.background = element_blank())
}


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
  
  # Pull out the current Page Number
  pageNum = getCompPage()
  
  
  iBeg = (pageNum)*nPlots + 1
  iEnd = (pageNum + 1)*nPlots
  
  
  # filter data
  filteredData = filterData() %>% 
    mutate(fullName = paste0(gene, ' (', transcript, ')'))
  
  
  # Check that there's more than one gene to compare.
  numGenes = length(unique(filteredData$transcript))
  
  if(numGenes > 1) {
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
             logFC = log10(FC),
             logFC = ifelse(is.infinite(logFC), NA, logFC)) # correct for infinite values
    
    
    # Calculate correlation coefficient ---------------------------------------
    
    # Splay outward
    pairwise = spread(filteredData %>% select(tissue, transcript, expr, refExpr),
                      transcript, expr) %>%
      select(-tissue)
    
    # Calculate correlation
    correl = data.frame(cor(pairwise)) %>%
      select(corr = refExpr)
    
    correl = correl %>%
      mutate(transcript = row.names(correl))
    
    # Merge in with the master
    filteredData = left_join(filteredData, correl, by = "transcript")
    
    # Calculate limits for the plot
    yMax = max(abs(filteredData$logFC), na.rm = TRUE)
    
    
    # Refactorize -------------------------------------------------------------
    
    # Reverse tissue names
    filteredData$tissue = factor(filteredData$tissue, levels = rev(levels(filteredData$tissue)))
    
    if (input$sortBy == 'most') {
      orderNames = filteredData %>% 
        arrange(desc(corr)) # Sort by correlation coefficient, in descending order
      
      orderNames = orderNames$fullName
      
    } else if (input$sortBy == 'least') {
      orderNames = filteredData %>% 
        arrange(corr) # Sort by correlation coefficient, in ascending order
      
      orderNames = orderNames$fullName
    } else {
      orderNames = sort(filteredData$fullName)
    }
    
    
    filteredData$fullName = factor(filteredData$fullName, orderNames)
    
    
    # Select just the transcripts that fit within the current page.
    transcriptList = unique(filteredData$transcript)[iBeg:iEnd]
    
    filteredData = filteredData %>% 
      filter(transcript %in% transcriptList)
    
    
    # Plot --------------------------------------------------------------------
    
    
    ggplot(filteredData,
           aes(x = logFC, xend = 0, y = tissue, yend = tissue,
               fill = logFC)) +
      geom_segment(colour = grey40K, size = 0.25) +
      geom_vline(xintercept = 0, colour = "#414042", size = 0.25) +
      geom_point(size = 4, colour = "#6d6e71",
                 shape = 21) +
      scale_fill_gradientn(colours = brewer.pal(10, 'RdYlBu'),
                           limits = c(-yMax, yMax)) +
      theme_XGrid() +
      theme(rect = element_rect(colour = "#414042", size = 0.25, fill = NA),
            panel.border = element_rect(colour = "#414042", size = 0.25, fill = NA)) +
      facet_wrap(~fullName) +
      xlab('log(fold change)')
  } else {
    ggplot(data = data.frame(x = 0, y = 0, label = 'Select more than one gene to compare'), 
           aes(x = x, y = y, label = label)) +
      geom_text() +
      theme_void()
  }
  
})



# Comparison pagination ---------------------------------------------------

getCompPage <- reactive({
  page = (input$nextComp - input$prevComp)
  
  if (page < 0) {
    page = 0
  } else {
    page = page
  }
})
