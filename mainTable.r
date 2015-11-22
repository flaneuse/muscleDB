
# Table to display all the results ----------------------------------------


output$table <- renderDataTable({
  filtered = filterData()
  
  # Remove cols not needed in the table.
  filtered = filtered %>% 
    # mutate(test = "<a href = 'http://www.google.com'>google</a>") %>% 
    select(transcript, tissue, expr, id)
  
  # Convert to table so can be used by tidyr.
  filtered = collect(filtered) 
  
  filtered %>% 
            spread(tissue, expr) %>% 
    select(-id)
  
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