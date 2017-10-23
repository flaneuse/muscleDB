df = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2017-04-23.rds')
library(dplyr)
library(tidyr)

expr = read.csv('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/Fixed SEs TAN QUAD GAS.csv')

expr = expr %>% 
  select(Transcript, contains('ATR'), contains('LV'), contains('RV'), contains('AOR')) %>% 
  select(Transcript, contains('MIN_ANTI')) %>% 
  mutate(uc = str_extract(expr$Transcript, 'uc......'),
             NM = str_extract(expr$Transcript, 'N...............')) %>% 
  mutate(fullTranscript = Transcript, 
         transcript = ifelse(is.na(uc), NM, uc)) %>% 
  select(-uc, -NM, -fullTranscript, -Transcript)


df = df %>% 
  select(transcript, gene) %>% 
  distinct()


expr = left_join(expr, df, by = 'transcript')

colnames(expr) = str_replace_all(str_replace_all(str_replace_all(colnames(expr), 'MIN_ANTI', ''), '\\.', ''), '\\_', '')

gene_sample = expr %>% distinct(gene) %>% sample_n(100) %>% pull()

transcript_sample = expr %>% distinct(transcript) %>% sample_n(100) %>% pull()

expr = expr %>% filter(gene %in% gene_sample | transcript %in% transcript_sample) %>% arrange(gene)

write.csv(expr,'~/Documents/GitHub/ExpressionDB/data/sample_data2_muscledb.csv')
