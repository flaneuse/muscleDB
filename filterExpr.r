# filterData is a reactive function that takes no arguments, so it'll autoupdate when
# the inputs change.
filterData <- reactive({
  x = proc.time()
  
  
  # Per1, Per2, Per3, ....
  # Note: to change to exact matching, include '$' at the end of the string.
  geneInput = paste0('^',input$geneInput)
  ont = input$GO
  
  
  # SELECT DATA.
  # Note: right now, if there's something in both the "gene" and "ont"
  # input boxes, they must BOTH be true (AND relationship).
  # For example, if you have gene = "Myod1" and ont = "kinase",
  # you'll find only genes w/ both the name Myod1 and kinase as an ontology (which doesn't exist).
  # To switch this to an OR relationship, change the '&' to a '|'.
  
  filtered = data %>% 
    filter(tissue %in% input$muscles,
           grepl(geneInput, Transcript) & grepl(ont, GO)
    )
  
  # Quantitative filtering
  filteredTranscripts = filtered %>% 
    filter(expr <= input$maxExprVal, 
           expr >= input$minExprVal, 
           q <= input$qVal) %>% 
    select(Transcript)
  
  # Select the transcripts where at least one tissue meets the conditions.
  filtered = filtered %>% 
    filter(Transcript %in% filteredTranscripts$Transcript)
  
  
  print(proc.time() - x)
  
  return(filtered)
  #       if (input$saveRowsTable > 0){
  #         filtered = filtered %>% 
  #           slice(as.numeric(input$table_rows_selected))
  #       } else {
  #         filtered
  #       }
})
