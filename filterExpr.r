# filterData is a reactive function that takes no arguments, so it'll autoupdate when
# the inputs change.
filterData <- reactive({
  

    # Number to return at a specific time.
  num2Return = 2500
  
  x = proc.time()
  
  
  # Gene and muscle filtering -----------------------------------------------
  
  # Per1, Per2, Per3, ....
  # Note: to change to exact matching, include '$' at the end of the string.
  # geneInput = paste0(input$geneInput, '%') # For SQL-based filtering
  geneInput = paste0('^', input$geneInput)
  ont = paste0(input$GO)
  
  
  muscleSymbols = plyr::mapvalues(input$muscles,
                                  from = c('atria', 'left ventricle',
                                           'total aorta', 'right ventricle',
                                           'soleus', 
                                           'diaphragm',
                                           'eye', 'EDL', 'FDB', 
                                           'plantaris'),
                                  to = c('ATR', 'LV',
                                         'AOR', 'RV',
                                         'SOL', 'DIA',
                                         'EYE', 'EDL',
                                         'FDB', 'PLA'))
  qCol = paste0(paste0(sort(muscleSymbols), collapse = '.'), '_q')
  
  # SELECT DATA.
  # Note: right now, if there's something in both the "gene" and "ont"
  # input boxes, they must BOTH be true (AND relationship).
  # For example, if you have gene = "Myod1" and ont = "kinase",
  # you'll find only genes w/ both the name Myod1 and kinase as an ontology (which doesn't exist).
  # To switch this to an OR relationship, combine the geneInput and ont with an '|'.
  
  # Check if q-value filtering is turned on
  if(input$adv == FALSE & qCol %in% colnames(data)) {
    
    
    filtered = data %>% 
      select_("-contains('_q')", q = qCol) %>% 
      filter(tissue %in% input$muscles,   # muscles
             shortName %like% geneInput,  # gene symbol
             GO %like% ont)

  }  else if (input$adv == FALSE) {
    filtered = data %>% 
      select_("-contains('_q')") %>% 
      filter(tissue %in% input$muscles,   # muscles
             shortName %like% geneInput,  # gene symbol
             GO %like% geneInput) %>%     # gene ontology
      mutate(q = NA)
  } else if(qCol %in% colnames(data)){
    # Check if the q values exist in the db.
    
    filtered = data %>% 
      select_("-contains('_q')", q = qCol) %>% 
      filter(tissue %in% input$muscles,   # muscles
             shortName %like% geneInput,  # gene symbol
             GO %like% ont,               # gene ontology
             q < input$qVal
      )} else {
        filtered = data %>% 
          select(-contains('_q')) %>% 
          filter(tissue %in% input$muscles,   # muscles
                 shortName %like% geneInput,  # gene symbol
                 GO %like% ont                # gene ontology                 
          ) %>% 
          mutate(q = NA)
      }
  
  
  
  # filter(filtered, row_number(transcript) == 1L)
  
  
  
  # Filter on expression & q-values ---------------------------------------------
  
  if(input$maxExprVal != maxInit | input$minExprVal != 0){
    # Check to make sure that filtering is on.  Otherwise, don't filter.
    # Quantitative filtering
    filteredTranscripts = filtered %>%
      filter(expr <= input$maxExprVal,
             expr >= input$minExprVal) %>% 
      select(transcript)
    
    # Select the transcripts where at least one tissue meets the conditions.
    filtered = filtered %>% 
      filter(transcript %in% filteredTranscripts$transcript)
  }
  
  return(filtered)
})

