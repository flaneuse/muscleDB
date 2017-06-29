data = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2017-04-23.rds')

data = data %>% select(transcript, tissue, expr) %>% spread(tissue, expr)

data = data %>% select(-transcript)

dendro = hclust(dist(t(data)))

dist_matrix = dist(t(data))

dist_matrix = as.matrix(dist_matrix)

dist_matrix =  data.frame(dist_matrix) %>% 
  mutate(tissue1 = row.names(dist_matrix))%>% 
  gather(tissue2, dist, -tissue1) %>% 
  mutate(tissue2 = stringr::str_replace_all(tissue2, '\\.', ' '))


tissue_order = dendro$labels[dendro$order]


dist_matrix$tissue1 = factor(dist_matrix$tissue1, levels = tissue_order)
dist_matrix$tissue2 = factor(dist_matrix$tissue2, levels = tissue_order)



ggplot(dist_matrix, aes(x = tissue1, y = tissue2, fill = dist)) +
  geom_tile(color = 'white', size = 0.2) +
  scale_fill_gradientn(name = 'distance',
                       colors = brewer.pal(9, 'Blues')) +
  coord_equal() +
  ggtitle('Euclidean distance matrix') + 
  scale_x_discrete(position = 'bottom') +
  theme_xylab(legend.position = 'bottom') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


library(readxl)
diff = read_excel('~/Downloads/Pairwise DiffExp.xlsx', sheet = 2)
diff = diff %>% 
  rename(tissue1 = X__1) %>% 
  gather(tissue2, dist, -tissue1)


diff$tissue1 = factor(diff$tissue1, levels = tissue_order)
diff$tissue2 = factor(diff$tissue2, levels = tissue_order)



ggplot(diff, aes(x = tissue1, y = tissue2, fill = dist)) +
  geom_tile(color = 'white', size = 0.2) +
  scale_fill_gradientn(name = 'percent differentially expressed',
                       colors = brewer.pal(9, 'Blues')) +
  coord_equal() +
  ggtitle('Differentially expressed tissues') + 
  scale_x_discrete(position = 'bottom') +
  theme_xylab(legend.position = 'bottom') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  