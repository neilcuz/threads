Pivoting with tidyr
================

This notebook contains the code underpinning the *Pivoting with* tidyr
Twitter thread.

- For online courses, training and consultancy visit my website
  [shoogle.co](shoogle.co)

- Subscribe to my YouTube channel for videos on R and data science
  @shoogle [youtube.com/@shoogle](www.youtube.com/@shoogle)

- Follow me on Twitter for weekly threads on data and coding
  @neilgcurrie [twitter.com/neilgcurrie](www.twitter.com/neilgcurrie)

You can find links to all my threads
[here](https://github.com/neilcuz/threads).

## Setup

Check’s if tidyr is installed, if not it will install and then load.

``` r
if (!require(tidyr)) install.packages("tidyr")
library(tidyr)
```

## pivot_longer

Pivot data into tidy or long format from messy or wide format.

``` r
pop_millions_messy <- tibble(country = c("Argentina", "Albania", "Australia"),
                             `2005` = c(39.18, 3.03, 20.2),
                             `2010` = c(41.34, 2.99, 21.5),
                             `2015` = c(43.43, 3.03, 22.8))

pop_millions_tidy <-  pivot_longer(pop_millions_messy, 
                                   cols = c(`2005`, `2010`, `2015`), 
                                   names_to = "year",
                                   values_to = "population")

print(pop_millions_messy)
```

    # A tibble: 3 × 4
      country   `2005` `2010` `2015`
      <chr>      <dbl>  <dbl>  <dbl>
    1 Argentina  39.2   41.3   43.4 
    2 Albania     3.03   2.99   3.03
    3 Australia  20.2   21.5   22.8 

``` r
print(pop_millions_tidy)
```

    # A tibble: 9 × 3
      country   year  population
      <chr>     <chr>      <dbl>
    1 Argentina 2005       39.2 
    2 Argentina 2010       41.3 
    3 Argentina 2015       43.4 
    4 Albania   2005        3.03
    5 Albania   2010        2.99
    6 Albania   2015        3.03
    7 Australia 2005       20.2 
    8 Australia 2010       21.5 
    9 Australia 2015       22.8 

## pivot_wider

Pivot data into messy or wide format from tidy or long format.

``` r
pop_millions_messy <- pivot_wider(pop_millions_tidy, names_from = year,
                                  values_from = population)

print(pop_millions_messy)
```

    # A tibble: 3 × 4
      country   `2005` `2010` `2015`
      <chr>      <dbl>  <dbl>  <dbl>
    1 Argentina  39.2   41.3   43.4 
    2 Albania     3.03   2.99   3.03
    3 Australia  20.2   21.5   22.8 
