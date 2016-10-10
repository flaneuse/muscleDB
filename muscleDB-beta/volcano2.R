library(ggvis)
library(shiny)

alpha_dot = 0.3
size_dot = 25
stroke_width = 0.75
fill_dot = '#3288bd'
stroke_dot = '#313695'
fill_hover = '#d53e4f'
stroke_hover = '#9e0142'

volcanoTooltip <- function(x) {
  if(is.null(x)) return(NULL)
  # all_data <- isolate(filterVolcano())
  geneName = df[df$id == x$id, 'gene']
  transcriptName  = df[df$id == x$id, 'transcript']
    # strtrim(all_data[all_data$ID == x$ID, 2],10)
  # paste0("<b>", geneName, "</b><br>",
  # transcriptName, "<br>",
  # "fold change: ", format(10^x[1], digits = 3, nsmall = 1), "<br>",
  # "p/q: ", format(10^-x[2], digits = 3, nsmall = 1))
  
  paste0("<b>", geneName, "</b><br>",
         transcriptName, "<br>",
         "fold change: ", format(10^x[1], digits = 3, nsmall = 1), "<br>",
         "q: ", format(10^-x[2], digits = 3, nsmall = 1))
}

# toy df
df = data %>% 
  filter(tissue %in% c('total aorta', 'abdominal aorta')) %>% 
  select(id, tissue, transcript, gene, shortName, geneLink, transcriptLink, expr, AA.AOR_q) %>% 
  spread(tissue, expr) %>% 
  mutate(FC = signif(`abdominal aorta`/`total aorta`, 3),
         logFC = signif(log(`abdominal aorta`/`total aorta`), 3),
         logQ = signif(log(AA.AOR_q), 3)) %>% 
  slice(1:1000)

server <- function(input, output) {
  df %>% 
    filter(is.finite(logFC)) %>% 
    ggvis(x = ~logFC, y = ~-1*logQ, key := ~id) %>% 
    
    layer_points(opacity := alpha_dot,
                 size := size_dot,
                 
                 fill := fill_dot,
                 stroke := stroke_dot,
                 strokeWidth := stroke_width,

                 size.hover := size_dot * 4,
                 fill.hover := fill_hover,
                 stroke.hover := stroke_hover, 
                 strokeWidth.hover := stroke_width) %>% 
    
    add_tooltip(volcanoTooltip, "hover")  %>%
    bind_shiny('plot1')
  
  df %>% 
    filter(!is.na(logQ)) %>% 
    ggvis(~logQ) %>% 
    layer_densities() %>% 
    bind_shiny('plot2')
  
  df %>% 
    filter(!is.na(logFC)) %>% 
    ggvis(~logFC) %>% 
    layer_densities() %>% 
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




set.seed(1233)
cocaine <- cocaine[sample(1:nrow(cocaine), 500), ]

cocaine$id <- seq_len(nrow(cocaine))

lb <- linked_brush(keys = cocaine$id, "red")

cocaine %>%
  ggvis(~weight, ~price, key := ~id) %>%
  layer_points(fill := lb$fill, fill.brush := "red", opacity := 0.3) %>%
  lb$input()

# A subset of cocaine, of only the selected points
selected <- lb$selected
cocaine_selected <- reactive({
  cocaine[selected(), ]
})

cocaine %>%
  ggvis(~potency) %>%
  layer_histograms(width = 5, boundary = 0) %>%
  add_data(cocaine_selected) %>%
  layer_histograms(width = 5, boundary = 0, fill := "#dd3333")
