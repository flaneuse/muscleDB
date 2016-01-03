shinyServer(
  function(input, output, session) {
    
    # FILTER ------------------------------------------------------------------
    
    # FILTER: Based on the inputs given by the users, filter down the large db into 
    # a table with only the selected values.  MAIN function to select data.
    source("filterExpr.r", local = TRUE) 
    
    # TABLE ------------------------------------------------------------------
    
    # TABLE outputs: main table with all the data, and summary table 
    # with the summary statistics for the filtered data.
    # source("summaryTable.r", local = TRUE)
    source("mainTable.r", local = TRUE)
    
    # SUMMARY WIDGETS at the top of the table page w/ some summary stats.
    source("summaryStats.r", local = TRUE)      
    
    # DOWNLOAD data buttons.
    source("downloadFncns.r", local = TRUE)
    
    
    # PLOT (MAIN) -------------------------------------------------------------
    
    # PAGINATION
    # pager_state = input$pager
    # updatePageruiInput(session, 'pager', page_current = new_page_current)
    # updatePageruiInput(session, 'pager', pages_total = new_pages_total)
    # updatePageruiInput(session, 'pager', 
    #                    page_current = new_page_current, 
    #                    pages_total = new_pages_total)
    
    # PLOT output
    source("formatPlot.r", local = TRUE)
    source("plot.r", local = TRUE)
    
    # PCA ---------------------------------------------------------------------
    
    # PCA output
    source("calcPCA.r", local = TRUE)
    source("PCA.r", local = TRUE)
    
    output$PCAload = renderDataTable({
      PCA = calcPCA()
      
      PCA$rotation[,1:2]
    })
    
    output$PCAstats = renderInfoBox({
      PCA = calcPCA()
      
      stats = cumsum((PCA$sdev)^2) / sum(PCA$sdev^2)
      infoBox("PCA stats", subtitle = "Percent variance explained by PC1", 
              width = 12,
              value = round(stats[1]*100,1))
    })
    
    
    output$test <- renderPrint({ # Test function for returning current page.
      beg = input$table_state$start+1
      end = input$table_state$length+input$table_state$start
      # return(beg:end)
      as.numeric(input$table_rows_selected)
    })
    
    # HEATMAP -----------------------------------------------------------------
    source("heatmap.R", local = TRUE) 
    
    
    # VOLCANO PLOT ------------------------------------------------------------
    output$m1 = renderUI(
           selectInput('muscle1', label = 'muscle 1',
                       choices = input$muscles,
           width = '200px'))
    
    output$m2 = renderUI(
      selectInput('muscle2', label = 'muscle 2 (reference)',
                  choices = input$muscles,
                  width = '200px'))
    
    source("volcano.R", local = TRUE)
    
    
  })
