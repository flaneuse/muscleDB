# Widget showing the minimum, mean, and maximum expression value.
output$minExpr <- renderInfoBox({
  filteredData = filterData()
  
  minVal = filteredData %>% 
    summarise(min = min(expr))
  
  # Find minimum value and which tissues have that value.
  minVal= minVal[[1]]
  
  iMin = which(filteredData$expr == minVal)
  
  
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
  
  avgVal = filteredData %>% 
    summarise(round(mean(expr),2))
  
  infoBox("mean expression",
          avgVal,
          #               HTML(paste0(minVal, '<br>',"fdjks")),"rjek",
          icon = icon("minus"),
          fill = TRUE
  )
})

output$maxExpr <- renderInfoBox({
  filteredData = filterData()
  
  maxVal = filteredData %>% 
    summarise(max = max(expr))
  
  # Find maximum value and which tissues have that value.
  maxVal= maxVal[[1]]
  
  iMax = which(filteredData$expr == maxVal)
  
  
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
