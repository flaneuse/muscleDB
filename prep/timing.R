library(profvis)
library(microbenchmark)
library(readr)

mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3', create = FALSE)
data = tbl(mt_source, 'MT')

x = proc.time()

data %>% 
  filter(expr > 10000) %>% 
  collect()

print(proc.time() - x)


profvis(data%>% 
          filter(expr > 100) %>% 
          collect())
# 20 ms

microbenchmark(df_public%>% 
                 filter(expr > 100) %>% 
                 collect())

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



# 2016-01-02 --------------------------------------------------------------
mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2016-01-02.sqlite3')
csvFile = '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2016-01-02.csv'
rdsFile = '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2016-01-02.rds'

microbenchmark(mt_source = 
                 src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2016-01-02.sqlite3'),
               data = tbl(mt_source, 'MT'), times = 5)   

# Unit: milliseconds
# expr       min        lq      mean    median        uq       max neval cld
# mt_source  1.587156  1.624611  1.868068  1.882497  2.097639  2.148436     5  a 
# data 27.236683 27.561139 28.377779 28.836713 29.035498 29.218864     5   b


testSQL = function() {
  mt_source2 = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2016-01-02.sqlite3')
  data = tbl(mt_source2, 'MT')
}

microbenchmark(testSQL(), times = 5)   
# Unit: milliseconds
# expr      min       lq     mean   median       uq      max neval
# testSQL() 31.55138 32.19742 40.90228 32.22655 52.20697 56.32906     5

microbenchmark(read_csv(csvFile), times = 5)  
# Unit: seconds
# expr      min       lq     mean   median       uq      max neval
# read_csv(csvFile) 7.119855 7.591674 8.178306 7.734527 7.742967 10.70251     5


microbenchmark(read.csv(csvFile), times = 5)  
# Unit: seconds
# expr      min       lq     mean   median       uq      max neval
# read.csv(csvFile) 67.07867 67.52327 70.97954 68.93592 75.10657 76.25324     5

microbenchmark(fread(csvFile), times = 5)  
# Unit: seconds
# expr      min       lq     mean   median      uq      max neval
# fread(csvFile) 5.048835 5.085546 5.224239 5.244558 5.30128 5.440977     5

microbenchmark(readRDS(rdsFile), times = 5)
# Unit: seconds
# expr      min       lq     mean   median       uq      max neval
# readRDS(rdsFile) 1.816742 1.844397 1.917542 1.887949 1.994142 2.044478     5

microbenchmark(read_rds(rdsFile), times = 5)
# Unit: seconds
# expr      min       lq     mean   median       uq      max neval
# read_rds(rdsFile) 1.823947 1.905809 1.967962 1.920554 2.081367 2.108134     5

# Conclusion: by microbenchmark, seems VERY clear that loading SQL file <<< read_rds ~= readRDS < fread < read_csv


# Test: 2016-01-02: Accessing data within. --------------------------------



# data.tables test: 2016-01-02 --------------------------------------------
# Checking how melt and reshape compare b/w data.tables and tidyr
data1 = data %>% 
  select(transcript = transcriptLink, gene = geneLink, tissue, expr, id, LV.PLA_q)
data2 = data.table(data1)

#tidyr
microbenchmark(x = data1 %>%  
                 spread(tissue, expr) %>% 
                 select(-id), times = 5)
# Unit: seconds
# expr     min       lq     mean   median       uq      max neval
# x 3.35939 3.371684 3.686335 3.632538 3.954592 4.113469     5



# as data.table
microbenchmark(y = data2 %>% 
                 spread(tissue, expr) %>% 
                 select(-id), times = 5)

# Unit: seconds
# expr      min       lq     mean   median       uq      max neval
# x 3.364923 3.666169 3.785398 3.691737 3.951036 4.253124     5


# data.table
microbenchmark(x = data.table::dcast(data1, transcript + gene + id + LV.PLA_q ~ tissue, value.var = 'expr'),
               times = 5)
# Unit: seconds
# expr      min       lq     mean   median       uq      max neval
# x 3.211758 3.396247 3.461231 3.418552 3.574601 3.704999     5

# dt, as data.table

microbenchmark(x = data.table::dcast(data2, transcript + gene + id + LV.PLA_q ~ tissue, value.var = 'expr'),
               times = 5)
# Unit: milliseconds
# expr      min       lq     mean   median       uq      max neval
# x 639.4798 657.0914 677.4345 676.1142 697.2487 717.2387     5


# data.tables vs. dplyr: filtering ----------------------------------------
microbenchmark(x = data[expr > 1000,], times = 20)
# Unit: milliseconds
# expr      min       lq     mean   median       uq      max neval
# x 7.038254 7.188981 7.524891 7.470954 7.575805 8.611422    20

microbenchmark(x = data %>% filter(expr > 1000), times = 20)
# Unit: milliseconds
# expr      min       lq     mean   median       uq     max neval
# x 10.01758 11.65281 12.06868 11.84012 12.77642 13.8705    20

muscles = c('diaphragm', 'EDL', 'eye',
            'FDB', 
            'soleus', 'plantaris')
geneInput = 'uc0'
ont = 'process'

muscleSymbols = plyr::mapvalues(muscles,
                                from = c('atria', 'left ventricle',
                                         'total aorta', 'right ventricle',
                                         'soleus', 
                                         'diaphragm',
                                         'eye', 'EDL', 'FDB', 
                                         'plantaris'),
                                to = c('ATR', 'LV',
                                       'AOR', 'RV',
                                       'SOL', 'DIA',
                                       'EYE', 'EDL',
                                       'FDB', 'PLA'))

qCol = paste0(paste0(sort(muscleSymbols), collapse = '.'), '_q')

