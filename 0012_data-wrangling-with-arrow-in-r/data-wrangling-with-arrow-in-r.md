Data Wrangling with Arrow in R
================

\* \* Update 5 Aug 2022 - I have tweaked the code slightly from the
original thread, see comments in code below \*

This is the code underpinning the thread Data Wrangling with Arrow in R
which you can find
[here](https://twitter.com/neilgcurrie/status/1554867200392998912).

### Setup

This installs and loads the required libraries. I have written in this
way so you can run it without modifying or writing manual installation
code.

``` r
# Install packages (if not already installed)

packages_to_load <- c("arrow", "dplyr", "glue", "here", "readr")
installed <- packages_to_load %in% installed.packages()[,1]
packages_to_install <- packages_to_load[!installed]

install.packages(packages_to_install)

# Load packages

for (package in packages_to_load) library(package, character.only = TRUE)
```

### NY Taxis using readr::read_csv

This code shows the standard approach to reading in some data and
manipulating. This is done with the commonly used functions
`readr::read_csv`. As an aside you will find `vroom::vroom` and
`data.table::fread` are faster.

``` r
file_taxi <- glue("{here::here()}/data/taxi_trip_data.csv")

taxi_standard <- file_taxi |> 
  read_csv(show_col_types = FALSE) |> 
  select(trip_distance, passenger_count, total_amount, pickup_location_id) |> 
  filter(trip_distance >= 5, passenger_count > 1) |> 
  mutate(total_amount = as.numeric(total_amount),
         total_amount_per_head = total_amount / passenger_count) |> 
  group_by(pickup_location_id) |> 
  summarise(mean_amount = mean(total_amount_per_head, na.rm = TRUE))

print(taxi_standard)
```

    # A tibble: 249 × 2
       pickup_location_id mean_amount
                    <dbl>       <dbl>
     1                  1        54.0
     2                  3        11.8
     3                  4        11.9
     4                  5        14.6
     5                  6        12.7
     6                  7        11.6
     7                  8        18.2
     8                  9        13.2
     9                 10        19.7
    10                 11        10.7
    # … with 239 more rows
    # ℹ Use `print(n = ...)` to see more rows

### NY Taxis using arrow::read_csv_arrow

This code shows the approach for reading in the same data and
manipulating in the same way, but this time we use the arrow package.

``` r
taxi_arrow <- file_taxi |> 
  # Added as_data_frame = FALSE retrospecitively. Reads in data as an arrow table.
  read_csv_arrow(as_data_frame = FALSE) |> 
  select(trip_distance, passenger_count, total_amount, pickup_location_id) |> 
  filter(trip_distance >= 5, passenger_count > 1) |> 
  mutate(total_amount = as.numeric(total_amount),
         total_amount_per_head = total_amount / passenger_count) |> 
  group_by(pickup_location_id) |> 
  summarise(mean_amount = mean(total_amount_per_head, na.rm = TRUE)) |> 
  collect()

print(taxi_arrow)
```

    # A tibble: 261 × 2
       pickup_location_id mean_amount
                    <int>       <dbl>
     1                164        17.4
     2                143        16.4
     3                138        17.4
     4                141        14.0
     5                125        16.1
     6                 90        15.5
     7                 74        13.8
     8                100        16.9
     9                239        15.4
    10                246        16.1
    # … with 251 more rows
    # ℹ Use `print(n = ...)` to see more rows

### NIDS using arrow::read_csv_arrow

This code using arrow for reading a larger dataset, one which wouldn’t
work on my machine with a standard approach.

``` r
file_nids <- glue("{here::here()}/data/NF-UQ-NIDS-v2.csv")

nids <- file_nids |>
  # Added as_data_frame = FALSE retrospecitively. Reads in data as an arrow table.
  read_csv_arrow(as_data_frame = FALSE) |>
  select(IN_PKTS, IN_BYTES) |>
  mutate(IN_PKTS = as.numeric(IN_PKTS),
         IN_BYTES = as.numeric(IN_BYTES)) |>
  filter(IN_PKTS > 3, IN_BYTES > 400) |>
  mutate(bytes_per_packet = IN_BYTES / IN_PKTS) |>
  filter(bytes_per_packet > 200) |>
  collect()

print(nids)
```
