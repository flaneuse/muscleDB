# Define sidebar for inputs -----------------------------------------------

sidebar <- dashboardSidebar(
  
  
  
  # -- Sidebar icons --
  sidebarMenu(
    # Setting id makes input$tabs give the tabName of currently-selected tab
    id = "tabs",
    menuItem("plot", tabName = "plot", icon = icon("bar-chart"))
  )
)



# Header ------------------------------------------------------------------
header <- dashboardHeader(
  title = "MuscleDB (beta)",
  # -- Message bar --
  dropdownMenu(type = "messages", badgeStatus = NULL, icon = icon("question-circle"),
               messageItem("Muscle Transcriptome Atlas",
                           "about the database",
                           icon = icon("bar-chart"),
                           href="http://flaneuse.github.io/muscleDB/about.html"
               ),
               messageItem("Need help getting started?",
                           "click here", icon = icon("question-circle"),
                           href="http://flaneuse.github.io/muscleDB/help.html"
               ),
               messageItem("Website code and data scripts",
                           "find the code on Github", icon = icon("code"),
                           href = "https://github.com/flaneuse/muscle-transcriptome")
  )
)



# Body --------------------------------------------------------------------

body <- dashboardBody(
  
  # -- Import custom CSS --
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "customStyle.css")),
  
  # -- Each tab --
  tabItems(
    
    # -- Basic plot -- 
    tabItem(tabName = "plot", 
            fluidRow(HTML("<h1><a href = 'http://muscledb.org/'>MuscleDB</a> has moved to <a href = 'http://muscledb.org/'>http://muscledb.org/</a></h1>")),
            fluidRow(HTML("<h3><a href = 'http://muscledb.org/'>MuscleDB</a> is a database containing RNAseq expression
                        levels for 14 different muscle tissues.</h3>")))
    
  ))



# Dashboard definition (main call) ----------------------------------------

dashboardPage(
  title = "MuscleDB: A muscle transcriptome atlas",  
  header,
  sidebar,
  body
)