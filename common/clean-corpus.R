(function() {
    library("tm", quietly=T)
    
    swear.words <- c(
            # http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
            readLines("./bad-words-dict/bad-words-banned-by-google.txt", warn=F, skipNul=T),
            # http://www.bannedwordlist.com/
            readLines("./bad-words-dict/swearWords.txt", warn=F, skipNul=T))

    getTransformations()

    CleanCorpus <<- function(corpus) {
        RemoveByPattern <- content_transformer(function(x, pattern) gsub(pattern, "", x, perl=T))
        RemoveURLs <- function(x) RemoveByPattern(x, "([a-z]+://|www\\.)\\S+")
        RemoveEmails <- function(x) RemoveByPattern(x, "([a-z0-9]\\S*)@([a-z0-9]\\S*)\\.([a-z.]{2,6})")
        RemoveAccounts <- function(x) RemoveByPattern(x, "@\\S+")
        RemoveSpecials <- function(x) RemoveByPattern(x, "[^a-z.,\\s]")
        RemoveStopWords <- function(x) removeWords(x, stopwords("english"))
        RemoveSwearWords <- function(x) removeWords(x, swear.words)
        transformations <- list(stripWhitespace,
                                RemoveSwearWords,
                                RemoveStopWords,
                                RemoveSpecials,
                                RemoveAccounts,
                                RemoveEmails,
                                RemoveURLs,
                                content_transformer(tolower))
        return(tm_map(corpus, FUN=tm_reduce, tmFuns=transformations))
    }
    
    CleanQuery <<- function(query.text) {
        cleaned.query.corpus <- CleanCorpus(VCorpus(VectorSource(query.text)))
        return(cleaned.query.corpus[[1L]]$content)
    }
})()
