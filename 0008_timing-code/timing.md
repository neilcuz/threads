Timing Code
================

### Setup

``` r
library(tidyverse)
library(tictoc)
library(microbenchmark)
```

### 1. Sys.time approach

``` r
# Record the start time

start <- Sys.time()

diamonds_mass <- diamonds |> 
  mutate(xyz = x * y * z) |> 
  group_by(cut) |> 
  summarise(xyz = mean(xyz)) |> 
  arrange(desc(xyz))

# Record the end time

end <- Sys.time()

# Difference gives the time taken

end - start
```

    Time difference of 0.04417801 secs

### 2. tictoc approach

``` r
# similar to the Sys.time approach

tic()

diamonds |> 
  mutate(xyz = x * y * z) |> 
  group_by(cut) |> 
  summarise(xyz = mean(xyz)) |> 
  arrange(desc(xyz))
```

    # A tibble: 5 × 2
      cut         xyz
      <ord>     <dbl>
    1 Fair       165.
    2 Premium    145.
    3 Good       136.
    4 Very Good  131.
    5 Ideal      115.

``` r
toc()
```

    0.039 sec elapsed

``` r
# you can setup multiple timers and name them

tic("timer1")
tic("timer2")

Sys.sleep(1)

toc()
```

    timer2: 1.012 sec elapsed

``` r
toc()
```

    timer1: 1.015 sec elapsed

### 3. Using microbenchmark

``` r
f1 <- function (x) {
  
  x |> 
    group_by(year, city) |> 
    summarise(listings = mean(listings), .groups = "drop") |> 
    arrange(desc(listings)) |>  
    filter(year == 2000)
  
} 

f2 <- function (x) {

  x |> 
    filter(year == 2000) |> 
    group_by(city) |> 
    summarise(listings = mean(listings), .groups = "drop") |> 
    arrange(desc(listings))
  
}

microbenchmark(f1(txhousing), f2(txhousing))
```

    Unit: milliseconds
              expr       min        lq      mean    median        uq      max neval
     f1(txhousing) 11.109376 11.311001 11.934800 11.529605 12.253104 16.66967   100
     f2(txhousing)  5.812417  5.976355  6.586821  6.098625  6.498979 20.49075   100
