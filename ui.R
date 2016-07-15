library(shiny)

shinyUI(fluidPage(
    titlePanel("Smart Keyboard",
               windowTitle="Data Science Capstone: Smart Keyboard"),
    fluidRow(
        column(width=12,
               p("Around the world, people are spending an increasing amount of time on their mobile devices for email, social networking, ant etc.",
                 "Smart keyboard makes it easier for people to type on their mobile devices. One cornerstone of smart keyboard is predictive text models.",
                 "This project is aimed on building predictive text models like those used by", strong("SwiftKey"), "."),
               conditionalPanel(condition="output.dictionarySize",
                                p("The algorithm is based on n-gram frequency table with size equals to",
                                  tags$strong(textOutput("dictionarySize", inline=T), "n-grams."))),
               conditionalPanel(condition="!output.dictionarySize",
                                p("The algorithm is based on n-gram frequency table approach.")),
               h4("Please enter some phrase in the text field below and explore the prediction results on the right.")
        )
    ),
    fluidRow(
        column(width=12,
               textInput("query", value="I'm going to say something",
                         placeholder="Uncompleted phrase",
                         label="", width="100%")
        )
    ),
    sidebarLayout(
        sidebarPanel(
            selectInput("resultViewMode", label="Result view mode", 
                        choices=list("Text"=1, "Plot"=2, "Table"=3), 
                        selected=1),
            sliderInput("maxResultCount", label="Max result count",
                        min=10, max=100, value=25, step=10),
            checkboxInput("kneser", label="Kneser-Ney smoothing", value=F),
            conditionalPanel(condition="!input.kneser",
                selectInput("stringDistanceMetric", label="Str. distance metric", 
                            choices=list("Equality"="eq", "Q-gram"="qgram",
                                         "Cosine"="cosine", "Jaccard"="jaccard"), 
                            selected="eq"),
                conditionalPanel(condition="input.stringDistanceMetric != 'eq'",
                    sliderInput("stringDistanceThreshold", label="Str. distance threshold",
                                min=0, max=50, value=0, step=1, post="%")
                )
            ),
            conditionalPanel(condition="output.dictionarySize",
                p(tags$strong("Cleaned query")),
                textOutput("cleanedQuery")
            )
        ),
        mainPanel(
            conditionalPanel(condition="!output.dictionarySize",
                             h4("Please wait until the dictionary is loaded...")),
            conditionalPanel(condition="input.resultViewMode == 1",
                             p(tags$strong(textOutput("query", inline=T)),
                               textOutput("result", inline=T))),
            conditionalPanel(condition="input.resultViewMode == 2",
                             plotOutput("resultWordCloud")),
            conditionalPanel(condition="input.resultViewMode == 3",
                             DT::dataTableOutput("resultTable"))
        )
    ),
    fluidRow(
        column(width=6,
               h4("Reports"),
               tags$ol(
                   tags$li(tags$a("Smart Keyboard Exploratory Data Analysis Report",
                                  href="http://rpubs.com/redneckz/smart-keyboard-exploratory-data-analysis")),
                   tags$li(tags$a("Smart Keyboard Basic Modeling Report",
                                  href="http://rpubs.com/redneckz/smart-keyboard-basic-modeling"))
               )
        ),
        column(width=6,
               h4("Useful Links"),
               tags$ol(
                   tags$li("Fast and efficient data.frame extension -",
                           tags$a("data.table",
                                  href="https://cran.r-project.org/web/packages/data.table/index.html")),
                   tags$li("Text mining package -",
                           tags$a("tm",
                                  href="https://cran.r-project.org/web/packages/tm/index.html")),
                   tags$li("Collection of machine learning algorithms -",
                           tags$a("RWeka",
                                  href="https://cran.r-project.org/web/packages/RWeka/index.html")),
                   tags$li("String processing facilities -",
                           tags$a("stringi",
                                  href="https://cran.r-project.org/web/packages/stringi/index.html")),
                   tags$li("String distance functions -",
                           tags$a("stringdist",
                                  href="https://cran.r-project.org/web/packages/stringdist/index.html"))
               )
        )
    )
))
