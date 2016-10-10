library(ggvis)

df %>% 
  filter(!is.na(AA.AOR_q)) %>% 
  ggvis(~log(AA.AOR_q)) %>% 
  layer_densities()


library(ggvis)
library(shiny)

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
