(function() {
    library("tm", quietly=T)
    
    source("./read-sentences.R", chdir=T)
    
    swear.words <- c(
            # http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
            readLines("./bad-words-dict/bad-words-banned-by-google.txt", warn=F, skipNul=T),
            # http://www.bannedwordlist.com/
            readLines("./bad-words-dict/swearWords.txt", warn=F, skipNul=T))

    getTransformations()

    CleanCorpus <<- function(corpus) {
        RemoveStopWords <- function(x) removeWords(x, stopwords("english"))
        RemoveSwearWords <- function(x) removeWords(x, swear.words)
        RemoveByPattern <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
        RemoveURLs <- function(x) RemoveByPattern(x, "(ht|f)tps?://([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?")
        RemoveEmails <- function(x) RemoveByPattern(x, "([a-z0-9_\\.-]+)@([a-z0-9_\\.-]+)\\.([a-z\\.]{2,6})")
        RemoveAccounts <- function(x) RemoveByPattern(x, "@[^\\s]+")
        transformations <- list(content_transformer(tolower),
                                removePunctuation,
                                removeNumbers,
                                RemoveStopWords,
                                RemoveSwearWords,
                                RemoveURLs,
                                RemoveEmails,
                                RemoveAccounts,
                                stripWhitespace)
        return(tm_map(corpus, FUN=tm_reduce, tmFuns=transformations))
    }
})()
