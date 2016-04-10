output$pcaPlot = renderPlot({
  
  library(RColorBrewer)
  
  x = calcPCA()
  
  PCA = data.frame(x$x, ID = 1:nrow(x$x))
  
  ggplot(PCA, aes(x = PC1, y = PC2)) +
    theme_bw() +
    geom_point(size = 3, alpha = 0.3, color = brewer.pal(9, "PuRd")[7])
})


# Data table for filtered points ------------------------------------------

output$PCApts <- renderDataTable({
  filtered = calcPCA()
  
  filtered = data.frame(filtered$x, ID = 1:nrow(filtered$x))
  
  brushedPoints(filtered, input$pcaBrush)
},  
escape = c(-1,-2, -3),
options = list(searching = TRUE, stateSave = TRUE,
               pageLength = 25,
               rowCallback = JS(
                 'function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                 if (aData[0])
                 $("td:eq(0)", nRow).css("color", "#293C97");
                 $("td", nRow).css("text-align", "center");
                 }')
)
)


# Brush/zoom --------------------------------------------------------------


# When a double-click happens, check if there's a brush on the plot.
# If so, zoom to the brush bounds; if not, reset the zoom.
observeEvent(input$pcaDblclick, {
  brush <- input$pcaBrush
  if (!is.null(brush)) {
    ranges$x <- c(brush$xmin, brush$xmax)
    ranges$y <- c(brush$ymin, brush$ymax)
    
  } else {
    ranges$x <- NULL
    ranges$y <- NULL
  }
})
