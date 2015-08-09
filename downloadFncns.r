output$downloadTable <- downloadHandler(
  filename = function() {
    paste('data-', Sys.Date(), '.csv', sep='')
  },
  content = function(file) {
    filteredData = filterData()
    write.csv(filteredData, file)
  }
)