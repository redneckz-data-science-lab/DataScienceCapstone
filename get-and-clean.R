library("tm")

ReadSomeLines <- function(path, prob=0.01) {
    con <- file(path, "r")
    result <- vector("numeric")
    while (length(line <- readLines(con, n=1, warn=F)) > 0) {
        if (rbinom(1, 1, prob) == 1) {
            result <- c(result, line)
        }
    }
    close(con)
    return (result)
}

CreateCorpus <- function(lines) VCorpus(VectorSource(lines))

removeByPattern <- content_transformer(function(x, pattern) gsub(pattern, " ", x))

CleanCorpus <- function(corpus) {
    getTransformations()
    result <- tm_map(corpus, content_transformer(tolower))
    result <- tm_map(result, removePunctuation)
    result <- tm_map(result, removeNumbers)
    # Remove english stop words (like the, a, an, etc)
    result <- tm_map(result, removeWords, stopwords("english"))
    # Remove profanity words
    # http://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
    con <- file("bad-words-banned-by-google.txt", "r")
    swear.words <- readLines(con, warn=F)
    close(con)
    # http://www.bannedwordlist.com/
    con <- file("swearWords.txt", "r")
    swear.words <- c(swear.words, readLines(con, warn=F))
    close(con)
    result <- tm_map(result, removeWords, swear.words)
    # Remove URLs
    result <- tm_map(result, removeByPattern, "(ht|f)tps?://([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?")
    # Remove emails
    result <- tm_map(result, removeByPattern, "([a-z0-9_\\.-]+)@([a-z0-9_\\.-]+)\\.([a-z\\.]{2,6})")
    # Remove accounts
    result <- tm_map(result, removeByPattern, "@[^\\s]+")
    return (tm_map(result, stripWhitespace))
}

