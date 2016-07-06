(function() {
    CombinePartitions <<- function(partition.files,
                                   map.f=identity, reduce.f=c) {
        read <- function(in.file.path) map.f(readRDS(in.file.path))
        acc <- read(head(partition.files, 1L))
        for (in.file.path in tail(partition.files, -1L)) {
            acc <- reduce.f(acc, read(in.file.path))
        }
        return(acc)
    }
    
    MapPartitions <<- function(f, in.dir, out.dir) {
        dir.create(out.dir, showWarnings=F)
        IterateOverPartitions(function(corpus, name) {
            out.file.path <- file.path(out.dir, name)
            if (!file.exists(out.file.path)) {
                saveRDS(f(corpus), out.file.path)
            }
        }, in.dir)
    }
            
    IterateOverPartitions <<- function(f, in.dir) {
        in.files <- list.files(in.dir, pattern=".rds$", full.names=T)
        for (in.file.path in in.files) {
            f(corpus=readRDS(in.file.path), name=basename(in.file.path))
        }
    }
    
    PartitionCorpus <<- function(in.dir, out.dir,
                                 chunk.reader, chunk.skiper) {
        in.files <- list.files(in.dir, pattern=".txt$", full.names=T)
        dir.create(out.dir, showWarnings=F)
        for (in.file.path in in.files) {
            PartitionCorpusFile(in.file.path, out.dir,
                                chunk.reader, chunk.skiper)
        }
    }
    
    PartitionCorpusFile <- function(in.file.path, out.dir,
                                    chunk.reader, chunk.skiper) {
        in.con <- file(in.file.path, "r")
        chunk.count <- 0L
        repeat {
            out.file.path <- file.path(out.dir,
                                       paste(basename(in.file.path),
                                             chunk.count, "rds", sep="."))
            if (file.exists(out.file.path)) {
                chunk.skiper(in.con)
            } else {
                chunk <- chunk.reader(in.con)
                if (length(chunk) == 0L) {
                    break
                }
                saveRDS(chunk, file=out.file.path)
            }
            chunk.count <- chunk.count + 1L
        }
        close(in.con)
    }
})()
