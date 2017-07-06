
# setup -------------------------------------------------------------------
library(tidyverse)
library(stringr)
library(data.table)

# import data -------------------------------------------------------------

data = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2017-04-23.rds')



# examine ontology distribution -------------------------------------------

ont =
  data %>% select(transcript, GO) %>% 
  distinct() %>% 
  rowwise() %>% 
  mutate(ct = length(stringr::str_extract_all(GO, '\\|')[[1]]) - 1) 

ont %>% 
  count(ct)


all_ont = str_split(ont$GO,'\\|')
all_ont2 = data.frame(ont = unlist(all_ont))

# all_ont2 = all_ont %>% ungroup() %>% gather(col, ont)

ont_hist = all_ont2 %>% count(ont) %>% arrange(desc(n)) %>% filter(!is.na(ont), ont != '')

ggplot(data = ont_hist %>% slice(1:15)) + 
  geom_bar(aes(y = n, x = forcats::fct_reorder(ont, n)), stat = 'identity') + 
  coord_flip() +
  ylab('number of transcripts') +
  xlab(' ')

# cluster by tissue -------------------------------------------------------
# spread wide
df = data %>% 
  select(transcript, GO, tissue, expr) %>% spread(tissue, expr)

dendro = NULL

ont = ont_hist$ont[1:35]

cluster = function(ont, df) {
  
  df2 = df %>% 
    filter(GO %like% paste0('^', ont, '\\|') |
            GO %like% paste0('\\|', ont, '\\|')) %>% 
    select(-transcript, -GO)
  
  print(paste('transcripts: ', nrow(df2)))
  
  dendro = hclust(dist(t(df2)))
}

for(i in 1:length(ont)) {
  print(i)
  dendro[[i]] = cluster(ont[i], df)
  
  plot(dendro[[i]], main = ont[i])
}

dd = dendro_data(dendro)
