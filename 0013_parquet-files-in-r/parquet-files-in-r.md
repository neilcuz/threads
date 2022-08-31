Parquet Files in R
================

This is the code underpinning the thread Data Wrangling with Arrow in R
which you can find [here]().

### Setup

``` r
# Install packages (if not already installed) and load with pacman

if(!("pacman" %in% installed.packages()[,1])) {
  
  install.packages("pacman")
  
}

packages_to_load <- c("arrow", "ggplot2", "dplyr")

pacman::p_load(packages_to_load, character.only = TRUE)
```

### Writing a parquet file

Let’s take the diamonds dataset from ggplot2 and save it as a parquet
file. Parquet files take the .parquet or .pqt file extensions. .parquet
is apparently more common.

``` r
filename_parquet <- paste0(here::here(), "/data/diamonds.parquet")

write_parquet(diamonds, filename_parquet)
```

### Read a parquet file

It is easy to read a parquet file into R as a tibble. Its almost the
same as what you will be familar with in csv files.

``` r
diamonds_tbl <- read_parquet(filename_parquet)

print(diamonds_tbl)
```

    # A tibble: 53,940 × 10
       carat cut       color clarity depth table price     x     y     z
       <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
     1  0.23 Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
     2  0.21 Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
     3  0.23 Good      E     VS1      56.9    65   327  4.05  4.07  2.31
     4  0.29 Premium   I     VS2      62.4    58   334  4.2   4.23  2.63
     5  0.31 Good      J     SI2      63.3    58   335  4.34  4.35  2.75
     6  0.24 Very Good J     VVS2     62.8    57   336  3.94  3.96  2.48
     7  0.24 Very Good I     VVS1     62.3    57   336  3.95  3.98  2.47
     8  0.26 Very Good H     SI1      61.9    55   337  4.07  4.11  2.53
     9  0.22 Fair      E     VS2      65.1    61   337  3.87  3.78  2.49
    10  0.23 Very Good H     VS1      59.4    61   338  4     4.05  2.39
    # … with 53,930 more rows
    # ℹ Use `print(n = ...)` to see more rows

An advantage of the parquet approach though is you dont need to load the
whole dataset into memory. You can use dplyr verbs to manipulate and
ideally reduce the data before collecting it into memory. This is useful
for big datasets so possibly a but overkill here.

``` r
diamonds_pqt <- read_parquet(filename_parquet, as_data_frame = FALSE)

diamonds_tbl <- diamonds_pqt |> 
  select(carat, cut, depth) |> 
  filter(cut %in% c("Ideal", "Premium"), depth > 59.5) |> 
  collect()
 
print(diamonds_tbl)
```

    # A tibble: 33,818 × 3
       carat cut     depth
       <dbl> <ord>   <dbl>
     1  0.23 Ideal    61.5
     2  0.21 Premium  59.8
     3  0.29 Premium  62.4
     4  0.23 Ideal    62.8
     5  0.22 Premium  60.4
     6  0.31 Ideal    62.2
     7  0.2  Premium  60.2
     8  0.32 Premium  60.9
     9  0.3  Ideal    62  
    10  0.24 Premium  62.5
    # … with 33,808 more rows
    # ℹ Use `print(n = ...)` to see more rows
