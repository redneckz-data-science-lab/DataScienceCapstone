library(shiny)
library(stringi)
library(stringdist)
library(wordcloud)
library(RColorBrewer)

source("common/kneser-ney.R", chdir=T)

shinyServer(function(input, output) {
    kn.train.freq.table <- readRDS("basic-modeling/output/kn.train.freq.table.rds")
    
    inTokenizedQuery <- reactive({
        TokenizeQuery(input$query)
    })
    inStringEqStrategy <- reactive({
        metric <- input$stringDistanceMetric
        th <- input$stringDistanceThreshold / 100
        if ("eq" == metric) {
            return(StringEq)
        } else {
            return(function(a, b) stringdist(a, b, method=metric) <= th)
        }
    })
    inPredictionResult <- reactive({
        if (input$kneser) {
            return(PredictNextWordsByKneserNey(kn.train.freq.table,
                                               query.text=input$query,
                                               max.ngram.count=input$maxResultCount))
        } else {
            return(PredictNextWords(kn.train.freq.table,
                                    query.text=input$query,
                                    string.eq.strategy=inStringEqStrategy(),
                                    max.ngram.count=input$maxResultCount))
        }
    })
    
    output$dictionarySize <- renderText({
        format(nrow(kn.train.freq.table), big.mark=" ")
    })
    output$cleanedQuery <- renderText({
        paste(inTokenizedQuery(), collapse=" ")
    })
    output$query <- renderText({
        paste(input$query, ": ", sep="")
    })
    output$result <- renderText({
        paste(inPredictionResult()[, last.word], collapse=", ")
    })
    output$resultWordCloud <- renderPlot({
        prediction.result <- inPredictionResult()
        suppressWarnings(
            wordcloud(prediction.result[, last.word],
                      seq(100, 1, length.out=nrow(prediction.result)),
                      random.color=F, random.order=F,
                      colors=brewer.pal(10, "Spectral"),
                      rot.per=0, fixed.asp=F, scale=c(10, 1))
        )
    })
    output$resultTable <- DT::renderDataTable({
        prediction.result <- inPredictionResult()
        if (input$kneser) {
            prepared.result <- prediction.result[, .("Preceeding Words"=first.words,
                                                     "Predicted Word"=last.word,
                                                     "Kneser-Ney Prob."=p.kn)]
        } else {
            prepared.result <- prediction.result[, .("Preceeding Words"=first.words,
                                                     "Predicted Word"=last.word,
                                                     "Rate"=freq)]
        }
        DT::datatable(prepared.result, options=list(lengthMenu=c(10, 25, 100),
                                                    pageLength=10,
                                                    searching=F))
    })
})
