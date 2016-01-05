# volcano table -----------------------------------------------------------

output$volcanoTable <- renderDataTable({
  filtered = filterData()
  
},  
escape = c(-1,-2, -3),
options = list(searching = TRUE, stateSave = TRUE,
               pageLength = 25,
               rowCallback = JS(
                 'function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
        if (aData[0])
          $("td:eq(0)", nRow).css("color", "#293C97");
          $("td", nRow).css("text-align", "center");
      }')
)
)


# volcano tooltip ---------------------------------------------------------





# ggvis volcano output ----------------------------------------------------

output$volcanoPlot <- renderPlot({
  filteredData = filterData()
  
  qplot(data = filteredData, y = logQ, x = logFC)
})
