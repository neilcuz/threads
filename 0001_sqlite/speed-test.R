
library(dplyr)
library(readr)

epl_2122 <- readr::read_csv("https://www.football-data.co.uk/mmz4281/2122/E0.csv",
                            show_col_types = FALSE)

data <- dplyr::slice(epl_2122, rep(1:n(), 1))

write_rds(data, "data.rds")
write_csv(data, "data.csv")

filename <- glue::glue("{here::here()}/data.db")

con <- DBI::dbConnect(RSQLite::SQLite(), filename)

DBI::dbWriteTable(con, name = "data", value = data)

# Test speed ----------

library(DBI)
library(RSQLite)
library(data.table)
library(readr)

f_dt <- function() dplyr::as_tibble(data.table::fread("data.csv", verbose = FALSE))
f_csv_readr <- function () readr::read_csv("data.csv", show_col_types = FALSE,
                                           progress = FALSE)
f_csv_base <- function() dplyr::as_tibble(read.csv("data.csv"))
f_rds <- function () readr::read_rds("data.rds")

f_db <- function () {

  con <- DBI::dbConnect(RSQLite::SQLite(), "data.db")
  DBI::dbGetQuery(con, statement = "SELECT * FROM data")

}

tests <- microbenchmark::microbenchmark(f_dt(),
                                        f_csv_readr(),
                                        f_csv_base(),
                                        f_db())

ggplot2::autoplot(tests)