microbenchmark(data[expr > 1000 & 
                      tissue %in% muscles &
                      transcript %like% geneInput &
                      GO %like% GO &
                      `DIA.EDL.EYE.FDB.PLA.SOL_q` < 1e-5, ], times = 30)
# Unit: milliseconds
# expr
# data[expr > 1000 & tissue %in% muscles & transcript %like% geneInput &      GO %like% GO & DIA.EDL.EYE.FDB.PLA.SOL_q < 1e-05, ]
# min       lq     mean   median       uq      max neval
# 306.497 315.8089 329.4008 321.3758 333.1114 466.5269    30

microbenchmark(data %>% filter(expr > 1000,
                               tissue %in% muscles,
                               transcript %like% geneInput,
                               GO %like% GO,
                               `DIA.EDL.EYE.FDB.PLA.SOL_q` < 1e-5),
               times = 30)

# Unit: milliseconds
# expr
# data %>% filter(expr > 1000, tissue %in% muscles, transcript %like%      geneInput, GO %like% GO, DIA.EDL.EYE.FDB.PLA.SOL_q < 1e-05)
# min       lq     mean   median       uq      max neval
# 304.6636 310.1527 322.5199 320.1557 324.6389 456.4683    30

# Pretty similar-- regardless of data.frame or data.table.  Faster for indiv. operation as dt, but when string together, doesn't seem to make a diff.


# testing splitting q values ----------------------------------------------

microbenchmark(data %>% filter())

# Small version of data ---------------------------------------------------

data = readRDS('data/expr_2016-04-10.rds') %>% 
  select(-id)


df = data %>% 
  filter(!(transcript %like% 'NM'),
         transcript %like% 'uc00')

saveRDS(df, 'data/expr_2016-04-10_small.rds')


# test inputs -------------------------------------------------------------

input = NULL
input$geneInput = 'uc0'
input$GO = 'kinase'
input$ref = 'left ventricle'
input$muscles = c('atria', 'left ventricle',
                  'total aorta', 'right ventricle',
                  'soleus', 
                  'diaphragm',
                  'eye', 'EDL', 'FDB',
                  'thoracic aorta', 'abdominal aorta',
                  'tongue', 'masseter',
                  'plantaris')
input$qVal = 1
input$tabs = 'notVolcano'
input$adv = TRUE
input$maxExprVal = 1e6
input$minExprVal = 1


# data prep
geneInput = paste0('^', input$geneInput)

if(is.null(input$GO)){
  ont = ""
} else {
  ont = input$GO
}

# For fold change, adding in the FC-selected muscle if it's not already in the list
if(input$tabs == 'volcano') {# volcano plot     
  # Select 2 muscles from the user input.
  selMuscles = unique(c(input$muscle1, input$muscle2))
} else if(input$adv == TRUE & input$ref != 'none') {
  selMuscles = unique(c(input$ref, input$muscles))
} else { 
  selMuscles = input$muscles
}

# Generate key for muscles
muscleSymbols = plyr::mapvalues(selMuscles,
                                from = c('atria', 'left ventricle',
                                         'total aorta', 'right ventricle',
                                         'soleus', 
                                         'diaphragm',
                                         'eye', 'EDL', 'FDB',
                                         'thoracic aorta', 'abdominal aorta',
                                         'tongue', 'masseter',
                                         'plantaris'),
                                to = c('ATR', 'LV',
                                       'AOR', 'RV',
                                       'SOL', 'DIA',
                                       'EYE', 'EDL', 'FDB',
                                       'TA', 'AA', 
                                       'TON', 'MAS',
                                       'PLA'),
                                warn_missing = FALSE)


qCol = paste0(paste0(sort(muscleSymbols), collapse = '.'), '_q')




# testing two split db ----------------------------------------------------
library(tidyr)
library(dplyr)
library(data.table)
library(microbenchmark)

data = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2016-04-10.rds')

GOs = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/allOntologyTerms.rds')

# split data into two tables
qVals = data %>% 
  select(id, contains('q')) %>% 
  distinct()

smData = data %>% 
  select(-contains('q'))


# Basic filtering / merging

filtered = data %>% 
  select_("-contains('_q')", q = qCol) %>% 
  filter(tissue %in% selMuscles,   # muscles
         grepl(eval(geneInput), transcript, ignore.case = TRUE),  # gene symbol
         GO %like% ont,               # gene ontology
         q < input$qVal)

# Baseline: all data Unit: milliseconds
# min      lq     mean  median       uq      max neval
# 491.7325 504.276 518.0987 512.013 540.5665 553.0165    10
# 480.541 489.2287 494.8896 493.1172 497.3798 521.3991    10
microbenchmark(data %>% 
                 select_("-contains('_q')", q = qCol) %>% 
                 filter(tissue %in% selMuscles,   # muscles
                        grepl(eval(geneInput), transcript, ignore.case = TRUE),  # gene symbol
                        GO %like% ont,               # gene ontology
                        q < input$qVal), times = 10)

# min       lq    mean   median       uq      max neval
# 529.3549 547.9918 570.042 566.4815 574.8051 631.8543    10
# No GO: 515.1447 518.1921 530.573 526.3044 531.0613 588.7164    10
microbenchmark({
  filtered = smData %>% 
    filter(tissue %in% selMuscles,   # muscles
           grepl(eval(geneInput), transcript, ignore.case = TRUE),  # gene symbol
           GO %like% ont)
  
  filteredQ = qVals %>% 
    select_('id', q = qCol) %>% 
    filter(q < input$qVal)
  
  filtered = filtered %>% 
    filter(id %in% filteredQ$id)
  
  left_join(filtered, filteredQ, by = 'id')
  
}, times = 10)
