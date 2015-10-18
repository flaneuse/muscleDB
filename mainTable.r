output$table <- renderDataTable({
  filtered = filterData()
  
  filtered %>% 
    select(gene = entrezLink, transcript = UCSCLink, 
           tissue, expr, q) %>% 
    spread(tissue, expr)
  
},  escape = c(-1,-2),
options = list(searching = FALSE, stateSave = TRUE,
               rowCallback = JS(
                 'function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
        if (aData[0])
          $("td:eq(0)", nRow).css("color", "#293C97");
          $("td", nRow).css("text-align", "center");
      }')
)    
)