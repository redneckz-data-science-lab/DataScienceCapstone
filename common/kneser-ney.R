(function() {
    library("gmp", quietly=T)
    
    SmoothNgramFreqTableByKneserNey <<- function(ngram.freq.table, delta=0.75) {
        ngram.freq.table[, c("p.kn.numerator", "p.kn.denominator") := list(0L, 0L)]
        SmoothNgrams(ngram.freq.table, delta)
    }
    
    SmoothNgrams <- function(ngram.freq.table, delta, target.n=1L) {
        if (ngram.freq.table[target.n == n, .N] == 0L) {
            return()
        }
        if (target.n == 1L) {
            # Unigrams
            SmoothUnigrams(ngram.freq.table)
        } else {
            by.first.words <- ngram.freq.table[target.n == n,
                                               list(N=.N,
                                                    total.freq=sum(freq)),
                                               by=first.words]
            setkey(by.first.words, first.words)
            ComputePkn <- function(first.words, last.word, freq) {
                p <- as.bigq(pmax(freq - delta, 0),
                             by.first.words[first.words, total.freq])
                lambda <- as.bigq(delta * by.first.words[first.words, N],
                                  by.first.words[first.words, total.freq])
                ngram.freq.backoff <- ngram.freq.table[(target.n - 1L) == n]
                setkey(ngram.freq.backoff, first.words, last.word)
                first.words.backoff <- stri_replace_first_regex(first.words, 
                                                                "^\\S+ ?", "",
                                                                perl=T)
                last.word.backoff <- last.word
                p.backoff <- ngram.freq.backoff[list(first.words=first.words.backoff,
                                                     last.word=last.word.backoff),
                                                as.bigq(p.kn.numerator,
                                                        p.kn.denominator)]
                p.kn <- p + lambda * ifelse(is.na(p.backoff), as.bigq(0), p.backoff)
                return(list(as.integer(numerator(p.kn)), as.integer(denominator(p.kn))))
            }
            ngram.freq.table[target.n == n,
                             c("p.kn.numerator",
                               "p.kn.denominator") := ComputePkn(first.words,
                                                                 last.word, freq)]
        }
        SmoothNgrams(ngram.freq.table, target.n + 1L)
    }
    
    SmoothUnigrams <- function(ngram.freq.table) {
        bigram.count <- ngram.freq.table[n == 2L, .N]
        by.last.word <- ngram.freq.table[n == 2L, .N, by=last.word]
        setkey(by.last.word, last.word)
        numerator <- by.last.word[ngram.freq.table[n == 1L, last.word], N]
        denominator <- bigram.count + sum(is.na(numerator))
        ngram.freq.table[n == 1L,
                         c("p.kn.numerator",
                           "p.kn.denominator") := list(AdjustNAs(numerator),
                                                       denominator)]
    }
    
    AdjustNAs <- function(freq) ifelse(is.na(freq), 1L, freq)
})()