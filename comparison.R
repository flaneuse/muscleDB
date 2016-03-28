output$compPlot = renderPlotly({

  filteredData = filterData()
  
  refGene = filteredData$transcript[1]
  
  refExpr = filteredData %>% 
    filter(transcript == refGene) %>% 
    mutate(refExpr = expr) %>% 
    select(tissue, refExpr)
  
  
  filteredData = left_join(filteredData, refExpr, by = 'tissue')
  
  
  pairwise = spread(filteredData %>% select(tissue, transcript, expr, refExpr),
                    transcript, expr) %>% 
    select(-tissue)
  
  correl = data.frame(cor(pairwise)) %>% 
    select(corr = refExpr) 
  
  correl = correl %>%
    mutate(transcript = row.names(correl)) %>% 
    filter(transcript != 'refExpr')
  
  filteredData = left_join(filteredData, correl, by = "transcript", copy = TRUE) %>% 
    mutate(transFacet = paste0(gene, '(', transcript, ')'))
  
  
  yMax = max(max(filteredData$refExpr), max(filteredData$expr))
  yMin = min(min(filteredData$refExpr), min(filteredData$expr))
  
  
  shading <- data.frame(x1 = c(yMin, yMax, yMin),
                        y1 = c(yMin, yMax, yMax),
                        x2 = c(yMin, yMax, yMax),
                        y2 = c(yMin, yMin, yMax),
                        group = c(1, 1, 1))
  
  

  
  x = ggplot(filteredData, aes(x = expr, y = refExpr,
                               colour = tissue)) +
    geom_polygon(aes(x = x1, y = y1, group = group), 
                 fill = grey15K,  colour = NA,
                 data = shading, alpha  = 0.3) +
    geom_polygon(aes(x = x2, y = y2, group = group), 
                 fill = grey30K,  colour = NA,
                 data = shading, alpha = 0.3) +
    geom_abline(slope = 1, intercept = 0,
                colour = grey40K, size = 0.5,
                linetype = 2) +
    annotate(geom = 'text', x = yMin, y = yMax * 0.95,
             hjust = 0, 
             label = 'lower expression than ref.', colour = grey70K, size = 3) +
    annotate(geom = 'text', x = yMax * 0.95, y = yMin*1.05,
             hjust = 1,
             label = 'higher expression than ref.', colour = grey90K, size = 3) +
    # geom_smooth(method = "lm", se = FALSE, 
    # colour = grey40K, size = 0.5) +
    geom_point(size = 4) +
    facet_wrap(~transFacet) +
    ylab('ref. - uc007afc') +
    theme_bw() +
    theme(
      text = element_text(colour = grey80K),
      plot.title = element_text(hjust = 0),
      rect = element_blank(),
      plot.background = element_blank(),
      axis.text = element_text(size = 12,  color = grey80K),
      title =  element_text(size = 15, hjust = 0, color = grey90K),
      axis.title =  element_text(size = 14,  color = grey80K, hjust = 0.5, vjust = -0.25),
      strip.text = element_text(size=14, face = 'bold', hjust = 0.05, vjust = -2.5, color = grey70K),
      legend.position = 'none',
      strip.background = element_blank(),
      axis.ticks = element_blank(),
      panel.margin = unit(3, 'lines'),
      panel.grid.major.y = element_line(size = 0.2, color = grey80K),
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_line(size = 0.2, color = grey80K),
      axis.title.x = element_blank()) +
    coord_cartesian(xlim = c(yMin, yMax), ylim = c(yMin, yMax)) +
    scale_colour_manual(values = 
                          c('total aorta' = '#b15928',
                            'thoracic aorta' = '#ffff99',
                            'AA' = '#fed976',
                            'atria' = '#ff7f00',
                            'left ventricle' = '#e31a1c',
                            'right ventricle' = '#fb9a99',
                            'diaphragm' = '#6a3d9a',
                            'eye' = '#cab2d6',
                            'EDL' = '#1f78b4',
                            'FDB' = '#a6cee3',
                            'masseter' = '#1d91c0',
                            'plantaris' = '#7bccc4',
                            'soleus' = '#33a02c',
                            'tongue' = '#b2df8a'))
  
  
  
  ggplotly(x)
  
})
# # 
# #   # Temporary plgot to be replaced by interactive version.
# #   filteredData %>%   
# #     group_by(transcript) %>% 
# #     ggvis(x = ~tissue, y = ~expr2, colour =: ~transcript) %>%
# #     layer_bars()
# # })%>% bind_shiny("compPlot")
# # 
# # # 
# mtcars %>%   ggvis(~mpg, ~wt) %>%
#   layer_points() %>%
#   layer_smooths() %>%
#   bind_shiny("compPlot")
# 
# 
# # n= n %>% mutate(expr1 = n/maxN)
# 
# # n %>% ggvis(x=~c(1:8), y=~expr/maxN) %>% 
# #   layer_bars(fill:="dodgerblue") %>%
# #   scale_numeric("y", domain = c(0, 1)) %>%
# #                   hide_axis("y") %>%
# #                   hide_axis("x")