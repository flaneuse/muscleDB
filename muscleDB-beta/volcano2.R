library(ggvis)
library(shiny)

alpha_dot = 0.3
size_dot = 25


df = data %>% 
  filter(tissue %in% c('total aorta', 'abdominal aorta')) %>% 
  select(id, tissue, transcript, gene, shortName, geneLink, transcriptLink, expr, AA.AOR_q) %>% 
  spread(tissue, expr) %>% 
  mutate(FC = signif(`abdominal aorta`/`total aorta`, 3),
         logFC = signif(log(`abdominal aorta`/`total aorta`), 3),
         logQ = signif(log(AA.AOR_q), 3))

server <- function(input, output) {
  df %>% 
    filter(is.finite(logFC)) %>% 
    ggvis(~logFC, ~-1*logQ) %>% 
    layer_points(opacity := alpha_dot,
                 size := size_dot) %>% 
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
