(function() {
    SmoothNgramFreqTableByKneserNey <<- function(ngram.freq.table, delta=0.75) {
        ngram.freq.table[, p.kn := 0]
        SmoothNgrams(ngram.freq.table, delta)
    }
    
    SmoothNgrams <- function(ngram.freq.table, delta, target.n=1) {
        if (ngram.freq.table[target.n == n, .N] == 0) {
            return()
        }
        if (target.n == 1) {
            # Unigrams
            SmoothUnigrams(ngram.freq.table)
        } else {
            by.first.words <- ngram.freq.table[target.n == n,
                                               list(N=.N,
                                                    total.freq=sum(freq)),
                                               by=first.words]
            setkey(count.by.first.words, first.words)
            ComputePkn <- function(first.words, last.word, freq) {
                p <- pmax(freq - delta, 0) / by.first.words[first.words,
                                                            total.freq]
                lambda <- delta * by.first.words[first.words, N] /
                        by.first.words[first.words, total.freq]
                first.words.reduced <- stri_replace_first_regex(first.words, 
                                                                "^\\S+ ?", "",
                                                                perl=T)
                last.word.reduced <- last.word
                p.reduced <- ngram.freq.table[(target.n - 1) == n][
                        first.words %in% first.words.reduced &
                            last.word %in% last.word.reduced, p.kn]
                return(p + lambda * p.reduced)
            }
            ngram.freq.table[target.n == n, p.kn := ComputePkn(first.words,
                                                               last.word,
                                                               freq)]
        }
        SmoothNgrams(ngram.freq.table, target.n + 1)
    }
    
    SmoothUnigrams <- function(ngram.freq.table) {
        bigram.count <- ngram.freq.table[n == 2, .N]
        by.last.word <- ngram.freq.table[n == 2, .N, by=last.word]
        setkey(by.last.word, last.word)
        ngram.freq.table[n == 1,
                         p.kn := by.last.word[last.word, N] / bigram.count]
    }
})()