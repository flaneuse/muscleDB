# Data prep for MuscleDB, to pull relevant values and get ready for Shiny app
# Laura Hughes, laura.d.hughes@gmail.com
# updated 2017-02-19

library(RSQLite)
library(stringr)
library(dplyr)
library(tidyr)
library(readr)
library(data.table)
library(readxl)

# Import and clean data.


# Import averages and SEs. ------------------------------------------------
# df <- read.delim("~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/Expression_Levels_for_webpage(10-6-15).txt")
# df <- read_excel("~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants (Feb 2017 update).xlsx")
df = read.csv('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/Fixed SEs TAN QUAD GAS.csv')

# Filter out any NA values
df = df %>% 
  filter(!is.na(Transcript), Transcript != "")


numTranscripts = nrow(df)

# Pull out the averages and gather ----------------------------------------
avg = df %>% 
  select(transcript = Transcript, 
         # transcript means
         atria = ATR_mean, `left ventricle` = LV_mean,
         `total aorta` = AOR_mean, `right ventricle` = RV_mean,
         soleus = SOL_mean, `thoracic aorta` = TA_mean, 
         `abdominal aorta`  = AA_mean, diaphragm = DIA_mean,
         eye = EYE_mean, EDL = EDL_mean, FDB = FDB_mean, 
         masseter = MAS_mean, plantaris = PLA_mean, 
         tongue = TON_mean,
         `tibialis anterior` = TAN_mean, quadriceps = Quad_Mean, gastrocnemius = GAS_mean
         ) %>% 
  mutate(id = 1:numTranscripts) %>% 
  gather(tissue, expr, -transcript, -id)


# Pull out SE and gather --------------------------------------------------
SE = df %>% 
  select(transcript = Transcript, 
         
         # transcript standard errors
         atria = ATR_standard_error, `left ventricle` = LV_standard_error,
         `total aorta` = AOR_standard_error, `right ventricle` = RV_standard_error,
         soleus = SOL_standard_error, `thoracic aorta` = TA_standard_error, 
         `abdominal aorta`  = AA_standard_error, diaphragm = DIA_standard_error,
         eye = EYE_standard_error, EDL = EDL_standard_error, FDB = FDB_standard_error, 
         masseter = MAS_standard_error, plantaris = PLA_standard_error, 
         tongue = TON_standard_error,
         `tibialis anterior` = TAN_standarderror, 
         quadriceps = Quad_standarderror, gastrocnemius = GAS_standarderror) %>% 
  gather(tissue, SE, -transcript)


#! Need to spot check that everything is done properly.
#! SE, stdev, 95% CI, ...?



# Calculate q-values ------------------------------------------------------
# Run previously; then imported.

# 2017-02-19
# Full query of the entire dataset to calculate all the ANOVAs.  
# Takes quite awhile to run, so run before.
# source('~/GitHub/muscle-transcriptome/prep/2017-02-19_ANOVAs.R')

# source('~/GitHub/muscle-transcriptome/prep/ANOVAlookupTable.r')

# anovas = ANOVAlookupTable('~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants.csv', 6)



# Pull in the outdated data to get GO and gene names ----------------------
# oldFile = '~/Dropbox/Muscle Transcriptome Atlas/Website files/MTapp-v0-51/data/combData_2014-10-19.rds'

# Updated by Scott 
ont_file = '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/MOUSE_RUM_Transcripts+.xlsx'

