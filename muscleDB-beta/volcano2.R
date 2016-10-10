library(ggvis)
library(shiny)

alpha_dot = 0.3
size_dot = 25
stroke_width = 0.75
fill_dot = '#3288bd'
stroke_dot = '#313695'
fill_hover = '#d53e4f'
stroke_hover = '#9e0142'



# toy df
df = data %>% 
  filter(tissue %in% c('total aorta', 'abdominal aorta')) %>% 
  select(id, tissue, transcript, gene, shortName, geneLink, transcriptLink, expr, AA.AOR_q) %>% 
  spread(tissue, expr) %>% 
  mutate(FC = signif(`abdominal aorta`/`total aorta`, 3),
         logFC = signif(log(`abdominal aorta`/`total aorta`), 3),
         logQ = -1 * signif(log(AA.AOR_q), 3)) %>% 
  slice(1:1000)



server <- function(input, output) {
  
  volcanoTooltip <- function(x) {
    if(is.null(x)) return(NULL)
    # all_data <- isolate(filterVolcano())
    geneName = df[df$id == x$id, 'gene']
    transcriptName  = df[df$id == x$id, 'transcript']
    
    paste0("<b>", geneName, "</b><br>",
           transcriptName, "<br>",
           "fold change: ", format(10^x[1], digits = 3, nsmall = 1), "<br>",
           "q: ", format(10^-x[2], digits = 3, nsmall = 1))
  }
  
  
  lb <- linked_brush(keys = df$id, "#fee090")
  
  # A subset of df, of only the selected points
  selected <- lb$selected
  
  df_selected <- reactive({
    # if(sum(selected()) > 0){
      df[selected(), ]
    # } else{
        # df
      # }
  })
  
  df %>% 
    # remove things @ Inf, -Inf
    filter(is.finite(logFC)) %>% 
    
    # main setup
    ggvis(x = ~logFC, y = ~logQ, key := ~id) %>% 
    layer_points(opacity := alpha_dot,
                 size := size_dot,
                 
                 # fill := lb$fill,
                 fill := fill_dot,
                 stroke := stroke_dot,
                 strokeWidth := stroke_width,
                 
                 size.hover := size_dot * 4,
                 fill.hover := fill_hover,
                 stroke.hover := stroke_hover, 
                 strokeWidth.hover := stroke_width,
                 fill.brush := fill_hover) %>% 
    lb$input() %>%
    
    add_tooltip(volcanoTooltip, "hover")  %>%
    bind_shiny('plot1')
  
  
  
  
  df %>% 
    filter(!is.na(logQ)) %>% 
    ggvis(x = ~logQ) %>% 
    add_data(df_selected) %>% 
    layer_densities(fill := fill_dot) %>% 
    bind_shiny('plot2')
  
  df %>% 
    filter(!is.na(logFC)) %>% 
    ggvis(~logFC) %>% 
    layer_densities() %>% 
    add_data(df_selected) %>% 
    bind_shiny('plot3')
}

ui <- fluidPage(
  mainPanel(ggvisOutput("plot1"),
            ggvisOutput("plot2"),
            ggvisOutput("plot3"))
)

shinyApp(ui = ui, server = server)




# # Add axis labels
# add_axis("x", title = paste("log(fold change in expression) (", xLab,")"),
#          properties = axis_props(
#            title = list(fontSize = 20),
#            axis = list(strokeWidth = 2),
#            labels = list(align = "center", fontSize = 16))) %>%
# add_axis("y", title = "-log(q)",
#          tick_padding = 13,
#          title_offset = 50,
#          properties = axis_props(
#            title = list(fontSize = 20),
#            axis = list(strokeWidth = 2),
#            labels = list(align = "center", fontSize = 16))) %>%
# set_options(width = 700, height = 500)



