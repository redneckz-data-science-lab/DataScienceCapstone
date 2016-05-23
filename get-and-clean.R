library("tm")

ReadAndCleanCorpus <- function(dir, prob=0.001) {
    files <- list.files(dir, pattern=".txt$", full.names=T)
    lines <- character()
    for (path in files) {
        lines <- c(lines, ReadSomeLines(path, prob))
    }
    corpus <- CreateCorpus(lines)
    return (CleanCorpus(corpus))
}

ReadSomeLines <- function(path, prob) {
    con <- file(path, "r")
    result <- numeric()
    while (length(line <- readLines(con, n=1, warn=F)) > 0) {
        if (rbinom(1, 1, prob) == 1) {
            result <- c(result, line)
        }
    }
    close(con)
    return (result)
}

CreateCorpus <- function(lines) VCorpus(VectorSource(lines))

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
    result <- tm_map(result, RemoveByPattern, "(ht|f)tps?://([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?")
    # Remove emails
    result <- tm_map(result, RemoveByPattern, "([a-z0-9_\\.-]+)@([a-z0-9_\\.-]+)\\.([a-z\\.]{2,6})")
    # Remove accounts
    result <- tm_map(result, RemoveByPattern, "@[^\\s]+")
    return (tm_map(result, stripWhitespace))
}

RemoveByPattern <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
