
# Creates a heatmap with clustering for use in static publications --------

# Laura Hughes, laura.d.hughes@gmail.com




# import libraries --------------------------------------------------------

# main library for plotting
library(ggplot2)

# dynamic library for re-creating MuscleDB
library(d3heatmap)

# library to create dendrograms
library(ggdendro)

# color libraries
library(viridis)
library(RColorBrewer)

# library to have custom fonts from the system installed 
library (extrafont)
extrafont::font_import()

# library for basic data manipulation
library(dplyr)
library(tidyr)
library(data.table)

# heatmap choices ---------------------------------------------------------

# Whether the heatmap tiles should be square (TRUE) or rectangular (FALSE)
squareTiles = TRUE

# colorPalette is a series of colors to be used in the color ramp
colorPalette = viridis::magma(11)
nodataColor = viridis::magma(1)

# font color for everything (in hexadecimal)
fontColor = '#777777'

# threshold for whether to label unusually high values
exprLabelThresh = 25


# import data -------------------------------------------------------------
# Note: data should be in a "long" format, e.g. each row should contain:
#  gene | muscle tissue | expression 
# NOT
# gene | atria expression | left ventricle expression | ...


data = readRDS('data/expr_2017-04-23.rds')

# filter out just the data for 'Hox' genes
df = data %>% 
  filter(gene %like% 'Hox')


# calculate dendrogram ----------------------------------------------------

# cluster the wide form of the data (just numbers) to get the transcript clusters
dendro_genes = hclust(dist(dfwide))

# figure out how the tissues should be ordered from left to right
gene_order = data.frame(transcript =  dendro_genes$labels[dendro_genes$order], gene_order = 1:max(dendro_genes$order))

gene_order = left_join(gene_order, df %>% select(transcript, shortName) %>% distinct(), 
                       by = 'transcript') %>% 
  arrange(desc(gene_order))

# cluster the transpose of the data to get the tissue clusters
dendro_tissues = hclust(dist(t(dfwide)))

# figure out how the tissues should be ordered from left to right
tissue_order = dendro_tissues$labels[dendro_tissues$order]

# resort the transcripts and tissues, so they are in the order of the dendrogram
df$tissue = factor(df$tissue, levels = tissue_order)

df$transcript = factor(df$transcript, levels = gene_order$transcript)
df$shortName = factor(df$shortName, levels = unique(gene_order$shortName))

# create heatmap ----------------------------------------------------------

# x values are the tissue / muscle type
# y values are the gene names (using the gene name if it exists, or otherwise the transcript id)
# fill values (color) are the expression levels
heatmap = ggplot(df, aes(x = tissue, y = shortName, fill = log10(expr))) +
  
  # no border between tiles
  geom_tile() +
  
  # create the filled color tiles. color/size specify the color and width of the border outside each tile
  # geom_tile(color = 'white', size = 0.05) +
  
  # label expression values
  # geom_text(aes(label = round(expr, 0)),
  #           data = df %>% filter(expr > exprLabelThresh), 
  #           size = 2.5, # size is in mm, not points
  #   color = '#222222'
  # ) +
  
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


dendro_y = ggplot(segment(dendro_data(rev(dendro_genes)))) +
  geom_segment(aes(x = x, y = y, xend = xend, yend = yend),
               size = 0.25,
               color = fontColor
               ) +
  geom_text(aes(x = x, y = y, label = label), 
            color = fontColor,
            size = 2, 
            hjust = 1,
            data = dendro_data(rev(dendro_genes))$labels) +
  scale_x_continuous(expand = c(0.1, 0.1)) +
  coord_flip() +
  theme_void()

dendro_x = ggplot(segment(dendro_data((dendro_tissues)))) +
  geom_segment(aes(x = x, y = y, xend = xend, yend = yend),
               size = 0.25,
               color = fontColor
  ) +
  theme_void()


# save heatmap ------------------------------------------------------------
library(grid)
grid.newpage()

print(dendro_x, vp = viewport(width = 0.725, height = 0.2, x = 0.44, y = 0.875))
print(dendro_y, vp = viewport(width = 0.45, height = 0.655, x = 0.9,  y = 0.495))
print(heatmap, vp = viewport(0.8, 0.8, x = 0.4, y = 0.4))


# interactive version -----------------------------------------------------
dfwide = tidyr::spread(df %>% select(transcript, shortName, tissue, expr), tissue, expr)
row.names(dfwide) = dfwide$transcript

dfwide = dfwide %>% select(-transcript, -shortName)

d3heatmap::d3heatmap(dfwide %>% select(-transcript, -shortName), colors = colorPalette)
