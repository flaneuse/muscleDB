library(dplyr)
library(tidyr)
library(shiny)
library(shinydashboard)
library(DT)
library(d3heatmap)
library(ggvis)
library(ggplot2)
# library(rCharts)
library(dtplyr)
library(data.table)
library(llamar)
# library(plotly)
library(RColorBrewer)



# Source javascript pagination code ---------------------------------------
# Forked from https://github.com/wleepang/shiny-pager-ui
# source('pagerui.R')

# Import in the Muscle Transcriptome database -----------------------------

# Set the initial view to be the Myod1 gene, to save on processing time.
initGene = 'Myod1'

# mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3', create = FALSE)
# data = tbl(mt_source, 'MT')

data = readRDS('data/expr_2017-04-23.rds')

initData = data %>% filter(shortName %like% initGene)

GOs = readRDS("data/allOntologyTerms.rds")

# Set the maximum of the expression, for the limits on the expr widget.
maxInit = max(data$expr)

# List of tissues
tissueList = list('total aorta' = 'total aorta',
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
                'tongue' = 'tongue')

allTissues = c('atria', 'left ventricle',
               'total aorta', 'right ventricle',
               'soleus', 'tibialis anterior', 'quadriceps', 'gastrocnemius',
               'thoracic aorta',
               'abdominal aorta',
               'diaphragm',
               'eye', 'EDL', 'FDB', 
               'masseter', 'tongue',
               'plantaris')

# skelMuscles = c('DIA', 'EDL', 'EYE', 'SOL', 'TON','FDB', 'MAS', 'PLA', 'TAN', 'QUAD', 'GAS')
selTissues = c(
               'soleus', 'tibialis anterior', 'quadriceps', 
               'diaphragm',
               'eye', 'EDL', 'FDB', 'gastrocnemius',
               'masseter', 'tongue',
               'plantaris')

# shortNameList = unique(data$shortName)


# greys -------------------------------------------------------------------
grey10K = "#E6E7E8"
grey40K = "#a7a9ac"
grey50K = "#939598"
grey60K = "#808285"
grey90K = "#414042"
