# volcano table -----------------------------------------------------------

output$volcanoTable <- renderDataTable({
  filtered = filterData()
  
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


# volcano tooltip ---------------------------------------------------------

volcanoTooltip = function(x) {
  
  # Nothing to tooltip.
  if(is.null(x)) return(NULL)
  
  # Pull out an isolated instance of the data.
  all_data <- isolate(filterData())
  
  # get gene symbol and transcript id.
  geneName <- all_data[all_data$id == x$id, 1]
  transcriptName <- all_data[all_data$id == x$id, 2]
  
  # Paste together the data.
  paste0("<b>", geneName, "</b><br>",
         transcriptName, "<br>",
         "fold change: ", format(10^x[1], digits = 3, nsmall = 1), "<br>",
         "q: ", format(10^-x[2], digits = 3, nsmall = 1))
}



# ggvis volcano output ----------------------------------------------------

reactiveVolcano <- reactive({
  
  # -- x-axis label --
  xLab = paste0(input$muscle1, ' / ', input$muscle2)
  
  # -- Main ggvis plot --
  # mtcars %>% ggvis(~wt, ~mpg) %>% 
  filterData %>% ggvis(x = ~logFC, y = ~logQ, key := ~id) %>%
    
    # -- Draw scatter plot --
    layer_points(size := 25, size.hover := 100, fill.hover := "royalblue",
                 stroke := "#BD202E",  stroke.hover := "navy", strokeWidth.hover := 0.75,
                 fill := "#BD202E",  opacity := 0.5) %>%
    
    # -- add tooltip --
    # add_tooltip(volcanoTooltip, "hover")  %>%
    
    # -- add axis labels --
    add_axis("x", title = paste("log(fold change in expression) (", xLab,")"),
             properties = axis_props(
               title = list(fontSize = 20),
               axis = list(strokeWidth = 2),
               labels = list(align = "center", fontSize = 16))) %>%
    add_axis("y", title = "-log(q)",
             tick_padding = 13,
             title_offset = 50,
             properties = axis_props(
               title = list(fontSize = 20),
               axis = list(strokeWidth = 2),
               labels = list(align = "center", fontSize = 16))) %>%
    set_options(width = 700, height = 500)
}) %>% bind_shiny("volcanoPlot")
