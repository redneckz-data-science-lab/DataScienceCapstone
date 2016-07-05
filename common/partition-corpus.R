(function() {
    LoadPartitionedCorpus <<- function(files) {
        corpus <- Map(f=function(file.path) {
            
        }, files)
        return(Reduce(f=function(a, b) c(a, b), x=corpus))
    }
    
    PartitionCorpus <<- function(in.dir, out.dir,
                                 chunk.reader, chunk.skiper) {
        in.files <- list.files(in.dir, pattern=".txt$", full.names=T)
        dir.create(out.dir, showWarnings=F)
        for (in.file.path in in.files) {
            PartitionFile(in.file.path, out.dir,
                          chunk.reader, chunk.skiper)
        }
    }
    
    PartitionFile <- function(in.file.path, out.dir,
                              chunk.reader, chunk.skiper) {
        in.con <- file(in.file.path, "r")
        chunk.count <- 0
        repeat {
            out.file.path <- file.path(out.dir,
                                       paste(basename(in.file.path),
                                             chunk.count, "rds", sep="."))
            if (file.exists(out.file.path)) {
                chunk.skiper(in.con)
            } else {
                chunk <- chunk.reader(in.con)
                if (length(chunk) == 0) {
                    break
                }
                saveRDS(chunk, file=out.file.path)
            }
            chunk.count <- chunk.count + 1
        }
        close(in.con)
    }
})()
