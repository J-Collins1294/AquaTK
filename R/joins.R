#' Join Lipid Fraction Estimates
#'
#' @param combined The AquaTK combined data frame
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' join_lipid_fraction(AquaTK::combined)
#'
join_lipid_fraction <- function(combined){

  df <- data.frame(ORGANISM = c("Daphnia Magna", "Fathead Minnow", "Rainbow Trout"),
                      LIPIDFRACTION = c(0.005, 0.05, 0.085))

  dplyr::left_join(combined, df, by = "ORGANISM")

}

#' Join Source Metadata
#'
#' @param keys A data frame of bibtex citekeys
#'
#' @return A data frame.
#' @export
#'
#' @examples
#' df <- data.frame(BIBTEXKEY = unique(AquaTK::combined$BIBTEXKEY))
#' join_source_metadata(df)
#'
join_source_metadata <- function(keys){

  df <- AquaTK::sources

  dplyr::left_join(keys, df, by = "BIBTEXKEY")

}

