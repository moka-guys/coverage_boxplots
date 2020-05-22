library("shiny")
library("tidyverse")
library("stringr")

# Load coverage data from the same directory as App.R
covtidy <- read_tsv("covtidy.txt")
covtidy_genes <- read_tsv("covtidy_genes.txt", col_names="genes")
covtidy_median <- read_csv("covtidy_median.txt", col_names=c("genes","median","hgnc"))

# User interface
ui <-pageWithSidebar(
  # Application title     
  titlePanel("WES Gene Coverage Boxplot"),
  # Sidebar: allows user to select a gene from the drop down menu
  sidebarPanel(
    selectizeInput(
      inputId = "genename",
      label = "Enter HGNC gene symbol",
      choices = covtidy_genes$genes,
      selected = "A1BG",
      multiple = FALSE,
      options = list(placeholder ='Gene Symbol')
      ),
    ),
  # Main Panel: Display coverage box plot for a selected gene. This is calculated by the server object below.
  mainPanel(
    h3(textOutput("caption"), align = "center"),
    h4(textOutput("median"), align = "center"),
    plotOutput(outputId = "boxplot"),
    p("In-house WES gene coverage above 20X (N=63; RefSeq exons +/- 5bp).", style="font-weight:600", align="center"),
    p("Disclaimer: This plot shows the first 63 samples processed using the Twist Human Core Exome kit. Plots will be updated as more samples become available.", style="color:red", align="center"),
    p("Interpreting the boxplot: The horizontal line represents the median coverage. The white box contains the 1st to 3rd quartile. Outliers are shown as dots and are defined as any data point (sample gene coverage) less than or greater than 1.5 times interquartile range. Whiskers show the range of inliers.", align="center"),
    p(a("Legacy Coverage Boxplot (Agilent)", href="https://mokaguys.shinyapps.io/covapp"), style="font-size:-3em", align="center")
    )
  )

# Server: Calculate coverage boxplot for genes specified by the user
server <- function(input, output){
  output$caption <- renderText(input$genename)
  output$median <- renderText(
      {
        # Get the median value for the gene from covtidy_median
        median_value = covtidy_median %>% filter(genes==input$genename) %>% select(median) %>% as.character()
        # Wrap the median around a string for the user interface. E.g. 'Median 100% above 20X'
        output_string = paste("Median ", paste(median_value, "%", sep=""), "of bases above 20X coverage", sep=" ")
        # Return the output string  
        return(output_string)
      }
    )
  output$boxplot <- renderPlot(
    {
      covtsubset <- filter(covtidy, Gene == input$genename)
      p <- ggplot(covtsubset, aes(x="", y=above20X)) +
        geom_boxplot(aes(group = Gene)) +
        coord_cartesian(ylim = c(0, 100)) +
        labs(y="Bases covered above 20X (%)", x="Samples") +
        scale_y_continuous(breaks=seq(0,100,10))
      return(p)
    }
  )
}

shinyApp(ui = ui, server = server)
