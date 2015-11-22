library(profvis)

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


# loading -----------------------------------------------------------------
library(microbenchmark)
# base read.csv
microbenchmark(x = read.csv('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.csv'), 
               times = 1)

# readr read_csv
microbenchmark(read_csv('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.csv'), 
               times = 1)

# readRDS (4.2 s)
microbenchmark(readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.rds'), 
               times = 10)

# readr read_rds (4.6 - 4.8 s)
microbenchmark(read_rds('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.rds'), 
               times = 10)

# sqlite db
microbenchmark(mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3', create = FALSE),
data = tbl(mt_source, 'MT'), times = 10)

profvis(readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.rds'))

profvis(read_rds('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.rds'))
