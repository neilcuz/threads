Spark Intro
================

``` r
library(glue)
library(here)
```

    ## here() starts at /Users/neilcurrie/freelance/socials/threads

``` r
library(readr)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
path <- glue("{here::here()}/notebooks/spark-intro_20220615/")
file <- glue("{path}data/taxi_trip_data.csv")

df <- read_csv(file)
```

    ## Rows: 10000000 Columns: 17

    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (9): trip_distance, store_and_fwd_flag, fare_amount, extra, mta_tax, ti...
    ## dbl  (6): vendor_id, passenger_count, rate_code, payment_type, pickup_locati...
    ## dttm (2): pickup_datetime, dropoff_datetime
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
summary_df <- df |> 
  dplyr::select(trip_distance, passenger_count, total_amount, 
                pickup_location_id) |> 
  dplyr::filter(trip_distance >= 5, passenger_count > 1) |> 
  dplyr::mutate(total_amount = as.numeric(total_amount),
                total_amount_per_head = total_amount / passenger_count) |> 
  dplyr::group_by(pickup_location_id) |> 
  dplyr::summarise(mean_amount = mean(total_amount_per_head, na.rm = TRUE))

remove(df)
```

``` r
# Install Spark and Sparklyr - run once, note you will need to change
# eval = FALSE here to run

install.packages("sparklyr")
library(sparklyr)
spark_install()
```

``` r
library(sparklyr)

sc <- spark_connect(master = "local")

summary_df <- sc |> 
  spark_read_csv(name = "sdf",  path = file, header = TRUE, 
                 infer_schema = FALSE) |> 
  select(trip_distance, passenger_count, total_amount, pickup_location_id) |>
  mutate(trip_distance = as.numeric(trip_distance),
         passenger_count = as.numeric(passenger_count),
         total_amount = as.numeric(total_amount)) |>
  filter(trip_distance >= 5, passenger_count > 1) |>
  mutate(total_amount = as.numeric(total_amount),
         total_amount_per_head = total_amount / passenger_count) |>
  group_by(pickup_location_id) |>
  summarize(mean_amount = mean(total_amount_per_head, na.rm = TRUE)) |>
  collect()

spark_disconnect(sc)
```

``` r
file <- glue("{path}data/NF-UQ-NIDS-v2.csv")

sc <- spark_connect(master = "local")

df <- sc |> 
  spark_read_csv(name = "sdf",  path = file, header = TRUE, 
                 infer_schema = FALSE) |> 
  select(IN_PKTS, IN_BYTES) |>
  mutate(IN_PKTS = as.numeric(IN_PKTS),
         IN_BYTES = as.numeric(IN_BYTES)) |>
  filter(IN_PKTS > 3, IN_BYTES > 400) |>
  mutate(bytes_per_packet = IN_BYTES / IN_PKTS) |>
  filter(bytes_per_packet > 200) |>
  collect()

spark_disconnect(sc)
```
