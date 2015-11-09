# # 
# data = readRDS("~/Dropbox/Muscle Transcriptome Atlas/Website files/MTapp-v0-51/data/combData_2014-10-19.rds")
# # # 
# # # # HACK for now to ignore p-vals.
# data = data[,1:23]
# data[,8:23] = round(data[,8:23],3)
# # # 
# data = data %>%
#   mutate(gene = shortName)
# # # 
# iMuscles= 8:15
# maxInit = max(data[,iMuscles])

# data = readRDS('~/Dropbox/Muscle Transcriptome Atlas/Website files/data/expr_2015-10-11.rds')
# maxInit = max(data$expr)

data = mt
maxInit = 25000

shinyServer(
  function(input, output, session) {
    
    # FILTER: Based on the inputs given by the users, filter down the large db into 
    # a table with only the selected values.  MAIN function to select data.
    source("filterExpr.r", local = TRUE) 
    
    # TABLE outputs: main table with all the data, and summary table 
    # with the summary statistics for the filtered data.
    # source("summaryTable.r", local = TRUE)
    source("mainTable.r", local = TRUE)
    
    # PLOT output
    source("formatPlot.r", local = TRUE)
    source("plot.r", local = TRUE)
  
    # PCA output
    source("calcPCA.r", local = TRUE)
    source("PCA.r", local = TRUE)
    
    output$PCAload = renderDataTable({
      PCA = calcPCA()
      
      PCA$rotation[,1:2]
    })
    
    output$PCAstats = renderInfoBox({
      PCA = calcPCA()
#       
      stats = cumsum((PCA$sdev)^2) / sum(PCA$sdev^2)
      infoBox("PCA stats", subtitle = "Percent variance explained by PC1", 
              width = 12,
              value = round(stats[1]*100,1))
    })
    
    # SUMMARY WIDGETS at the top of the table page w/ some summary stats.
    source("summaryStats.r", local = TRUE)      
    
    # DOWNLOAD data buttons.
    source("downloadFncns.r", local = TRUE)
    
    output$test <- renderPrint({ # Test function for returning current page.
      beg = input$table_state$start+1
      end = input$table_state$length+input$table_state$start
      # return(beg:end)
      as.numeric(input$table_rows_selected)
    })
    
    output$heatmap <- renderD3heatmap({
      filteredData = filterData() %>% 
        slice(1:200)
      
      # Pull out the names to display
      heatNames = filteredData %>% 
        mutate(name = paste0(gene, " (", transcript, ")")) %>% 
        select(name)
      
      filteredData = filteredData %>% 
        select(contains("_mean")) 

      
      if(input$scaleHeat == "log") {
        scaleHeat = "none"
        
        filteredData = filteredData %>% 
          mutate_each(funs(log10))
        
        
        filteredData[filteredData == -Inf] = NA #! Note!  Fix this.  NA's don't work with foreign call to calc dendrogram.
        
        
        
        
      } else{
        scaleHeat = input$scaleHeat
      }
      
      d3heatmap(filteredData, scale = scaleHeat, 
                dendrogram = if(input$orderHeat){'both'} else{'none'}, 
                # Rowv = TRUE, Colv = TRUE, 
                show_grid = TRUE, color="YlOrRd", labRow = t(heatNames),
                xaxis_height = 100, yaxis_width = 200
      )
    })
    
    output$volcanoSelect <- renderUI({
      
    })
  })
