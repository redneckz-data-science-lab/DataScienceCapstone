(function() {
    library("data.table", quietly=T)
    library("stringi", quietly=T)
    
    source("predict-next-words.R", chdir=T)
    
    PredictNextWordsByKneserNey <<- function(ngram.freq, query.text, ...) {
        return(PredictNextWords(ngram.freq, query.text,
                                ordering.strategy=function(ngram.freq) 
                                    ngram.freq[order(-p.kn)],
                                ...))
    }

    SmoothNgramFreqTableByKneserNey <<- function(ngram.freq.table, delta=0.75) {
        ngram.freq.table[, p.kn := 0]
        setkey(ngram.freq.table, first.words, last.word, n)
        SmoothNgrams(ngram.freq.table, delta)
        return(ngram.freq.table)
    }
    
    SmoothNgrams <- function(ngram.freq.table, delta, target.n=1L) {
        if (ngram.freq.table[target.n == n, .N] == 0L) {
            return()
        }
        if (target.n == 1L) {
            # Unigrams
            SmoothUnigrams(ngram.freq.table)
        } else {
            # NGrams
            ComputePkn <- function(target.first.words, target.last.word, target.freq) {
                count.by.first.words <- ngram.freq.table[target.n == n,
                                                         .(count=.N, freq=sum(freq)),
                                                         keyby=first.words]
                p <- ComputeDiscountedP(target.first.words, target.freq,
                                        count.by.first.words)
                lambda <- ComputeLambda(target.first.words,
                                        count.by.first.words)
                backed.off.ngram <- ComputeBackedOffNGrams(target.first.words, target.last.word)
                p.kn.backoff <- ngram.freq.table[backed.off.ngram, p.kn]
                return(p + lambda * AdjustNAs(p.kn.backoff, 0))
            }
            ComputeDiscountedP <- function(target.first.words, target.freq,
                                           count.by.first.words) {
                return(pmax(target.freq - delta, 0) * 100 /
                           count.by.first.words[target.first.words, freq])
            }
            ComputeLambda <- function(target.first.words,
                                      count.by.first.words) {
                return(delta * count.by.first.words[target.first.words, count] /
                           count.by.first.words[target.first.words, freq])
            }
            ComputeBackedOffNGrams <- function(target.first.words, target.last.word) {
                return(list(stri_replace_first_regex(target.first.words, "^\\S+ ?", "",
                                                     perl=T),
                            target.last.word))
            }
            ngram.freq.table[target.n == n, p.kn := ComputePkn(first.words,
                                                               last.word, freq)]
        }
        SmoothNgrams(ngram.freq.table, delta, target.n + 1L)
    }
    
    SmoothUnigrams <- function(ngram.freq.table) {
        computePkn <- function(unigrams) {
            bigram.count.by.last.word <- ngram.freq.table[n == 2L, .(count=.N),
                                                          keyby=last.word]
            numerator <- bigram.count.by.last.word[unigrams, count]
            bigram.count <- ngram.freq.table[n == 2L, .N]
            denominator <- bigram.count + sum(is.na(numerator))
            return(AdjustNAs(numerator) * 100 / denominator)
        }
        ngram.freq.table[n == 1L, p.kn := computePkn(last.word)]
    }

    AdjustNAs <- function(val, default.val=1L) ifelse(is.na(val), default.val, val)
})()