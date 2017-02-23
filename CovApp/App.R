library(shiny)
library("tidyverse")
library("stringr")

# load files, files must be in the same directory as App.R script
# List of genes for user selection
genelist <- read_tsv("CovGeneSymbFeb2017.txt")
# coverage data
covtidy <- read_tsv("covtidy.txt")

# User interface: loads page with sidebar, user selects a gene from the drop down menu. 
ui <-pageWithSidebar(
  # Application title
  headerPanel("WES Gene Coverage"),
  # Sidebar- allows user to enter gene
  sidebarPanel(selectizeInput(inputId = "genename", label = "Enter HGNC gene symbol", choices = genelist, selected = NULL, multiple = FALSE, 
                             options = list(placeholder ='Gene Symbol'))),
  # main pannel will dipaly selected gene and associated coverage box plot (calculated in the server section)
  mainPanel(h4(textOutput("caption"), align = "center"), plotOutput(outputId = "boxplot")))

# Server: Calaculates coverage boxplot for gene specified by the user
server <- function(input, output){output$caption <- renderText(input$genename)
  output$boxplot <- renderPlot({covtsubset <- filter(covtidy, Gene == input$genename) 
  p <- ggplot(covtsubset, aes(x="", y=above20X)) + geom_boxplot(aes(group = Gene)) + coord_cartesian(ylim = c(0, 100)) 
  print(p)})}

shinyApp(ui = ui, server = server)
