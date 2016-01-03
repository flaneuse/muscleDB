library(dplyr)
library(tidyr)
library(shiny)
library(shinydashboard)
library(DT)
library(d3heatmap)
library(ggvis)
library(ggplot2)
library(data.table)

# Import in the Muscle Transcriptome database -----------------------------

# mt_source = src_sqlite('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2015-11-08.sqlite3', create = FALSE)
# data = tbl(mt_source, 'MT')

data = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_public_2016-01-02.rds')
# data = data %>% 
  # slice(1:2500)

# Set the maximum of the expression, for the limits on the expr widget.
maxInit = max(data$expr)