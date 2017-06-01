## directory to download reports
dl.dir <- file.path(getwd(), paste0("downloads.", format(Sys.time(), "%Y%m%d.%H%M%S")))
dir.create(dl.dir)

## connect to server and navigate to page
require(RSelenium)
rd <- rsDriver(browser="chrome", extraCapabilities=list(chromeOptions=list(prefs=list("download.default_directory"=dl.dir))))
cl <- rd$client
cl$navigate("https://dashboards.lordashcroftpolls.com/login.aspx?target=1rH46DzH68RfFl7AknVWbbl4nsH0s%2f%2fj5uXrUWFycQ4%3d")


## dropdown for selecting constituencies
dropdown <- cl$findElement(using="css", "button.ui-multiselect")
dd.elems <- cl$findElements(using="css", "ul.ui-multiselect-checkboxes > li > label")
update.dd <- cl$findElement(using="css", "span#btnUpdateCharts")

dd.elem.name <- function(e) {
    ## have to open and close dropdown
    dropdown$clickElement()
    nm <- e$findChildElement(value="span")$getElementText()
    dropdown$clickElement()

    stopifnot(length(nm) == 1)
    nm[[1]]
}

select.const <- function(e) {
    dropdown$clickElement()
    e$clickElement()
    update.dd$clickElement()
}


## should be 633 elements: 1 "no selection" + 632 constituencies
stopifnot(length(dd.elems) == 633)
## drop first "no selection"
stopifnot(dd.elem.name(dd.elems[[1]]) == "No selection")
dd.elems <- dd.elems[-1]



## export
export.btn <- cl$findElement(using="css", "div#btnOpenExportPanel")
export.btn$clickElement(); export.btn$clickElement() ## open and close to load panel
excel.btn <- cl$findElement(using="css", "input#downloadSelectedPPTExcel")

dl <- function(max.wait=30) {
    ## generate and wait for link
    export.btn$clickElement()
    len <- length(cl$findElements(using="css", "div#downloadReportsPowerpoint > a"))
    excel.btn$clickElement()
    for (i in seq(max.wait)) {
        lnk <- cl$findElements(using="css", "div#downloadReportsPowerpoint > a")
        if (length(lnk) > len) break
        Sys.sleep(1)
    }
    if (length(lnk) <= len) {
        excel.btn$clickElement()
        stop("timeout: waiting for link")
    }
    lnk <- lnk[[length(lnk)]]

    ## download and wait
    prev.f <- list.files(dl.dir, "^Welcome.*\\.zip$", full.names=TRUE)
    lnk$clickElement()
    export.btn$clickElement()
    for (i in seq(max.wait)) {
        f <- list.files(dl.dir, "^Welcome.*\\.zip$", full.names=TRUE)
        if (length(f) > length(prev.f)) return(setdiff(f, prev.f))
        Sys.sleep(1)
    }
    stop("timeout: waiting for download")
}


## generate and download all
for (i in seq_along(dd.elems)) {
    nm <- dd.elem.name(dd.elems[[i]])
    cat(nm, "\n")
    select.const(dd.elems[[i]])
    f <- dl()
    print(f)
}
