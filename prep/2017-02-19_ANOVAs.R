# Overall wrapper function to calculate ANOVAs for muscle tissues.

# For ANOVAs, don't run through EVERY ANOVA calc; merely run through:
# 1. all tissues
# 2. all pairwise interactions
# 3. all skeletal muscles
# 4. all smooth muscles
# 5. all striated muscles
# 6. all cardiac muscles


# Import function to loop through the ANOVA calculations.
setwd('~/GitHub/muscleDB/prep/')
source('ANOVAlookupTable.r')
library(readxl) # reading in excel files.
library(dplyr)

# define muscle codes -----------------------------------------------------
skelMuscles = c('DIA', 'EDL', 'EYE', 'SOL', 'TON','FDB', 'MAS', 'PLA', 'TAN', 'QUAD', 'GAS')
smoothMuscles = c('TA', 'AA', 'AOR')
cardiacMuscles = c('ATR', 'LV', 'RV')
striatedMuscles = c(cardiacMuscles, skelMuscles)
allMusc = c(skelMuscles, smoothMuscles, cardiacMuscles)


# define raw data file ----------------------------------------------------
# rawDataFile = '~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants.csv'
rawDataFile = '~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants (Feb 2017 update).xlsx'
outputDir = '~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/ANOVAs/'


# import raw data  --------------------------------------------------------
rawdata = read_excel(rawDataFile)

rawdata = rawdata %>% 
  select(Transcript, Coordinates, Length, contains('MIN_ANTI'))

# Convert to a matrix; ANOVAs will only work w/ matrix output
rawdata = as.matrix(rawdata)

# 1. run ALL TISSUES ------------------------------------------------------
anovas = ANOVAlookupTable(rawdata, muscles = allMusc, onlyPairwise = TRUE, n = length(allMusc))
saveRDS(anovas, paste0(outputDir, 'allANOVAs_2017-02-19.rds'))
write.csv(anovas, paste0(outputDir,'allANOVAs_2017-02-19.csv'))


# 2. run ALL PAIRWISE -----------------------------------------------------

anovas = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, muscles = allMusc, n = 2)
saveRDS(anovas, paste0(outputDir,'pairwiseANOVAs_2017-02-19.rds'))
write.csv(anovas, paste0(outputDir,'pairwiseANOVAs_2017-02-19.csv'))


# 3. SMOOTH ---------------------------------------------------------------
smooth = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(smoothMuscles), muscles = smoothMuscles)
write.csv(smooth, paste0(outputDir,'allSmoothANOVAs_2017-02-19.csv'))
saveRDS(smooth, paste0(outputDir,'allSmoothANOVAs_2017-02-19.rds'))



# 4. CARDIAC --------------------------------------------------------------

card = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(cardiacMuscles), muscles = cardiacMuscles)
write.csv(card, paste0(outputDir,'allCardiacANOVAs_2017-02-19.csv'))
saveRDS(card, paste0(outputDir,'allCardiacANOVAs_2017-02-19.rds'))


# 5. SKELETAL -------------------------------------------------------------

skel = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(skelMuscles), muscles = skelMuscles)
saveRDS(skel, paste0(outputDir,'allSkelANOVAs_2017-02-19.rds'))
write.csv(skel, paste0(outputDir,'allSkelANOVAs_2017-02-19.csv'))


# 6. STRIATED -------------------------------------------------------------

striated = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(striatedMuscles), muscles = striatedMuscles)
write.csv(striated, paste0(outputDir,'allStriatedANOVAs_2017-02-19.csv'))
saveRDS(striated, paste0(outputDir,'allStriatedANOVAs_2017-02-19.rds'))




# MERGE DATA --------------------------------------------------------------


# Merge all together.
anovas = readRDS(paste0(outputDir, 'allANOVAs_2017-02-19.rds'))
anovas = data.frame(transcript = row.names(anovas), anovas)

striated = readRDS(paste0(outputDir,'allStriatedANOVAs_2017-02-19.rds'))
striated = data.frame(transcript = row.names(striated), striated)

cardiac = readRDS(paste0(outputDir,'allCardiacANOVAs_2017-02-19.rds'))
cardiac = data.frame(transcript = row.names(cardiac), cardiac)

skeletal = readRDS(paste0(outputDir,'allSkelANOVAs_2017-02-19.rds'))
skeletal = data.frame(transcript = row.names(skeletal), skeletal)

smooth = readRDS('allSmoothANOVAs_2017-02-19.rds')
smooth = data.frame(transcript = row.names(smooth), smooth)


pairwise = readRDS(paste0(outputDir,'pairwiseANOVAs_trimmed_2017-02-19.rds'))
pairwise = data.frame(transcript = row.names(pairwise), pairwise)


# Merge files together ----------------------------------------------------


allANOVAs = full_join(pairwise, smooth)
allANOVAs = full_join(allANOVAs, cardiac)
allANOVAs = full_join(allANOVAs, skeletal)
allANOVAs = full_join(allANOVAs, striated)
allANOVAs = full_join(allANOVAs, anovas)

write.csv(allANOVAs, paste0(outputDir,'allANOVAs_merged_2017-02-19.csv'))
saveRDS(allANOVAs, paste0(outputDir,'allANOVAs_merged_2017-02-19.rds'))

