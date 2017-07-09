
# Creates a heatmap with clustering for use in static publications --------

# Laura Hughes, laura.d.hughes@gmail.com


# csv file name CHANGE ME!-----------------------------------------------------------
# File that's read in on line 75.  Note that Excel files can be read in with slight modifications
csv_file = '~/Dropbox/Muscle Transcriptome Atlas/Website files/data/heatmap_demo.csv'



# Save heatmap function ---------------------------------------------------
# NOTE: replaces all 0's with 0.005 
# If log normalization is turned on, calculates the log10-transformed value of the 
# If row-normalization is tunred on, calculates the normalized value as (expr - meanRow) / stdRow
# If both log and row normalization are turned on, log-transform happens first
# Row normalization kicks out any transcript with 0 deviation.
# Clustering happens AFTER any normalization

save_heatmap = function(csv_file, 
                        # plot the heatmap?
                        show_heatmap = TRUE,
                        
                        # cluster and plot the genes in a dendrogram?
                        cluster_genes = TRUE,
                        
                        # cluster and plot the muscle tissues?
                        cluster_muscle = TRUE,
                        
                        # log-normalize values
                        log_norm = TRUE,
                        min_expr = 0.01/2,
                        
                        # row-normalize values
                        row_norm = TRUE,
                        
                        # whether heatmap should have square or rectangular tiles
                        square_tiles = FALSE,
                        border_color = 'white', # set to NA to remove
                        border_size = 0,
                        
                        # name to save the files
                        saved_filename = 'heatmap',
                        # export options (size and name for saved files)
                        width = 7,
                        height = 7.5
) {
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
  dfwide = read.csv(csv_file, stringsAsFactors = FALSE)
  
  
  # log-10 transform the numeric data
  # find which columns are numeric
  numeric_cols = unlist(lapply(dfwide, function(x) is.numeric(x)))
  numeric_cols = as.vector(names(numeric_cols[numeric_cols == TRUE]))
  
  if(log_norm == TRUE) {
    dfwide = dfwide %>% 
      # replace all zeros with the 1/2 the minimum expression value, to avoid -Inf values
      mutate_at(funs(ifelse(. == 0, min_expr, .)), .vars = numeric_cols) %>% 
      # log-transform
      mutate_at(funs(log10(.)), .vars = numeric_cols)
  }
  
  # row-wise normalize
  if(row_norm == TRUE){
    dfwide =
      dfwide %>% 
      rowwise() %>% 
      mutate_(.dots = setNames(paste0('sd(c(', paste(numeric_cols, collapse = ','), '))'), 'std')) %>%
      mutate_(.dots = setNames(paste0('mean(c(', paste(numeric_cols, collapse = ','), '))'), 'avg'))
    
    if(any(dfwide$std == 0)) {
      transcript = dfwide[dfwide$std == 0, 'transcript']
      warning(paste0('warning: removing transcript ', transcript, ' since it has no deviation'))
    }
    # remove rows with no standard deviation
    dfwide = dfwide %>% 
      filter(std != 0) %>% 
      # row normalize everything
      mutate_at(funs((. - avg)/std), .vars = numeric_cols) %>% 
      select(-avg, -std)
  }
  
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
  dendro_genes = hclust(dist((dfwide)))
  
  # row averages
  rs = data.frame(avg = rowMeans(dfwide)) 
  rs = rs %>% mutate(transcript = row.names(rs))
  
  
  
  # figure out how the tissues should be ordered from left to right
  gene_order = data.frame(transcript =  dendro_genes$labels[dendro_genes$order], 
                          gene_order = 1:max(dendro_genes$order)) 
  
  gene_order = gene_order %>% left_join(rs, by = 'transcript')
  
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
  # base heatmap
  heatmap = ggplot(df) + # controls the aesthetics of the graph
    theme_minimal() + # turns off default grey background
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
  
  # x values are the tissue / muscle type
  # y values are the gene names (using the gene name + transcript if it exists, or otherwise the transcript id)
  # fill values (color) are the expression levels
  
  if(show_heatmap == TRUE) { 
    heatmap = heatmap +
      
      # create the filled color tiles
      # no border between tiles
      geom_tile(aes(x = tissue, y = gene_trans, fill = expr),
                color = border_color, size = border_size) +
      
      # create the filled color tiles. 
      # Add a border where color/size specify the color and width of the border outside each tile
      # geom_tile(aes(x = tissue, y = gene_trans, fill = expr), color = 'white', size = 0.05) +
      
      # change the color palette
      scale_fill_gradientn(colours = colorPalette,
                           na.value = nodataColor,
                           name = 'expression (FPKM)')
    
    if(square_tiles == TRUE) {
      heatmap = heatmap +
        coord_equal()
    }
  }
  
  
  # add in dendrograms ------------------------------------------------------
  if(cluster_muscle == TRUE) {
    heatmap = heatmap +
      # tissue dendrogram
      geom_segment(aes(x = x, y = y/dendroReduction + numTranscripts + gapDendro, xend = xend, 
                       yend = yend/dendroReduction + numTranscripts + gapDendro, fill=1),
                   size = 0.25,
                   color = fontColor,
                   data = segment(dendro_data(dendro_tissues)))
  }
  
  if(cluster_genes == TRUE) {
    heatmap = heatmap +
      # transcript dendrogram
      geom_segment(aes(x = y/dendroReduction + numTissues + gapDendro, y = x, 
                       xend = yend/dendroReduction + numTissues + gapDendro, yend = xend, fill=1),
                   size = 0.25,
                   color = fontColor,
                   data = segment(dendro_data(dendro_genes)))
  }
  
  # save heatmap ------------------------------------------------------------
  # save as pdf
  ggsave(filename = paste0(saved_filename, '.pdf'), width = width, height = height)
  
  # save as png
  ggsave(filename = paste0(saved_filename, '.png'), width = width, height = height)
  
  # plot the heatmap
  return(heatmap)
}


# call the function -------------------------------------------------------
# Call and save
save_heatmap(csv_file, saved_filename = 'Hox_heatmap')

# remove white borders
save_heatmap(csv_file, border_color = NA)

# turn off clustering
save_heatmap(csv_file, cluster_genes = FALSE, cluster_muscle = FALSE)

# turn off all normalization
save_heatmap(csv_file, row_norm = FALSE, log_norm = FALSE, saved_filename = 'Hox_heatmap_nonorm')

# turn off log normalization
save_heatmap(csv_file, log_norm = FALSE, saved_filename = 'Hox_heatmap_nolog')

# turn off row normalization
save_heatmap(csv_file, row_norm = FALSE, saved_filename = 'Hox_heatmap_norow')



# interactive version -----------------------------------------------------
# d3heatmap::d3heatmap(dfwide %>% select(-transcript, -gene, -shortName), colors = colorPalette)
