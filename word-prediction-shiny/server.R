library("shiny")
library("stringi")
library("stringdist")

source("../common/kneser-ney.R", chdir=T)

kn.train.freq.table <- readRDS("../basic-modeling/output/kn.train.freq.table.rds")

shinyServer(function(input, output) {
    inTokenizedQuery <- reactive({
        TokenizeQuery(input$query)
    })
    inPredictionResult <- reactive({
        PredictNextWordsByKneserNey(kn.train.freq.table,
                                    query.text=input$query,
                                    max.ngram.count=input$maxResultCount)
    })
    
    output$cleanedQuery <- renderText({
        paste(inTokenizedQuery(), collapse=" ")
    })
    output$queryVariants <- renderText({
        stri_c_list(VariateQueryByBackOff(inTokenizedQuery()), collapse="; ", sep=" ")
    })
    output$query <- renderText({
        paste(input$query, ": ", sep="")
    })
    output$result <- renderText({
        paste(inPredictionResult()[, last.word], collapse="; ")
    })
    output$resultDetails <- DT::renderDataTable({
        result <- inPredictionResult()[, .("Preceeding Words"=first.words,
                                           "Predicted Word"=last.word,
                                           "Rate"=freq)]
        DT::datatable(result, options=list(lengthMenu=c(10, 25, 100),
                                           pageLength=10,
                                           searching=F))
    })
})
