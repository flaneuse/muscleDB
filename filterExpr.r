# filterData is a reactive function that takes no arguments, so it'll autoupdate when
# the inputs change.
filterData <- reactive({
  x = proc.time()
  

# #   
#   
#   # Per1, Per2, Per3, ....
#   # Note: to change to exact matching, include '$' at the end of the string.
#   # geneInput = paste0('^',input$geneInput) # Antiquated; for 
  geneInput = paste0(input$geneInput, '%')
  ont = paste0('%', input$GO, '%')
#   
#   
#   # SELECT DATA.
#   # Note: right now, if there's something in both the "gene" and "ont"
#   # input boxes, they must BOTH be true (AND relationship).
#   # For example, if you have gene = "Myod1" and ont = "kinase",
#   # you'll find only genes w/ both the name Myod1 and kinase as an ontology (which doesn't exist).
#   # To switch this to an OR relationship, change the '&' to a '|'.
#   
#   # filtered = semi_join(mt, df2, copy = TRUE, auto_index = TRUE) %>% 
  filtered = data %>% 
    filter(tissue %in% input$muscles,
           expr >10,
           # ,
           transcript %like% geneInput
           # , GO %like% ont
    )
  

#   
#   # Quantitative filtering
#   filteredTranscripts = filtered %>% 
#     filter(expr <= input$maxExprVal, 
#            expr >= input$minExprVal, 
#            q <= input$qVal) %>% 
#     select(transcript)
#   
#   # Select the transcripts where at least one tissue meets the conditions.
#   filtered = left_join(filtered, filteredTranscripts)
#   
#   print(proc.time() - x)
#   
#   return(filtered)
#   #       if (input$saveRowsTable > 0){
#   #         filtered = filtered %>% 
#   #           slice(as.numeric(input$table_rows_selected))
#   #       } else {
#   #         filtered
#   #       }
  
  # filtered = collect(filtered)
  
  # print(dim(filtered))
  
  
  # filtered = data %>% 
    # filter(expr > 18000)
  
})
