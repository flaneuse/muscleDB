output$volcano <- renderDataTable({
  filtered = filterData()
  
})

# plotVolcano <- reactive({
#   xLab = filterVolcano()$xLab[1]
#   
#   if (is.null(xLab)) {
#     xLab = NULL 
#   }
#   
#   filterVolcano %>% ggvis(x = ~logFC, y = ~logQ, key := ~ID) %>% 
#     layer_points(size := 25, size.hover := 100, fill.hover := "royalblue",
#                  stroke := "#BD202E",  stroke.hover := "navy", strokeWidth.hover := 0.75, 
#                  fill := "#BD202E",  opacity := 0.5) %>%
#     add_tooltip(volcanoTooltip, "hover")  %>%
#     # Add axis labels
#     add_axis("x", title = paste("log(fold change in expression) (", xLab,")"),
#              properties = axis_props(
#                title = list(fontSize = 20),
#                axis = list(strokeWidth = 2),
#                labels = list(align = "center", fontSize = 16))) %>%
#     #         scale_numeric("x", domain = c(-5, 5), nice = FALSE, clamp = TRUE) %>%
#     add_axis("y", title = "-log(q)",
#              tick_padding = 13,
#              title_offset = 50,
#              properties = axis_props(
#                title = list(fontSize = 20),
#                axis = list(strokeWidth = 2),
#                labels = list(align = "center", fontSize = 16))) %>%
#     set_options(width = 700, height = 500)
# }) %>% bind_shiny("volcano")
