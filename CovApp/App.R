#install.packages("tidyverse")
#install.packages("stringr")


library("shiny")
library("tidyverse")
library("stringr")

# load files, files must be in the same directory as App.R script
# List of genes for user selection
genelist <- read_tsv("CovGeneSymbOct2018.txt")
# coverage data
covtidy <- read_tsv("covtidy.txt")

# User interface: loads page with sidebar, user selects a gene from the drop down menu. 
ui <-pageWithSidebar(
  # Application title
  titlePanel("Horizontal coverage for WES"),
  # Sidebar- allows user to enter gene
  sidebarPanel(selectizeInput(inputId = "genename", label = "Enter HGNC gene symbol", choices = genelist, selected = "FXYD3", multiple = FALSE, 
                             options = list(placeholder ='Gene Symbol'))),
  # main pannel will dipaly selected gene and associated coverage box plot (calculated in the server section)
  mainPanel(h3("% of bases above 20X", align = "center"), h4(textOutput("caption"), align = "center"), plotOutput(outputId = "boxplot"), h6("Box plot shows 1st-3rd quartile, with the median value represented by a horizontal line. Outliers are defined as data points less than or greater than 1.5 times the interquartile range beyond the 1st and 3rd quartiles respectively, and are represented by dots. Whiskers show the range of inliers. Coverage calculated for RefSeq exonic bases +/- 5bp. N = 100 exomes (Agilent SureSelect Clinical Research Exome).")))

# Server: Calaculates coverage boxplot for gene specified by the user
server <- function(input, output){output$caption <- renderText(input$genename)
  output$boxplot <- renderPlot({covtsubset <- filter(covtidy, Gene == input$genename) 
  p <- ggplot(covtsubset, aes(x="", y=above20X)) + geom_boxplot(aes(group = Gene)) + coord_cartesian(ylim = c(0, 100)) 
  print(p)})}

shinyApp(ui = ui, server = server)
