# Abandoned: no geom_segment; harder to map color vals; axis more obno?

# rdylbu = colorRampPalette(brewer.pal(10, 'RdYlBu'))
# 
# filtered = filtered %>% 
#   mutate(colFC = 'red')
# 
# filtered %>% 
#   filter(!is.infinite(logFC)) %>% 
#   ggvis(x = ~logFC, 
#         y = ~tissue,
#         fill := ~colFC) %>% 
#   layer_points(size = 10) 
filtered = data %>% filter(transcript %in% c('uc007aet', 'uc007aew')) %>% 
  group_by(tissue) %>% 
  mutate(lagged = lag(expr),
         logFC = log10(expr/lagged)) %>% 
  select(transcript, tissue, expr, lagged, logFC)

x = filtered %>% filter(!is.na(logFC), !is.infinite(logFC))

# Reverse tissue names
x$tissue = factor(x$tissue, levels = rev(levels(x$tissue)))

ggplot(x ,
       aes(x = logFC, xend = 0, y = tissue, yend = tissue,
           fill = logFC)) +
   geom_segment(colour = grey40K, size = 0.25) +
  geom_vline(xintercept = 0, colour = grey90K, size = 0.25) +
  geom_point(size = 4, colour = grey70K,
             shape = 21) +
  scale_fill_gradientn(colours = brewer.pal(10, 'RdYlBu'),
                          limits = c(-max(abs(x$logFC)),
                                    max(abs(x$logFC)))) +
  theme_xgrid() +
  xlab('log(fold change)')

x %>% 
    ggvis(y = ~logFC,
          x = ~tissue) %>% 
  layer_bars()

