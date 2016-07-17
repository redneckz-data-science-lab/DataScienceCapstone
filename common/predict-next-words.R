(function() {
    library("stringi", quietly=T)
    library("data.table", quietly=T)
    source("clean-corpus.R", chdir=T)
    
    PredictNextWords <<- function(ngram.freq, query.text,
                                  query.tokenize.strategy=TokenizeQuery,
                                  query.variate.strategy=VariateQueryByBackOff,
                                  string.eq.strategy=stri_cmp_eq,
                                  ordering.strategy=OrderByFreq,
                                  result.prepare.strategy=identity,
                                  max.ngram.count=10L) {
        if (is.null(ngram.freq) || is.null(query.text) ||
                stri_isempty(stri_trim(query.text))) {
            return(result.prepare.strategy(data.table()))
        }
        query.words <- query.tokenize.strategy(query.text)
        query.words <- RemoveLastUncompleteWord(ngram.freq, query.words)
        query.variants <- query.variate.strategy(query.words)
        result <- Reduce(function(result, query) {
            if (nrow(result) < max.ngram.count) {
                return(rbind(result, FindNGramsByQuery(ngram.freq, query,
                                                       string.eq.strategy,
                                                       ordering.strategy,
                                                       max.ngram.count)))
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
        result <- ordering.strategy(ngram.freq[(target.n == n) &
                                                   string.eq.strategy(target.query,
                                                                      first.words)])
        return(head(result, max.ngram.count))
    }
    
    TokenizeQuery <- function(query.text) {
        cleaned.query.text <- CleanQuery(query.text)
        return(stri_extract_all_words(cleaned.query.text)[[1L]])
    }
    
    RemoveLastUncompleteWord <- function(ngram.freq, query.words) {
        target.last.word <- tail(query.words, 1L)
        if (ngram.freq[(n == 2L) & (target.last.word == last.word), .N] > 0L) {
            return(query.words)
        } else {
            return(head(query.words, -1L))
        }
    }
    
    VariateQueryByBackOff <- function(query, max.n=4L) Map(function(i) tail(query, i),
                                                           min(max.n, length(query)):1)
    
    OrderByFreq <- function(ngram.freq) ngram.freq[order(-freq)]
})()