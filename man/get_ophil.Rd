% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ophil.R
\name{get_ophil}
\alias{get_ophil}
\title{Grab the Open Philanthropy grants data search for keyword-date combos}
\usage{
get_ophil(keyword, from_year, to_year, verbose = FALSE)
}
\arguments{
\item{keyword}{Keyword to query}

\item{from_year}{Beginning year to search}

\item{to_year}{Ending year to search}

\item{verbose}{enable verbose HTTP messages. TRUE/FALSE, default: false}
}
\value{
A data.frame
}
\description{
Grab the Open Philanthropy grants data search for keyword-date combos
}
\examples{
ophil <- get_ophil("qualitative", 2019, 2020)
}