geneInfo = read_excel(ont_file) %>% 
  filter(!is.na(GO)) %>%
  select(transcript, geneSymbol, GO, EntrezLink, UCSCLink) %>% 
  # mutate(uc = str_extract(Transcript, 'uc......'), # Remove extra crap from transcript ids
         # NM = str_extract(Transcript, 'N...............')) %>% 
  # mutate(transcript = ifelse(is.na(uc), NM, uc), # tidying up transcript name.
  
  # mutate(geneLink = ifelse(geneSymbol == "", # Gene symbol w/ link to entrez page.
                           # "", paste0("<a href = '", EntrezLink, 
                                      # "' target = '_blank'>", geneSymbol, "</a>")), 
         # transcriptLink = ifelse(UCSCLink == "",
                                 # transcript, 
                                 # paste0("<a href = '", UCSCLink,
                                        # "' target = '_blank'>", transcript, "</a>")) # transcript name w/ link to UCSC page
  # ) %>% 
  select(transcript, gene = geneSymbol, GO, geneLink = EntrezLink, transcriptLink = UCSCLink)

# save ontology
write_rds(geneInfo, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/geneOntology_2017-04.rds')

# save master list of ontology terms for website
ont_terms = stringr::str_split(geneInfo$GO, pattern = '\\|')

ont_terms = unique(unlist(ont_terms))

write_rds(ont_terms, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/allOntologyTerms.rds')

# Merge everything together -----------------------------------------------
df = full_join(avg, SE, by = c("transcript", "tissue")) %>% 
  mutate(
    lb = expr - SE,
    ub = expr + SE)

if(nrow(df) != nrow(avg) | nrow(df) != nrow(SE)) {
  warning("Merge wasn't successful")
}


# Merge in ANOVAs ---------------------------------------------------------
anovas = readRDS('~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/ANOVAs/allANOVAs_merged_2017-04-15.rds')

anovas = anovas %>% 
  # select(-transcript.1) %>% 
  group_by(transcript) %>% 
  select(-contains('_p')) %>% 
  mutate_each(funs(signif(., digits = 3)))


# Merge
df = full_join(df, anovas, by = 'transcript')
  
if(nrow(df) != nrow(avg) | nrow(df) != nrow(SE)) {
  warning("Merge wasn't successful")
}

# Clean the transcript IDs into shortened versions ------------------------
df = df %>% mutate(uc = str_extract(df$transcript, 'uc......'),
                                 NM = str_extract(df$transcript, 'N...............')) %>% 
  mutate(fullTranscript = transcript, 
         expr = round(expr, digits = 2),
         SE = round(SE, digits = 2),
         lb = round(lb, digits = 2),
         ub = round(ub, digits = 2),
         transcript = ifelse(is.na(uc), NM, uc)) %>% 
  select(-fullTranscript, -uc, -NM)


# Merge in GO, ontology
df = left_join(df, geneInfo, by = c("transcript" = "transcript"))

# create shortened ID
df = df %>% 
  mutate(shortName = ifelse(is.na(gene), transcript, gene))


# refactorise the tissue levels.
df$tissue = factor(df$tissue,
                   c('total aorta' = 'total aorta',
                     'thoracic aorta' = 'thoracic aorta',
                     'abdominal aorta' = 'abdominal aorta',
                     'atria' = 'atria', 
                     'left ventricle' = 'left ventricle',
                     'right ventricle' = 'right ventricle',
                     'diaphragm' = 'diaphragm',
                     'eye' = 'eye', 
                     'EDL' = 'EDL', 
                     'FDB' = 'FDB',
                     'gastrocnemius' = 'gastrocnemius',
                     'masseter' =  'masseter',
                     'plantaris' = 'plantaris',
                     'quadriceps' = 'quadriceps',
                     'soleus' = 'soleus',
                     'tibialis anterior' = 'tibialis anterior',
                     'tongue' = 'tongue'))




# save files --------------------------------------------------------------

saveRDS(df, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2017-04-16.rds')
write_csv(df, '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2017-04-16.csv')

# Copy to sqlite db -------------------------------------------------------
# db = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2017-02-19.sqlite3',
#                 create = TRUE)
# 
# data_sqlite = copy_to(db, df_public, temporary = FALSE,
#                       name = 'MT',
#                       indexes = list('expr', 'transcript', 'tissue'))



# Create small version ----------------------------------------------------

