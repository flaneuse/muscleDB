library(RSQLite)
library(stringr)
library(dplyr)
library(tidyr)


# Import and clean data.


# Import averages and SEs. ------------------------------------------------
df <- read.delim("~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/Expression_Levels_for_webpage(10-6-15).txt")


numTranscripts = nrow(df)

# Pull out the averages and gather ----------------------------------------
avg = df %>% 
  select(transcript = Transcript, atria = ATR_mean, `left ventricle` = LV_mean,
         `total aorta` = AOR_mean, `right ventricle` = RV_mean,
         soleus = SOL_mean, `thoracic aorta` = TA_mean, 
         `abdominal aorta`  = AA_mean, diaphragm = DIA_mean,
         eye = EYE_mean, EDL = EDL_mean, FDB = FDB_mean, 
         masseter = MAS_mean, plantaris = PLA_mean, 
         tongue = TON_mean) %>% 
  mutate(id = 1:numTranscripts) %>% 
  gather(tissue, expr, -transcript, -id)


# Pull out SE and gather --------------------------------------------------
SE = df %>% 
  select(transcript = Transcript, atria = ATR_standard_error, `left ventricle` = LV_standard_error,
         `total aorta` = AOR_standard_error, `right ventricle` = RV_standard_error,
         soleus = SOL_standard_error, `thoracic aorta` = TA_standard_error, 
         `abdominal aorta`  = AA_standard_error, diaphragm = DIA_standard_error,
         eye = EYE_standard_error, EDL = EDL_standard_error, FDB = FDB_standard_error, 
         masseter = MAS_standard_error, plantaris = PLA_standard_error, 
         tongue = TON_standard_error) %>% 
  gather(tissue, SE, -transcript)


#! Need to spot check that everything is done properly.
#! SE, stdev, 95% CI, ...?
# Import GO and gene names ------------------------------------------------
geneInfo = readRDS("~/Dropbox/Muscle Transcriptome Atlas/Website files/MTapp-v0-51/data/combData_2014-10-19.rds")



# Calculate q-values ------------------------------------------------------
source('~/GitHub/muscle-transcriptome/prep/ANOVAlookupTable.r')

anovas = ANOVAlookupTable('~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants.csv', 6)

# Merge everything together -----------------------------------------------
df = full_join(avg, SE, by = c("transcript", "tissue")) %>% 
  mutate(
         lb = expr - SE,
         ub = expr + SE,
         shortName = 'foo',
         gene = 'fu',
         GO = 'moo',
         entrezLink = 'html',
         UCSCLink = 'html')




# ! Fix the UCSC links, etc.

saveRDS(df, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2015-10-11.rds')


# For the public version, remove 4 tissues.
anovasWeb = readRDS('~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/ANOVAs/allANOVAs_forWeb_2015-10-18.rds')

df_public = df %>% 
  filter(tissue != 'thoracic aorta', tissue != 'masseter', 
         tissue != 'abdominal aorta', tissue != 'tongue')

df_public = full_join(df_public, anovasWeb, by = 'transcript') %>% 
  select(-contains('_p'))


# Clean the transcript IDs into shortened versions ------------------------
df_public = df_public %>% mutate(uc = str_extract(df_public$transcript, 'uc......'),
                   NM = str_extract(df_public$transcript, 'N...........')) %>% 
  mutate(fullTranscript = transcript, 
         transcript = ifelse(is.na(uc), NM, uc)) %>% 
  select(-fullTranscript, -uc, -NM)

saveRDS(df_public, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.rds')


# Copy to sqlite db -------------------------------------------------------
db = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3',
                create = TRUE)

data_sqlite = copy_to(db, df_public, temporary = FALSE,
                      name = 'MT',
                      indexes = list('expr', 'transcript', 'tissue'))