theme_xOnly<- function() {
  theme(title = element_text(size = 32, color = grey90K),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title = element_blank(), 
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.major = element_line(color = grey60K, size = 0.2),
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.background = element_blank(), 
        strip.text = element_text(size=13, face = 'bold', color = grey60K, family = 'Segoe UI Semilight'),
        strip.background = element_blank()
  )
}

grey90K = '#414042'
grey60K = '#808285'
nPlots = 9

output$plot1 <- renderPlot({
  library(RColorBrewer)
  
  filteredData = filterData()
  
  transcriptList = unique(filteredData$transcript)[1:nPlots]
  
  data2Plot = filteredData %>% 
    filter(transcript %in% transcriptList)
  
  ggplot(data2Plot, aes(y= expr, x=tissue, label = round(expr, 1))) +
    coord_flip() +
    geom_bar(stat = "identity", fill = 'dodgerblue') +
    geom_text(aes(x = tissue, y = 0), hjust = 1.1,
                family = 'Segoe UI Light', 
               colour = 'blue') +
    facet_wrap(~transcript) +
    theme_xOnly()
  
})


output$plot2 <- renderPlot({
  library(RColorBrewer)
  
  filteredData = filterData()
  
  transcriptList = unique(filteredData$transcript)[1:nPlots]
  
  data2Plot = filteredData %>% 
    filter(transcript %in% transcriptList)
  
  ggplot(data2Plot, aes(y= expr, x=tissue, fill = expr)) +
    coord_flip() +
    geom_point(size = 3, shape = 21, colour = '#353839') +
    scale_fill_gradientn(colours = brewer.pal(9, 'BuPu')) +
    facet_wrap(~transcript) + 
    theme_xOnly()
  
})