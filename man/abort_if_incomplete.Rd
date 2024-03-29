% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/abort_if_incomplete.R
\name{abort_if_incomplete}
\alias{abort_if_incomplete}
\title{Aborts when data has missing values on non-nullable columns}
\usage{
abort_if_incomplete(data, non_nullable_cols = names(data))
}
\arguments{
\item{data}{Tibble holding a result data set.}

\item{non_nullable_cols}{A character vector holding names of columns on which
\code{NA}s are not allowed.}
}
\value{
Input \code{data} invisibly.
}
\description{
Aborts when data has missing values on non-nullable columns
}
\examples{
data <- tibble::tibble(x = NA, y = 1, z = NA)

# With NA in nullable columns returns data invisibly
data \%>\% abort_if_incomplete(non_nullable_cols = "y")
out <- data \%>\% abort_if_incomplete(non_nullable_cols = "y")
identical(out, data)

# With NA in one nullable column, alerts the column to review as an error
data \%>\%
  abort_if_incomplete(non_nullable_cols = c("x", "y")) \%>\%
  try()

# By default, it takes all columns as non-nullable
data \%>\%
  abort_if_incomplete() \%>\%
  try()
}
\keyword{internal}
