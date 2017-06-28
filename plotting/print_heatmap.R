
# Creates a heatmap with clustering for use in static publications --------

# Laura Hughes, laura.d.hughes@gmail.com


# csv file name CHANGE ME!-----------------------------------------------------------
# File that's read in on line 75.  Note that Excel files can be read in with slight modifications
csv_file = '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/heatmap_demo.csv'


# import libraries --------------------------------------------------------
# Check if packages are installed
pkgs = c('ggplot2', 'd3heatmap', 'ggdendro', 'viridis', 'dplyr', 'tidyr')
alreadyInstalled = installed.packages()[, "Package"]

toInstall = pkgs[!pkgs %in% alreadyInstalled]

# Install anything that isn't already installed.
if (length(toInstall > 0)) {
  print(paste0("Installing these packages: ", paste0(toInstall, collapse = ", ")))
  
  install.packages(toInstall)
}


# main library for plotting
library(ggplot2)

# dynamic library for re-creating MuscleDB
library(d3heatmap)

# library to create dendrograms
library(ggdendro)

# color libraries
library(viridis)

# library for basic data manipulation
library(dplyr)
library(tidyr)


# heatmap choices ---------------------------------------------------------

# colorPalette is a series of colors to be used in the color ramp
colorPalette = viridis::magma(11)
# If there are any NAs (e.g. from log-transform), what color should be plotted?
nodataColor = viridis::magma(1)

# font color for all text (in hexadecimal)
fontColor = '#777777'

# export options (size and name for saved files)
width = 7
height = 7.5
filename = 'heatmap'


# scaling values to scrunch the dendrograms
# gap between dendrogram and heatmap plot.  0.5 = overlapping with the end of the plot
gapDendro = 0.75

# scaling factor to limit the size of the dendrogram in the plot
dendroReduction = 5


# import data -------------------------------------------------------------
# Note: data should be in a "wide" format, e.g. each row should contain:
# gene | atria expression | left ventricle expression | ...
# NOT
#  gene | muscle tissue | expression 

# Note 2: only columns should be gene, transcript, shortName, and expression
dfwide = read.csv(csv_file)

# It's easiest to plot the base heatmap if the  data are  in the long form
# So to transpose...
# it'll take every column that's NOT gene, transcript, or id and put the column name into 'tissue' and the value into 'expr'
df = dfwide %>% 
  # transpose
  gather(tissue, expr, -gene, -transcript, -shortName) %>% 
  # create a fusion name for plotting, e.g. Hoxa7 (uc009byk)
  mutate(gene_trans = ifelse(is.na(gene), transcript, paste0(gene, ' (', transcript, ')')))

# pull out how many tissues/transcripts dealing with
numTranscripts = length(unique(df$transcript))
numTissues = length(unique(df$tissue))


# dfwide is used to cluster the genes.  To do so, the data frame should only contain numbers, 
# with the rows labeled by a unique variable (transcript, in this case)
row.names(dfwide) = dfwide$transcript
dfwide = dfwide  %>% select(-gene, -transcript, -shortName)

# calculate dendrogram ----------------------------------------------------

# cluster the wide form of the data (just numbers) to get the transcript clusters
# clustering based on a row mean of everything.
dendro_genes = hclust(dist(rowMeans(dfwide)))

# figure out how the tissues should be ordered from left to right
gene_order = data.frame(transcript =  dendro_genes$labels[dendro_genes$order], 
                        gene_order = 1:max(dendro_genes$order))

gene_order = left_join(gene_order, df %>% select(transcript, shortName, gene_trans) %>% distinct(), 
                       by = 'transcript') %>% 
  arrange(gene_order)

# cluster the transpose of the data to get the tissue clusters
dendro_tissues = hclust(dist(t(dfwide)))

# figure out how the tissues should be ordered from left to right
tissue_order = dendro_tissues$labels[dendro_tissues$order]

# resort the transcripts and tissues, so they are in the order of the dendrogram
# without this step, the heatmap will plot the tissues and genes in alpha order
df$tissue = factor(df$tissue, levels = tissue_order)

df$transcript = factor(df$transcript, levels = gene_order$transcript)
df$gene_trans = factor(df$gene_trans, levels = unique(gene_order$gene_trans))

# create heatmap ----------------------------------------------------------

# x values are the tissue / muscle type
# y values are the gene names (using the gene name + transcript if it exists, or otherwise the transcript id)
# fill values (color) are the expression levels
heatmap = ggplot(df) +
  
  # create the filled color tiles
  # no border between tiles
  geom_tile(aes(x = tissue, y = gene_trans, fill = expr)) +
  
  # create the filled color tiles. 
  # Add a border where color/size specify the color and width of the border outside each tile
  # geom_tile(aes(x = tissue, y = gene_trans, fill = expr), color = 'white', size = 0.05) +
  
  # change the color palette
  scale_fill_gradientn(colours = colorPalette,
                       na.value = nodataColor,
                       name = 'expression (FPKM)') +
  
  # controls the aesthetics of the graph
  theme_minimal() + # tunrs off default grey background
  theme(
    # remove x/y-axis titles, e.g. "tissue"
    axis.title = element_blank(),
    
    # rotate tissues by 45 degrees
    axis.text.x = element_text(angle = 45, hjust = 1),
    
    # remove the x/y tick marks, grid lines
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_line(colour = fontColor, size = 0.2, linetype = 1),
    panel.grid = element_blank(),
    
    # lighten color of labels
    text = element_text(colour = fontColor),
    axis.text = element_text(colour = fontColor),
    
    # flip the legend to exist on the bottom
    legend.position = 'bottom',
    legend.direction = 'horizontal'
  )




# add in dendrograms ------------------------------------------------------
heatmap +
  # tissue dendrogram
   geom_segment(aes(x = x, y = y/dendroReduction + numTranscripts + gapDendro, xend = xend, 
                    yend = yend/dendroReduction + numTranscripts + gapDendro, fill=1),
                                 size = 0.25,
                  color = fontColor,
                  data = segment(dendro_data(dendro_tissues))) +
  # transcript dendrogram
  geom_segment(aes(x = y/dendroReduction + numTissues + gapDendro, y = x, 
                   xend = yend/dendroReduction + numTissues + gapDendro, yend = xend, fill=1),
               size = 0.25,
               color = fontColor,
               data = segment(dendro_data(dendro_genes)))

# save heatmap ------------------------------------------------------------
# save as pdf
ggsave(filename = paste0(filename, '.pdf'), width = width, height = height)

# save as png
ggsave(filename = paste0(filename, '.png'), width = width, height = height)

# interactive version -----------------------------------------------------
d3heatmap::d3heatmap(dfwide, colors = colorPalette)
