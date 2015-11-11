library(dplyr)
library(tidyr)
library(shiny)
library(shinydashboard)
library(dplyr)
library(DT)
library(d3heatmap)
library(ggvis)
library(ggplot2)
library(RSQLite)

# Import in the Muscle Transcriptome database -----------------------------

mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3', create = FALSE)
data = tbl(mt_source, 'MT')
maxInit = 27000