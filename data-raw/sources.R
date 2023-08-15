library(bib2df)

sources <- bib2df::bib2df(file.path("data-raw", "references.bib"))

usethis::use_data(sources, overwrite = TRUE)
