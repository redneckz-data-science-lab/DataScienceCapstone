library(shiny)

shinyUI(fluidPage(
    titlePanel("Smart Keyboard",
               windowTitle="Data Science Capstone: Smart Keyboard"),
    fluidRow(
        column(width=12,
               textInput("query", value="I'm going to say something",
                         placeholder="Uncompleted phrase",
                         label="", width="100%")
        )
    ),
    sidebarLayout(
        mainPanel(
            conditionalPanel(condition="!output.dictionarySize",
                             tags$strong("Please wait until the dictionary is loaded...")),
            conditionalPanel(condition="input.resultViewMode == 1",
                             p(tags$strong(textOutput("cleanedQuery", inline=T)),
                               textOutput("result", inline=T))),
            conditionalPanel(condition="input.resultViewMode == 2",
                             plotOutput("resultWordCloud")),
            conditionalPanel(condition="input.resultViewMode == 3",
                             DT::dataTableOutput("resultTable"))
        ),
        sidebarPanel(
            selectInput("resultViewMode", label="Result View Mode", 
                        choices=list("Text"=1, "Plot"=2, "Table"=3), 
                        selected=1),
            sliderInput("maxResultCount", label="Max Result Count",
                        min=10, max=100, value=25, step=10),
            checkboxInput("kneser", label="Kneser-Ney Smoothing", value=F),
            conditionalPanel(condition="!input.kneser",
                selectInput("stringMetric", label="String Metric", 
                            choices=list("Equality"="eq", "Q-gram"="qgram",
                                         "Cosine"="cosine", "Jaccard"="jaccard"), 
                            selected="eq"),
                conditionalPanel(condition="input.stringMetric != 'eq'",
                    sliderInput("stringMetricThreshold", label="Str. Metric Threshold",
                                min=0, max=50, value=0, step=1, post="%")
                )
            )
        )
    ),
    fluidRow(
        column(width=12,
               helpText("Around the world, people are spending an increasing amount of time on their mobile devices for email, social networking, ant etc.",
                        "Smart keyboard makes it easier for people to type on their mobile devices. One cornerstone of smart keyboard is predictive text models.",
                        "This project is aimed on building predictive text models like those used by SwiftKey.")
               ),
        column(width=12,
               conditionalPanel(condition="output.dictionarySize",
                                helpText("The algorithm is based on n-gram frequency table with size equals to",
                                         textOutput("dictionarySize", inline=T), "n-grams.")),
               conditionalPanel(condition="!output.dictionarySize",
                                helpText("The algorithm is based on n-gram frequency table approach."))
        ),
        column(width=12,
               tags$strong("More details"),
               tags$ol(
                   tags$li(tags$a("Exploratory Data Analysis Report",
                                  href="http://rpubs.com/redneckz/smart-keyboard-exploratory-data-analysis")),
                   tags$li(tags$a("Basic Modeling Report",
                                  href="http://rpubs.com/redneckz/smart-keyboard-basic-modeling"))
               )
        )
    )
))
