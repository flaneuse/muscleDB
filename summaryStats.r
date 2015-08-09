# Widget showing the minimum expression value.
output$minExpr <- renderInfoBox({
  filteredData = filterData()
  
  minVal = min(filteredData[,sapply(filteredData, is.numeric)])
  
  iMin = rowSums(filteredData[,sapply(filteredData,is.numeric)]==minVal)
  iMin = which(iMin > 0)
  
  
  if (length(iMin) > 2) {
    minGenes = paste0("in ", length(iMin),
                      " different genes")
  } else {
    minGenes = paste0(filteredData[iMin,1], " (", strtrim(filteredData[iMin,2],10), ")")
  }
  
  infoBox("minimum expression",
          minVal,
          minGenes,
          #               HTML(paste0(minVal, '<br>',"fdjks")),"rjek",
          icon = icon("chevron-down"),
          fill = TRUE
  )
})

output$avgExpr <- renderInfoBox({
  filteredData = filterData()
  
  #   minVal = round(filteredData  %>% select(contains("_mean")) %>% 
  #                    summarise_each(funs(mean)),1)
  
  avgVal = round(mean(t(filteredData %>% select(contains("_mean")))),2)
  
  
  infoBox("mean expression",
          avgVal,
          #               HTML(paste0(minVal, '<br>',"fdjks")),"rjek",
          icon = icon("minus"),
          fill = TRUE
  )
})

output$maxExpr <- renderInfoBox({
  filteredData = filterData()
  
  maxVal = max(filteredData[,sapply(filteredData, is.numeric)])
  
  iMax = rowSums(filteredData[,sapply(filteredData,is.numeric)]==maxVal)
  iMax = which(iMax > 0)
  
  
  if (length(iMax) > 2) {
    maxGenes = paste0("in ", length(iMax),
                      " different genes")
  } else {
    maxGenes = paste0(filteredData[iMax,1], " (", strtrim(filteredData[iMax,2],10), ")")
  }
  
  infoBox("maximum expression",
          maxVal,
          maxGenes,
          #               HTML(paste0(minVal, '<br>',"fdjks")),"rjek",
          icon = icon("chevron-up"),
          fill = TRUE
  )
})
