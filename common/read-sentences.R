(function() {
    library("tm", quietly=T)
    library("openNLP", quietly=T)
    
    annotator <- Maxent_Sent_Token_Annotator()
    
    ReadSentences <<- function(con, chunk.line.count) {
        lines <- readLines(con, n=chunk.line.count, warn=F, skipNul=T)
        if (length(lines) == 0) {
            return(lines)
        }
        sentences <- Map(f=function(line) {
            str <- as.String(line)
            return(str[annotate(str, annotator)])
        }, lines)
        return(Reduce(f=c, x=sentences, init=character()))
    }
})()
