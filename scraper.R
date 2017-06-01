## connect to server and navigate to page
require(RSelenium)
rd <- rsDriver(browser="chrome")
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
