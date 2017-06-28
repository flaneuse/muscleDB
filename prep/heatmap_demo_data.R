library(data.table)
library(dplyr)
library(tidyr)

data = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2017-04-23.rds')

# filter out just the data for 'Hox' genes
df = data %>% 
  filter(gene %like% 'Hox') %>% 
  select(transcript, shortName, gene, tissue, expr) %>% 
  spread(tissue, expr)

df = df %>% select(-X)

write.csv(df, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/heatmap_demo.csv')
