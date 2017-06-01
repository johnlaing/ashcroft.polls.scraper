require(XLConnect)
if (length(commandArgs(TRUE)) != 1) stop("usage: Rscript . <unzip dir>")
unzip.dir <- commandArgs(TRUE)[1]
ff <- list.files(unzip.dir, "^Welcome")
stopifnot(grepl("\\.xlsx$", ff))

get.const.name <- function(f) {
    wb <- loadWorkbook(file.path(unzip.dir, f))
    filt <- readWorksheet(wb, "Filters")
    filt$Option
}

for (f in ff) {
    cn <- get.const.name(f)
    file.rename(file.path(unzip.dir, f),
        file.path(unzip.dir, paste0(cn, ".xlsx")))
}
