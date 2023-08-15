library(readr)
library(dplyr)
library(measurements)

process_daphnia <- function(df){

  # use only uptake measurements
  df <- dplyr::filter(df, FLAGUPTAKE == TRUE)

  # round exposure times to nearest hour
  df$EXPOSURE <- round(df$EXPOSURE, digits = 0)

  # remove redundant columns
  df <- subset(df, select = - FLAGUPTAKE)

  return(df)

}

standardize_daphnia <- function(df){

  # convert time to days
  df$EXPOSURE <- df$EXPOSURE / 24; df$EXPOSUREUNIT <- "days"

  # convert molar mass to mass: Xmol * MW = [mol] * [g] / [mol] = [g]
  df <- df %>%
    mutate(INTERNAL =
             if_else(grepl("mol", INTERNALUNIT),
                     INTERNAL * MOLWEIGHT,
                     INTERNAL))

  df$INTERNALUNIT <- gsub("mol", "g", df$INTERNALUNIT)

  # convert internal units to standard
  to_unit_internal <-  "ug / kg"
  df$INTERNAL <- apply(df, 1, convert_unit, to_unit_internal)

  df$INTERNALUNIT <- to_unit_internal

  # convert external units to standard
  to_unit_external <-  "ug / l"
  df$EXTERNAL <- apply(df, 1, convert_unit, to_unit_external, FALSE)

  df$EXTERNALUNIT <- to_unit_external

  # remove redundant columns
  df <- subset(df, select = - EXPOSUREUNIT)
  df <- subset(df, select = - INTERNALUNIT)
  df <- subset(df, select = - EXTERNALUNIT)

  return(df)

}

process_fish <- function(df){

  # remove redundant columns
  df <- subset(df, select = - FLAGUPTAKE)

  return(df)

}

standardize_fish <- function(df){

  # convert internal units to standard
  to_unit <-  "ug / kg"
  df$INTERNAL <- apply(df, 1, convert_unit, to_unit)

  df$INTERNALUNIT <- to_unit

  # remove redundant columns
  df <- subset(df, select = - EXPOSUREUNIT)
  df <- subset(df, select = - INTERNALUNIT)
  df <- subset(df, select = - EXTERNALUNIT)

  return(df)

}

convert_unit <- function(x, to_unit = "ug / kg", flag_internal = TRUE){

  if (flag_internal) {

    from_value <- x[["INTERNAL"]]
    from_unit  <- x[["INTERNALUNIT"]]

  } else {

    from_value <- x[["EXTERNAL"]]
    from_unit  <- x[["EXTERNALUNIT"]]

  }

  measurements::conv_multiunit(as.numeric(from_value),
                               from = from_unit,
                               to = to_unit)

}

# load raw data
df_d <- read_csv(file.path("data-raw", "daphnia.csv"), col_types = cols())
df_f <- read_csv(file.path("data-raw", "fish.csv"), col_types = cols())

# --- daphnia ---
# process daphnia raw data
df_d_processed <- process_daphnia(df_d)

# standardize daphnia processed data
daphnia <- standardize_daphnia(df_d_processed)

usethis::use_data(daphnia, overwrite = TRUE)

# --- fish ---
# process fish raw data
df_f_processed <- process_fish(df_f)

# standardize fish data
fish <- standardize_fish(df_f_processed)

usethis::use_data(fish, overwrite = TRUE)

# --- combined ---
stopifnot(identical(colnames(df_d), colnames(df_f)))
combined <- rbind(daphnia, fish)

usethis::use_data(combined, overwrite = TRUE)


