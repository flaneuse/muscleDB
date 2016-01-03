
# Table to display all the results ----------------------------------------


output$table <- renderDataTable({
  
  filtered = filterData()
  
  # Remove cols not needed in the table.
  filtered = filtered %>% 
    select(transcript = transcriptLink, gene = geneLink, tissue, expr, id, q)
 
  
  # Leftover from SQL implementation. 
  # filtered = collect(filtered) 
  
  # Convert to table so can be used by tidyr.  
  data.table::dcast(filtered, 
                    transcript + gene + id + q ~ tissue, 
                    value.var = 'expr')
},  
escape = c(-1,-2, -3),
selection = 'none', #! Temporarily turning off row selection.
options = list(searching = FALSE, stateSave = TRUE,
               pageLength = 25,
               rowCallback = JS(
                 'function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
        if (aData[0])
          $("td:eq(0)", nRow).css("color", "#293C97");
          $("td", nRow).css("text-align", "center");
      }')
)    
)