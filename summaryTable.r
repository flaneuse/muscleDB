output$summaryTable <- renderDataTable({
  filteredData = filterData()
  
  sumTab = bind_rows(round(filteredData  %>% summarise_each(funs(mean), 
                                                            matches ("mean")),3),
                     round(filteredData  %>% summarise_each(funs(median), 
                                                            matches ("mean")),3),
                     round(filteredData  %>% summarise_each(funs(max), 
                                                            matches ("mean")),3),
                     round(filteredData  %>% summarise_each(funs(min), 
                                                            matches ("mean")),3),
                     round(filteredData  %>% summarise_each(funs(sd), 
                                                            matches ("mean")),3))
  sumTab= bind_cols(data.frame(statistic = c("mean",
                                             "median",
                                             "max", "min", "std. dev"
  )),
  data.frame("tissue:" = rep("",5)),
  sumTab)
}, selection = 'none',
options = list(searching = FALSE, paging = FALSE, info = FALSE, ordering = FALSE,
               rowCallback = JS(
                 'function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
        if (aData[0])
          $("td:eq(0)", nRow).css("color", "#293C97");
          $("td", nRow).css("text-align", "center");
      }')
)    
)
