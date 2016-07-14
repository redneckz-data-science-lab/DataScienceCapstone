library(shiny)

shinyUI(fluidPage(
    titlePanel("Data Science Capstone: Smart Keyboard",
               windowTitle="Data Science Capstone: Smart Keyboard"),
    fluidRow(
        column(width=12,
               p("Around the world, people are spending an increasing amount of time on their mobile devices for email, social networking, ant etc. Smart keyboard makes it easier for people to type on their mobile devices. One cornerstone of smart keyboard is predictive text models."),
               p("This project is aimed on building predictive text models like those used by ", strong("SwiftKey"), "."),
               p(tags$strong("Please enter some phrase in the text field below and explore the prediction results on the right."))
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
            h4("Settings"),
            sliderInput("maxResultCount", "Max result count:",
                        min=10, max=100, value=100, step=10),
            tags$hr(),
            h4("Algorithm steps"),
            tags$ol(
                tags$li(tags$strong("Clean phrase:"),
                        textOutput("cleanedQuery")),
                tags$li(tags$strong("Variate phrase:"),
                        textOutput("queryVariants")),
                tags$li(tags$strong("Find n-grams:"))
            )
        ),
        mainPanel(
            fluidPage(
                tabsetPanel(
                    tabPanel("Prediction Results",
                             p(tags$strong(textOutput("query", inline=T)),
                               textOutput("result", inline=T))),
                    tabPanel("Details",
                             DT::dataTableOutput("resultDetails"))
                )
            )
        )
    ),
    fluidRow(
        column(width=12,
               h4("Reports"),
               tags$ol(
                   tags$li(tags$a("Smart Keyboard Exploratory Data Analysis Report",
                                  href="http://rpubs.com/redneckz/smart-keyboard-exploratory-data-analysis")),
                   tags$li(tags$a("Smart Keyboard Basic Modeling Report",
                                  href="http://rpubs.com/redneckz/smart-keyboard-basic-modeling"))
               ))
    )
))
