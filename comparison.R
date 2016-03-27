# comparison = reactive({
#   filteredData = filterData()
# 
#   transcriptList = c('uc033fhy', 'uc007afa')
#   
#   filteredData = data %>% 
#     filter(transcript %in% transcriptList) %>% 
#     mutate(expr2 = ifelse(transcript %in% transcriptList[1], -1 * expr, expr))
# 
#   # Temporary plgot to be replaced by interactive version.
#   filteredData %>%   
#     group_by(transcript) %>% 
#     ggvis(x = ~tissue, y = ~expr2, colour =: ~transcript) %>%
#     layer_bars()
# })%>% bind_shiny("compPlot")
# 
# # 
mtcars %>%   ggvis(~mpg, ~wt) %>%
  layer_points() %>%
  layer_smooths() %>%
  bind_shiny("compPlot")


# n= n %>% mutate(expr1 = n/maxN)

# n %>% ggvis(x=~c(1:8), y=~expr/maxN) %>% 
#   layer_bars(fill:="dodgerblue") %>%
#   scale_numeric("y", domain = c(0, 1)) %>%
#                   hide_axis("y") %>%
#                   hide_axis("x")