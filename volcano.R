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

output$volcanoPlot <- renderChart2({
  # m1 <- mPlot(x = 'cyl', y = 'mpg', type = "Line", data = mtcars)
  filteredData = filterData()
  # r1 <- rPlot(mpg ~ wt, data = mtcars, type = 'point', color = 'gear')
  
  # r1 = rPlot(logQ ~ logFC, data = filteredData, type = 'point',
  #            size = list(const = 3), color = list(const = '#888'))
  
  r1 = mPlot(x = 'logQ', y = 'logFC', data = filteredData, type = 'point')
  })
