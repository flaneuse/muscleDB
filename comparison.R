# comparison = reactive({
#   filteredData = filterData()
# 
library(llamar)

transcriptList = c('uc033fhy', 'uc007afa')

refExpr = data %>% 
  filter(transcript == 'uc007afc') %>% 
  mutate(refExpr = expr) %>% 
  select(tissue, refExpr)


filteredData = data %>%
  filter(transcript %in% transcriptList)

filteredData = left_join(filteredData, refExpr, by = 'tissue')


pairwise = spread(filteredData %>% select(tissue, transcript, expr, refExpr),
transcript, expr) %>% 
  select(-tissue)

correl = data.frame(cor(pairwise)) %>% 
  select(refExpr) 

correl = correl %>%
  mutate(transcript = row.names(correl)) %>% 
  filter(transcript != 'refExpr')


yMax = max(abs(min(filteredData$refExpr)), max(filteredData$expr))

ggplot(filteredData, aes(y = expr, x = tissue)) +
  geom_bar(stat = 'identity', fill = 'dodgerblue') +
  geom_bar(aes(y = refExpr), 
           stat = 'identity', fill = grey50K) +
  coord_flip() +
  facet_wrap(~transcript) +
  scale_y_continuous(limits = c(-1*yMax, yMax)) +
  theme_xgrid() +
  theme(panel.grid.major.x = element_line(colour = 'white', size = 0.3),
        panel.ontop = TRUE)

ggplot(filteredData, aes(x = expr, y = refExpr,
                         colour = tissue)) +
  geom_abline(slope = 1, intercept = 0,
              colour = grey40K, size = 0.5,
              linetype = 2) +
  # geom_smooth(method = "lm", se = FALSE, 
  # colour = grey40K, size = 0.5) +
  geom_point(size = 4) +
  facet_wrap(~transcript) +
  ylab('uc007afc') +
  theme_xygrid() +
  theme(axis.title.x = element_blank()) +
  coord_cartesian(xlim = c(0.8, 3.5), ylim = c(0.8, 3.5)) +
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