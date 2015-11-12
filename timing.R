mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3', create = FALSE)
data = tbl(mt_source, 'MT')

x = proc.time()

data %>% 
  filter(expr > 10000) %>% 
  collect()

print(proc.time() - x)


profvis(data %>% 
          filter(expr > 100) %>% 
          collect())
# 20 ms

data_rds = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.rds')

x = proc.time()

data_rds %>% 
  filter(expr > 100)

print(proc.time() - x)

profvis(data_rds %>% 
          filter(expr > 100))
