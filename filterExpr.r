# filterData is a reactive function that takes no arguments, so it'll autoupdate when
# the inputs change.
filterData <- reactive({
  x = proc.time()
  # Change gene so it's starting with the input$gene's name, e.g. 'Per' will return 
  # Per1, Per2, Per3, ....
  # Note: to change to exact matching, include '$' at the end of the string.
  geneInput = paste0('^',input$geneInput)
  ont = input$GO
  
  # Set minimum and maximum expression values.
  #   if(is.null(input$minExprVal)) {
  #     low = 0
  #     } else {
  low = input$minExprVal
  # }
  
  high = input$maxExprVal
  
  # Select just the muscles and other useful cols.
  cols2Sel = paste0("shortName,transcript,", paste0(lapply(input$muscles, function(x) 
    paste0("contains('", x,"_mean')")), collapse=","))
  
  muscleExpr = paste(
    paste0(lapply(input$muscles, 
                  function(x) paste0(x, "_mean >=", low)), collapse=" & "),
    paste0(lapply(input$muscles,
                  function(x) paste0(x, "_mean <=", high)), collapse = " & "),
    sep = ",")
  
  # SELECT DATA.
  # Note: right now, if there's something in both the "gene" and "ont"
  # input boxes, they must BOTH be true (AND relationship).
  # For example, if you have gene = "Myod1" and ont = "kinase",
  # you'll find only genes w/ both the name Myod1 and kinase as an ontology (which doesn't exist).
  # To switch this to an OR relationship, change the '&' to a '|'.
  
  filtered = eval(parse(text = sprintf("data %%>%% 
        filter(grepl(geneInput, shortName) & grepl(ont, GO)) %%>%%
        mutate(transcript = strtrim(Transcript, 10)) %%>%%      
        select(%s) %%>%% filter(%s)", 
                                       cols2Sel,
                                       muscleExpr
  )))
  
  print(proc.time() - x)
  
  return(filtered)
  #       if (input$saveRowsTable > 0){
  #         filtered = filtered %>% 
  #           slice(as.numeric(input$table_rows_selected))
  #       } else {
  #         filtered
  #       }
})
