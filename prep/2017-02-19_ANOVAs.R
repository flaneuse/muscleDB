# Overall wrapper function to calculate ANOVAs for muscle tissues.

# For ANOVAs, don't run through EVERY ANOVA calc; merely run through:
# 1. all tissues
# 2. all pairwise interactions
# 3. all skeletal muscles
# 4. all smooth muscles
# 5. all striated muscles
# 6. all cardiac muscles


# Import function to loop through the ANOVA calculations.
setwd('~/Documents/GitHub/muscleDB/prep/')
source('ANOVAlookupTable.r')
library(readxl) # reading in excel files.
library(dplyr)

# define muscle codes -----------------------------------------------------
skelMuscles = c('DIA', 'EDL', 'EYE', 'SOL', 'TON','FDB', 'MAS', 'PLA', 'TAN', 'QUAD', 'GAS')
smoothMuscles = c('TA', 'AA', 'AOR')
cardiacMuscles = c('ATR', 'LV', 'RV')
striatedMuscles = c(cardiacMuscles, skelMuscles)
allMusc = c(skelMuscles, smoothMuscles, cardiacMuscles)

minExpr = 1e-3 # minimum detectable expression.  All 0s replaced by minExpr.

# define raw data file ----------------------------------------------------
# rawDataFile = '~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants.csv'
rawDataFile = '~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/Muscle_Re-run_Mapstats_Quantfiles/MT_adjusted_TranscriptQuants (Feb 2017 update).xlsx'
outputDir = '~/Dropbox/Muscle Transcriptome Atlas/RUM_Re-analysis/ANOVAs/'


# import raw data  --------------------------------------------------------
importeddata = read_excel(rawDataFile)

# MAKE SURE THERE'S NO GUNK AT THE BOTTOM OF THE SHEET.
rawdata = importeddata %>% 
  select(Transcript, Coordinates, Length, contains('MIN_ANTI')) %>% 
  filter(!is.na(Transcript))

rawdata = lapply(rawdata, function(x) ifelse(x == 0, minExpr, x))

rawdata = lapply(rawdata, 
                 function(x) if(is.numeric(x)) {
                   log2(x)} else {
                     x
                   })

# Convert back from series of lists to a data frame.
rawdata = data.frame(rawdata)

# works but SUPER slow.
# rawdata = rawdata %>%
#   group_by(Transcript, Coordinates, Length) %>%  # group by to avoid log2 transform
#   mutate_all(funs(ifelse(. == 0, minExpr, .))) %>%
#   # Convert raw transcript expression to log-base-2 expression for more normal distribution (2017-04-15)
#   mutate_all(funs(log2(.)))

# Double check that the values are transformed correctly
# library(ggplot2)
# ggplot2::ggplot(rawdata, aes(x = GAS5_MIN_ANTI)) + geom_histogram(binwidth = 0.5)
# 
# ggplot2::qplot(x = rawdata$LV6_MIN_ANTI, y = importeddata$LV6_MIN_ANTI[1:nrow(rawdata)])
# ggplot2::ggplot(data = rawdata, aes(x = 2^rawdata$LV6_MIN_ANTI, y = importeddata$LV6_MIN_ANTI[1:nrow(rawdata)])) + geom_point(size = 3, alpha = 0.05)

# Convert to a matrix; ANOVAs will only work w/ matrix output
rawdata = as.matrix(rawdata)

# Make sure to rename the row names as the first column.
row.names(rawdata) = rawdata[,'Transcript']

# 1. run ALL TISSUES ------------------------------------------------------
anovas = ANOVAlookupTable(rawdata, muscles = allMusc, onlyPairwise = TRUE, n = length(allMusc))
saveRDS(anovas, paste0(outputDir, 'allANOVAs_2017-04-15.rds'))
write.csv(anovas, paste0(outputDir,'allANOVAs_2017-04-15.csv'))


# 2. run ALL PAIRWISE -----------------------------------------------------

pairwise = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, muscles = allMusc, n = 2)
saveRDS(pairwise, paste0(outputDir,'pairwiseANOVAs_2017-04-15.rds'))
write.csv(pairwise, paste0(outputDir,'pairwiseANOVAs_2017-04-15.csv'))


# 3. SMOOTH ---------------------------------------------------------------
smooth = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(smoothMuscles), muscles = smoothMuscles)
write.csv(smooth, paste0(outputDir,'allSmoothANOVAs_2017-04-15.csv'))
saveRDS(smooth, paste0(outputDir,'allSmoothANOVAs_2017-04-15.rds'))



# 4. CARDIAC --------------------------------------------------------------

card = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(cardiacMuscles), muscles = cardiacMuscles)
write.csv(card, paste0(outputDir,'allCardiacANOVAs_2017-04-15.csv'))
saveRDS(card, paste0(outputDir,'allCardiacANOVAs_2017-04-15.rds'))


# 5. SKELETAL -------------------------------------------------------------

skel = ANOVAlookupTable(rawdata, onlyPairwi  se = TRUE, n = length(skelMuscles), muscles = skelMuscles)
saveRDS(skel, paste0(outputDir,'allSkelANOVAs_2017-04-15.rds'))
write.csv(skel, paste0(outputDir,'allSkelANOVAs_2017-04-15.csv'))


# 6. STRIATED -------------------------------------------------------------

striated = ANOVAlookupTable(rawdata, onlyPairwise = TRUE, n = length(striatedMuscles), muscles = striatedMuscles)
write.csv(striated, paste0(outputDir,'allStriatedANOVAs_2017-04-15.csv'))
saveRDS(striated, paste0(outputDir,'allStriatedANOVAs_2017-04-15.rds'))




# MERGE DATA --------------------------------------------------------------


# Merge all together.
anovas = readRDS(paste0(outputDir, 'allANOVAs_2017-04-15.rds'))
anovas = data.frame(transcript = row.names(anovas), anovas)

striated = readRDS(paste0(outputDir,'allStriatedANOVAs_2017-04-15.rds'))
striated = data.frame(transcript = row.names(striated), striated)

cardiac = readRDS(paste0(outputDir,'allCardiacANOVAs_2017-04-15.rds'))
cardiac = data.frame(transcript = row.names(cardiac), cardiac)

skeletal = readRDS(paste0(outputDir,'allSkelANOVAs_2017-04-15.rds'))
skeletal = data.frame(transcript = row.names(skeletal), skeletal)

smooth = readRDS('allSmoothANOVAs_2017-04-15.rds')
smooth = data.frame(transcript = row.names(smooth), smooth)


pairwise = readRDS(paste0(outputDir,'pairwiseANOVAs_2017-04-15.rds'))
pairwise = data.frame(transcript = row.names(pairwise), pairwise)


# Merge files together ----------------------------------------------------


allANOVAs = full_join(pairwise, smooth)
allANOVAs = full_join(allANOVAs, cardiac)
allANOVAs = full_join(allANOVAs, skeletal)
allANOVAs = full_join(allANOVAs, striated)
allANOVAs = full_join(allANOVAs, anovas)

write.csv(allANOVAs, paste0(outputDir,'allANOVAs_merged_2017-04-15.csv'))
saveRDS(allANOVAs, paste0(outputDir,'allANOVAs_merged_2017-04-15.rds'))

