# Import and clean data.


# Import averages and SEs. ------------------------------------------------
df <- read.delim("~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/Expression_Levels_for_webpage(10-6-15).txt")


# Pull out the averages and gather ----------------------------------------
avg = df %>% 
  select(Transcript, atria = ATR_mean, `left ventricle` = LV_mean,
         `total aorta` = AOR_mean, `right ventricle` = RV_mean,
         soleus = SOL_mean, `thoracic aorta` = TA_mean, 
         `abdominal aorta`  = AA_mean, diaphragm = DIA_mean,
         eye = EYE_mean, EDL = EDL_mean, FDB = FDB_mean, 
         masseter = MAS_mean, plantaris = PLA_mean, 
         tongue = TON_mean) %>% 
  gather(tissue, expr, -Transcript)


# Pull out SE and gather --------------------------------------------------
SE = df %>% 
  select(Transcript, atria = ATR_standard_error, `left ventricle` = LV_standard_error,
         `total aorta` = AOR_standard_error, `right ventricle` = RV_standard_error,
         soleus = SOL_standard_error, `thoracic aorta` = TA_standard_error, 
         `abdominal aorta`  = AA_standard_error, diaphragm = DIA_standard_error,
         eye = EYE_standard_error, EDL = EDL_standard_error, FDB = FDB_standard_error, 
         masseter = MAS_standard_error, plantaris = PLA_standard_error, 
         tongue = TON_standard_error) %>% 
  gather(tissue, SE, -Transcript)


#! Need to spot check that everything is done properly.
#! SE, stdev, 95% CI, ...?
# Import GO and gene names ------------------------------------------------
geneInfo = readRDS("~/Dropbox/Muscle Transcriptome Atlas/Website files/MTapp-v0-51/data/combData_2014-10-19.rds")



# Calculate q-values ------------------------------------------------------
source('~/GitHub/muscle-transcriptome/prep/ANOVAlookupTable.r')

anovas = ANOVAlookupTable('~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants.csv', 6)

# Merge everything together -----------------------------------------------
df = full_join(avg, SE, by = c("Transcript", "tissue")) %>% 
  mutate(lb = expr - SE,
         ub = expr + SE,
         shortName = 'foo',
         transcript = 'bar',
         gene = 'fu',
         GO = 'moo',
         entrezLink = 'html',
         USCSLink = 'html')

saveRDS(df, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2015-10-11.rds')