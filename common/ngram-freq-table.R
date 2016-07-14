(function() {
    library("tm", quietly=T)
    library("data.table", quietly=T)
    library("stringi", quietly=T)
    
    MergeNGramFreqTables <<- function(x, y) {
        setkey(x, first.words, last.word, n)
        setkey(y, first.words, last.word, n)
        res <- merge(x, y, all=T)
        res[, freq := AdjustNAs(freq.x) + AdjustNAs(freq.y)]
        res[, freq.x := NULL]
        res[, freq.y := NULL]
        return(res)
    }
    
    ToNGramFreqTable <<- function(term.doc.matrix) {
        iv <- data.table(i=term.doc.matrix$i, v=as.integer(term.doc.matrix$v))
        ngram.freq <- iv[, list(freq=sum(v)), by=i]
        terms <- Terms(term.doc.matrix)[ngram.freq$i]
        index <- stri_locate_last_fixed(terms, " ")[, "start"]
        ngram.freq[, first.words := ifelse(is.na(index), "",
                                           stri_sub(terms, to=index - 1L))]
        ngram.freq[, last.word := ifelse(is.na(index), terms,
                                         stri_sub(terms, from=index + 1L))]
        ngram.freq[, n := stri_count_words(terms)]
        ngram.freq[, i := NULL]
        setkey(ngram.freq, first.words, last.word)
        return(ngram.freq)
    }
    
    AdjustNAs <- function(v, def.val=0L) ifelse(is.na(v), def.val, v)
})()