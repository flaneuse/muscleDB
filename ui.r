library(shiny)
library(shinydashboard)
library(dplyr)
library(DT)
library(d3heatmap)
library(ggvis)
library(ggplot2)


# Define sidebar for inputs -----------------------------------------------

sidebar <- dashboardSidebar(
  sidebarSearchForm(label = "search symbol (Myod1)", "geneInput", "searchButton"),
  sidebarSearchForm(label = "search ontology (axon)", "GO", "searchButton"),
  checkboxGroupInput("muscles","muscle type", inline = FALSE,
                     choices = c('atria' = 'atria', 
                                 'left ventricle' = 'left ventricle',
                                 'total aorta' = 'total aorta', 
                                 'right ventricle' = 'right ventricle',
                                 'soleus' = 'soleus', 
                                 # 'thoracic aorta' = 'thoracic aorta', 
                                 # 'abdominal aorta' = 'abdominal aorta', 
                                 'diaphragm' = 'diaphragm',
                                 'eye' = 'eye', 
                                 'EDL' = 'EDL', 'FDB' = 'FDB', 
                                 # 'masseter' =  'masseter', 
                                 'plantaris' = 'plantaris'), 
                                 # 'tongue' = 'tongue'),
                     selected = c('atria', 'left ventricle',
                                  'total aorta', 'right ventricle',
                                  'soleus', 
                                  # 'thoracic aorta', 
                                  # 'abdominal aorta', 
                                  'diaphragm',
                                  'eye', 'EDL', 'FDB', 
                                  # 'masseter', 'tongue'
                                  'plantaris')),
  
  # Conditional for advanced filtering options.
  checkboxInput("adv", "advanced filtering", value = FALSE),
  conditionalPanel(
    condition = "input.adv == true",
    
    # -- Expression filtering. --
    HTML("<div style = 'padding-left:1em; color:#00b3dd; font-weight:bold'>
      expression level </div>"),
    fluidRow(column(6,
                    numericInput("minExprVal", "min:", 0,
                                 min = 0, max = maxInit)),
             column(6,
                    numericInput("maxExprVal", "max:", 
                                 value = maxInit, min = 0, max = maxInit))),
    
    # -- fold change. --
    HTML("<div style = 'padding-left:1em; color:#00b3dd; font-weight:bold'> fold change </div>"),
    helpText(em(HTML("<div style= 'font-size:10pt; padding-left:1em'> 
        Filters by the increase in expression, 
                         relative to a single muscle tissue</div>"))),
    radioButtons("ref", label = "reference tissue:", 
                 choices = list("aorta" = "AOR", "atria" = "ATR",
                                "diaphragm"="DIA", "EDL" = "EDL", "eye"="EYE",
                                "left ventricle" = "LV", "right ventricle"="RV", "soleus" = "SOL"), selected = "AOR"),
      sliderInput("foldChange", label=NULL, min = 1.0, max = 21, value = 1, step = 0.5, width="100%"),
    
    # -- q-value. --
    HTML("<div style = 'padding-left:1em; color:#00b3dd; font-weight:bold'>
      q value </div>"),
    fluidRow(column(6,
                    numericInput("qVal", "maximum q value:", 0,
                                 min = 0, max = 1, value = 1)))
  ),
  
  sidebarMenu(
    # Setting id makes input$tabs give the tabName of currently-selected tab
    id = "tabs",
    menuItemOutput("minExprInput"),
    menuItemOutput("maxExprInput"),
    menuItem("plot", tabName = "plot", icon = icon("bar-chart")),
    menuItem("table", tabName = "table", icon = icon("table")),
    menuItem("volcano plot", tabName = "volcano", icon = icon("ellipsis-v")),
    menuItem("heat map", tabName = "heatMap", icon = icon("th", lib = "glyphicon")),
    menuItem("PCA", tabName = "PCA", icon = icon("arrows")),
    menuItem("compare genes", tabName = "compare", icon = icon("line-chart")), 
    menuItem("Charts", icon = icon("bar-chart-o"),
             menuSubItem("Sub-item 1", tabName = "subitem1"),
             menuSubItem("Sub-item 2", tabName = "subitem2")
    ),
    menuItem("code", icon = icon("code"))
  )
)



header <- dashboardHeader(
  title = "Muscle Transcriptome Atlas",
  dropdownMenu(type = "messages", badgeStatus = NULL, icon = icon("question-circle"),
               messageItem("Muscle Transcriptome Atlas",
                           "about the database",
                           icon = icon("bar-chart"),
                           href="https://muscle-transcriptome-atlas.shinyapps.io/how-to/"
               ),
               messageItem("Need help getting started?",
                           "click here", icon = icon("question-circle"),
                           href="https://muscle-transcriptome-atlas.shinyapps.io/how-to/"
               ),
               messageItem("Website code and data scripts",
                           "find the code on Github", icon = icon("code"),
                           href = "http://www.github.com")
  )
)

body <- dashboardBody(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "customStyle.css")),
  
  tabItems(
    tabItem(tabName = "volcano", plotOutput("volcano")),
    tabItem(tabName = "PCA", 
            fluidRow(column(5,
            plotOutput("pcaPlot"),
            dataTableOutput("PCAload")),
            column(7,infoBoxOutput("PCAstats")))),
            # h5("disclaimer; PCA loadings; % variance; brush; save --> table / graph / --> input")),
    tabItem(tabName = "heatMap", 
            fluidRow(column(7,
              d3heatmapOutput("heatmap",
                                                 width = 500,
                                                 height = 550)),
              column(5,
                     selectInput("scaleHeat", label = "heat map scaling",
                                 choices = c("none" = "none", "by row" = "row", 
                                             "by column" = "col", "log" = "log")),
                     checkboxInput("orderHeat", label = "group genes by similarity?", value = FALSE)
                     ))),
    tabItem(tabName = "plot", plotOutput("plot1")),
    tabItem(tabName = "table",
            # valueBoxes
            fluidRow(
              infoBoxOutput("maxExpr", width = 4),
              infoBoxOutput("avgExpr", width = 3),
              infoBoxOutput("minExpr", width = 4),
              column(1,
                     downloadButton('downloadTable', label = NULL, 
                                    class = 'btn btn-lg active btn-inverted hover btn-inverted'),
                     h5("")
                     #           actionButton("saveRowsTable", "save rows",
                     #                        icon = NULL)
              )
              #     infoBox("dwndTable", downloadLink('downloadTable'), icon = icon("download"), width = 1)
            ),
            
            
            # Boxes
            fluidRow(textOutput('tester')),
            fluidRow(
              box(status = NULL, width = 12,
                  dataTableOutput("table")
              )
            ),
            fluidRow(
              box(title = "Summary Statistics", solidHeader = TRUE, status = 'primary', width = 12,
                  dataTableOutput("summaryTable")))
            
            
    )
  ))

dashboardPage(
  title = "Muscle Transcriptome Atlas",  
  header,
  sidebar,
  body
)


# 
# sidebar <- dashboardSidebar(
#   sidebarUserPanel("User Name",
#                    subtitle = a(href = "#", icon("circle", class = "text-success"), "Online"),
#                    # Image file should be in www/ subdir
#                    image = "userimage.png"
#   ),
#   sidebarSearchForm(label = "Enter a number", "searchText", "searchButton"),
#   sidebarMenu(
#     # Setting id makes input$tabs give the tabName of currently-selected tab
#     id = "tabs",
#     menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
#     menuItem("Widgets", icon = icon("th"), tabName = "widgets", badgeLabel = "new",
#              badgeColor = "green"),
#     menuItem("Charts", icon = icon("bar-chart-o"),
#              menuSubItem("Sub-item 1", tabName = "subitem1"),
#              menuSubItem("Sub-item 2", tabName = "subitem2")
#     )
#   )
# )
# 
# 
# 
# header <- dashboardHeader(
#   title = "Muscle Atlas",
#   
#   # Dropdown menu for messages
#   dropdownMenu(type = "messages", badgeStatus = "success",
#                messageItem("Support Team",
#                            "This is the content of a message.",
#                            time = "5 mins"
#                ),
#                messageItem("Support Team",
#                            "This is the content of another message.",
#                            time = "2 hours"
#                ),
#                messageItem("New User",
#                            "Can I get some help?",
#                            time = "Today"
#                )
#   ),
#   
#   # Dropdown menu for notifications
#   dropdownMenu(type = "notifications", badgeStatus = "warning",
#                notificationItem(icon = icon("users"), status = "info",
#                                 "5 new members joined today"
#                ),
#                notificationItem(icon = icon("warning"), status = "danger",
#                                 "Resource usage near limit."
#                ),
#                notificationItem(icon = icon("shopping-cart", lib = "glyphicon"),
#                                 status = "success", "25 sales made"
#                ),
#                notificationItem(icon = icon("user", lib = "glyphicon"),
#                                 status = "danger", "You changed your username"
#                )
#   ),
#   
#   # Dropdown menu for tasks, with progress bar
#   dropdownMenu(type = "tasks", badgeStatus = "danger",
#                taskItem(value = 20, color = "aqua",
#                         "Refactor code"
#                ),
#                taskItem(value = 40, color = "green",
#                         "Design new layout"
#                ),
#                taskItem(value = 60, color = "yellow",
#                         "Another task"
#                ),
#                taskItem(value = 80, color = "red",
#                         "Write documentation"
#                )
#   )
# )
# 
# 
# body <- dashboardBody(
#   
#   # valueBoxes
#   fluidRow(
#     valueBox(
#       uiOutput("orderNum"), "New Orders", icon = icon("credit-card"),
#       href = "http://google.com"
#     ),
#     valueBox(
#       tagList("60", tags$sup(style="font-size: 20px", "%")),
#       "Approval Rating", icon = icon("line-chart"), color = "green"
#     ),
#     valueBox(
#       htmlOutput("progress"), "Progress", icon = icon("users"), color = "purple"
#     )
#   ),
#   
#   # Boxes
#   fluidRow(
#     box(status = "primary",
#         sliderInput("orders", "Orders", min = 1, max = 500, value = 120),
#         selectInput("progress", "Progress",
#                     choices = c("0%" = 0, "20%" = 20, "40%" = 40, "60%" = 60, "80%" = 80,
#                                 "100%" = 100)
#         )
#     ),
#     box(title = "Histogram box title",
#         status = "warning", solidHeader = TRUE, collapsible = TRUE,
#         plotOutput("plot", height = 250)
#     )
#   ),
#   
#   # Boxes with solid color, using `background`
#   fluidRow(
#     # Box with textOutput
#     box(
#       title = "Status summary",
#       background = "green",
#       width = 4,
#       textOutput("status")
#     ),
#     
#     # Box with HTML output, when finer control over appearance is needed
#     box(
#       title = "Status summary 2",
#       width = 4,
#       background = "red",
#       uiOutput("status2")
#     ),
#     
#     box(
#       width = 4,
#       background = "light-blue",
#       p("This is content. The background color is set to light-blue")
#     )
#   )
# )

