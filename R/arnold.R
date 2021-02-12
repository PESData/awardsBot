#' Get Arnold Foundations/Arnold Venture awards
#' @param keyword Keyword to query, single string
#' @param from_year Year to begin search, integer
#' @param to_year Year to end search, integer
#' @return a data.frame
#' @export
#' @examples
#' arnold <- arnold_get("qualitative data", 2016, 2017)
arnold_get <- function(keyword, from_year, to_year) {
  url <- "https://pyj9b8sltv-dsn.algolia.net/1/indexes/*/queries?x-algolia-agent=Algolia%20for%20JavaScript%20(4.5.1)%3B%20Browser%20(lite)%3B%20instantsearch.js%20(4.8.3)%3B%20JS%20Helper%20(3.2.2)&x-algolia-api-key=bec9ead5977b11ae383f4df272c2f106&x-algolia-application-id=PYJ9B8SLTV"

  years <- paste0('"years:', from_year, '"')
  for (n in (from_year+1):to_year) years <- paste0(years, ',"years:', n, '"')
  years <- xml2::url_escape(years)

  # Not includidng all the terms at the end gives a HTTP 400 error
  page <- 0
  query <- paste0("query=", keyword,
                  "&maxValuesPerFacet=100&highlightPreTag=__ais-highlight__&highlightPostTag=__%2Fais-highlight__&facets=%5B%22topics%22%2C%22years%22%2C%22fundingSource%22%5D&tagFilters=",
                  "&facetFilters=%5B%5B", years, "%5D%5D")

  payload <- list(requests = list(list(indexName ="prod_grants",
                                         params = paste0(query, "&page=0"))))

  response <- request(url, "post", payload)
  response <- unlist(response, recursive=F)$results
  if (response$nbHits==0) return(NULL) # No results?

  full <- list()
  while (response$page <= response$nbPages) {
    awards <- response$hits
    row <- lapply(awards, function(x) {
      entry <- unlist(x, recursive=F)
      with(entry, data.frame(
        title, grantDescription, grantTerm,
        fundingSource, grantAmount,
        url, objectID, keyword))
    })
    full[[response$page+1]] <- do.call(rbind.data.frame, row)

    # Load next page
    payload$requests[[1]]$params <- paste0(query, "&page=", response$page+1)
    response <- request(url, "post", payload)
    response <- unlist(response, recursive=F)$results
  }

  do.call(rbind.data.frame, full)
}

#' Standardize Arnold Foundations/Arnold Venture award results
#' @param keywords Vector of keywords to search
#' @param from_date Beginning date object to search
#' @param to_date Ending date object to search
#' @return a standardized data.frame
arnold_standardize <- function(keywords, from_date, to_date) {
  raw <- lapply(keywords, arnold_get,
                   format.Date(from_date, "%Y"), format.Date(to_date, "%Y"))
  raw <- do.call(rbind.data.frame, raw)
  if (nrow(raw)==0) return(NULL)

  with(raw, data.frame(
    institution=title, pi=NA,
    year=substr(grantTerm, 1, 4), start=substr(grantTerm, 1, 4),
    end=substr_right(as.character(grantTerm), 4),
    program=fundingSource, amount=grantAmount, id=objectID,
    title=grantDescription, keyword, source="Arnold",
    stringsAsFactors = FALSE
  ))
}