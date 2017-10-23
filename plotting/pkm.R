df = data  %>% filter(gene == 'Pkm', !(tissue %in% c('tibialis anterior', 'gastrocnemius', 'quadriceps')), transcript == 'uc009pyh')


ggplot(df, aes(x = forcats::fct_reorder(tissue, expr), y = expr, fill = expr)) + 
  # lollipops
  geom_segment(aes(x = forcats::fct_reorder(tissue, expr), 
                   xend = forcats::fct_reorder(tissue, expr),
                   y = 0, yend = expr), colour = grey90K,
               size = 0.1) +
  # error bars
  geom_segment(aes(x = forcats::fct_reorder(tissue, expr), 
                   xend = forcats::fct_reorder(tissue, expr),
                   y = lb, yend = ub), 
               size = 1.5,
               colour = grey50K, alpha = 0.5) +
  # points
  geom_point(size = 3, colour = grey90K, stroke = 0.1, shape = 21) + 
  scale_fill_gradientn(colours = brewer.pal(9, "BuPu")) +
  # facet_wrap(~transcript) + 
  coord_flip() + 
  ylab('gene expression (FPKM)') +
  ggtitle('Pkm gene is implicated in myotonic dystrophy') +
  theme_xgrid()

save_plot('~/Desktop/pkm.pdf', height = 3, width = 6)