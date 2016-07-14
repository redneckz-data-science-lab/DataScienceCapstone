(function() {
    library("stringi", quietly=T)
    library("data.table", quietly=T)
    source("clean-corpus.R", chdir=T)
    
    PredictNextWords <<- function(ngram.freq, query.text,
                                  query.tokenize.strategy=TokenizeQuery,
                                  query.variate.strategy=VariateQueryByBackOff,
                                  string.eq.strategy=StringEq,
                                  ordering.strategy=OrderByFreq,
                                  result.prepare.strategy=identity,
                                  max.ngram.count=10L) {
        query.variants <- query.variate.strategy(query.tokenize.strategy(query.text))
        result <- Reduce(function(result, query) {
            if (nrow(result) < max.ngram.count) {
                return(FindNGramsByQuery(ngram.freq, query,
                                         string.eq.strategy,
                                         ordering.strategy,
                                         max.ngram.count))
            } else {
                return(result)
            }
        }, query.variants, init=data.table())
        return(result.prepare.strategy(result))
    }
    
    FindNGramsByQuery <- function(ngram.freq, query.words,
                                  string.eq.strategy,
                                  ordering.strategy,
                                  max.ngram.count) {
        if ((nrow(ngram.freq) == 0L) || (length(query.words) == 0L)) {
            return(data.table())
        }
        target.n <- length(query.words) + 1L
        target.query <- paste(query.words, collapse=" ")
        result <- ordering.strategy(ngram.freq[target.n == n][string.eq.strategy(target.query,
                                                                                 first.words)])
        return(head(result, max.ngram.count))
    }
    
    TokenizeQuery <<- function(query.text) {
        cleaned.query.corpus <- CleanCorpus(VCorpus(VectorSource(query.text)))
        cleaned.query.text <- cleaned.query.corpus[[1L]]$content
        return(stri_extract_all_words(cleaned.query.text)[[1L]])
    }
    
    VariateQueryByBackOff <<- function(query, max.n=4L) Map(function(i) tail(query, i),
                                                            min(max.n, length(query)):1)
    
    StringEq <- function(a, b) a == b
    
    OrderByFreq <- function(ngram.freq) ngram.freq[order(-freq)]
})()