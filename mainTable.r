output$table <- renderDataTable({
  filtered = filterData()
  
  filtered %>% 
    mutate(test = "<a href = 'http://www.google.com'>google</a>") %>% 
    select(transcript, tissue, expr, test) %>% 
    spread(tissue, expr)
  
},  
escape = c(-1,-2, -3),
selection = 'none', #! Temporarily turning off row selection.
options = list(searching = FALSE, stateSave = TRUE,
               rowCallback = JS(
                 'function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
        if (aData[0])
          $("td:eq(0)", nRow).css("color", "#293C97");
          $("td", nRow).css("text-align", "center");
      }')
)    
)