(function() {
    print(getwd())
    
    # http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
    con <- file("./bad-words-dict/bad-words-banned-by-google.txt", "r")
    swear.words <- readLines(con, warn=F)
    close(con)
    # http://www.bannedwordlist.com/
    con <- file("./bad-words-dict/swearWords.txt", "r")
    swear.words <- c(swear.words, readLines(con, warn=F))
    close(con)
    
    CleanCorpus <<- function(corpus, remove.stop.words=T) {
        getTransformations()
        result <- tm_map(corpus, content_transformer(tolower))
        result <- tm_map(result, removePunctuation)
        result <- tm_map(result, removeNumbers)
        if (remove.stop.words) {
            # Remove english stop words (like the, a, an, etc)
            result <- tm_map(result, removeWords, stopwords("english"))
        }
        # Remove profanity words
        result <- tm_map(result, removeWords, swear.words)
        RemoveByPattern <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
        # Remove URLs
        result <- tm_map(result, RemoveByPattern, "(ht|f)tps?://([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?")
        # Remove emails
        result <- tm_map(result, RemoveByPattern, "([a-z0-9_\\.-]+)@([a-z0-9_\\.-]+)\\.([a-z\\.]{2,6})")
        # Remove accounts
        result <- tm_map(result, RemoveByPattern, "@[^\\s]+")
        return (tm_map(result, stripWhitespace))
    }
})()
