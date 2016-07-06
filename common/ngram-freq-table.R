(function() {
    library("tm", quietly=T)
    library("data.table", quietly=T)
    library("stringi", quietly=T)
    
    MergeNGramFreqTables <<- function(x, y) {
        res <- merge(x, y, by=c("first.words", "last.word", "n"), all=T)
        res[is.na(freq.x), freq.x := 0L]
        res[is.na(freq.y), freq.y := 0L]
        res[, freq := freq.x + freq.y]
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
})()