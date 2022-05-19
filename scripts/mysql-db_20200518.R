
## Using SQLite with R
# --------------------------------------------------------------------------------------------------

## Libraries

## Creating a database

# If you use dbConnect and the database doesnt already exist it will create one for you

library(DBI)     # for connecting R with databases
library(RSQLite) # for working with SQLite

con <- DBI::dbConnect(RSQLite::SQLite(), "football-data.db")

DBI::dbListTables(con) # no tables yet

## Grab some data and create a table

library(readr) # for reading data

# We will use football (soccer) data from football-data.co.uk for Premier League and La Liga

epl_2122 <- readr::read_csv("https://www.football-data.co.uk/mmz4281/2122/E0.csv")

DBI::dbWriteTable(con, name = "england_premier_league", value = epl_2122)

dbListTables(con) # the table is in there now
DBI::dbListFields(con, name = "england_premier_league") # here are all the fields

# Create another table

ll_2122 <- read_csv("https://www.football-data.co.uk/mmz4281/2122/SP1.csv")

dbWriteTable(con, name = "spain_la_liga", value = ll_2122)

dbListTables(con) # two different tables now

## Appending to a table

# Say we wanted to grab another season of Premier League data

epl_2021 <- readr::read_csv("https://www.football-data.co.uk/mmz4281/2021/E0.csv")

# append = TRUE is important here

dbWriteTable(con, name = "england_premier_league", value = epl_2021, append = TRUE)

## Querying the database

query <- "SELECT Date, HomeTeam, AwayTeam, FTHG, FTAG
          FROM   england_premier_league"

football_data1 <- DBI::dbGetQuery(con, statement = query)

head(football_data1)

# Say you only wanted games with more than 2.5 goals scored

query <- "SELECT Date, HomeTeam, AwayTeam, FTHG, FTAG
          FROM   england_premier_league
          WHERE  FTHG + FTAG > 2.5"

football_data2 <- DBI::dbGetQuery(con, statement = query)

head(football_data2)

## Querying the database with tidyverse

# You dont even need to know SQL code

library(dplyr)
library(dbplyr)

football_data3 <- con |>
  dplyr::tbl("england_premier_league") |>
  dplyr::select(Date, HomeTeam, AwayTeam, FTHG, FTAG) |>
  dplyr::filter(FTHG + FTAG > 2.5)

#  notice this looks different to the usual tibble or data.frame. Thats because R has send the
# query to the database - it doesnt pull any data in until you ask it to keep things fast

head(football_data3)

# To bring in to R use collect()

football_data3 <- collect(football_data3)
print(football_data3)

identical(football_data2, football_data3) # exactly the same thing

close.connection(con) # remember to close your connection to the database
