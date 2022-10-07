Writing Functions
================

This notebook contains the code underpinning the Writing Functions
thread.

Follow me on Twitter [@neilgcurrie](twitter.com/neilgcurrie) and visit
[torchdata.io](https://www.torchdata.io).

You can find links to all my threads
[here](https://github.com/neilcuz/threads).

## Setup

Install the packages if you need to.

``` r
install.packages("dplyr")
install.packages("ggplot2")
install.packages("purrr")
install.packages("readr")
install.packages("here")
```

And load them.

``` r
library(dplyr)
library(ggplot2)
library(purrr)
library(readr)
library(here)
```

## When to write functions

The rule of three.

``` r
# Bad

sample1 <- sample(c(TRUE, FALSE), size = 10, replace = TRUE)
names(sample1) <- paste0("pos", 1:10)
sample1_true <- sample1[sample1 == TRUE]

sample2 <- sample(c(TRUE, FALSE), size = 15, replace = TRUE)
names(sample2) <- paste0("pos", 1:15)
sample2_true <- sample2[sample2 == TRUE]

sample3 <- sample(c(TRUE, FALSE), size = 20, replace = TRUE)
names(sample3) <- paste0("pos", 1:20)
sample3_true <- sample3[sample3 == TRUE]

# Better

sampler <- function (size) {
  
  my_sample <- sample(c(TRUE, FALSE), size, replace = TRUE)
  names(my_sample) <- paste0("pos", 1:size)

  return(my_sample[my_sample == TRUE])
  
}

sample1 <- sampler(10)
sample2 <- sampler(15)
sampler3 <- sampler(20)
```

## Defining functions

``` r
# If you cast your mind back to school this is Pythagoras' Theorem. 
# This function calculates side c (the hypotenuse) given sides a and b of a triangle

# The function name is calculate_c, side_a and side_b are arguments

calculate_c <- function (side_a, side_b) {
  
  return(sqrt(side_a ^ 2 + side_b ^ 2))
  
}

# We could extend the function and give the user control of if they want c
# squared or not. Here we have given squared a default value of FALSE.

calculate_c <- function (side_a, side_b, squared = FALSE) {
  
  side_c <- side_a ^ 2 + side_b ^ 2

  if (squared == TRUE) {
    
    return(side_c)
    
  } else {
    
    return(sqrt(side_c))
    
  }
}
```

## Tidy evaluation

This won’t work

``` r
dummy <- tibble(id = 1:20, i = runif(20), j = runif(20), k = runif(20))

transform_data1 <- function(x, min_value, filter_by, sort_by) {
  
  x |> 
    filter(filter_by >= min_value) |> 
    arrange(sort_by) 
  
}
```

``` r
transform_data1(dummy, 0.5, j, k) # error!
```

This will work. And an example of using :=

``` r
# Will work with the curly brackets

transform_data2 <- function(x, min_value, filter_by, sort_by) {
  
  x |> 
    filter({{filter_by}} >= min_value) |> 
    arrange({{sort_by}}) 
  
}

transform_data2(dummy, 0.5, j, k)
```

    # A tibble: 10 × 4
          id      i     j     k
       <int>  <dbl> <dbl> <dbl>
     1     2 0.324  0.810 0.292
     2    16 0.716  0.864 0.368
     3    18 0.883  0.940 0.545
     4    11 0.540  0.697 0.830
     5     4 0.638  0.694 0.846
     6     5 0.453  0.939 0.865
     7     9 0.983  0.921 0.878
     8     1 0.272  0.812 0.897
     9    19 0.0395 0.542 0.899
    10    10 0.239  0.817 0.985

``` r
# Using := to modify the left hand side or name

transform_data3 <- function(x, min_value, filter_by, sort_by, new_name) {
  
  x |> 
    filter({{filter_by}} >= min_value) |> 
    arrange({{sort_by}}) |> 
    mutate({{new_name}} := {{filter_by}} * {{sort_by}})
    
  
}

transform_data3(dummy, 0.5, i, k, "l")
```

    # A tibble: 11 × 5
          id     i      j       k       l
       <int> <dbl>  <dbl>   <dbl>   <dbl>
     1    12 0.894 0.120  0.00567 0.00507
     2    13 0.578 0.282  0.231   0.133  
     3     6 0.666 0.244  0.256   0.171  
     4    17 0.973 0.325  0.295   0.287  
     5    16 0.716 0.864  0.368   0.263  
     6    18 0.883 0.940  0.545   0.481  
     7    20 0.639 0.0240 0.605   0.386  
     8    11 0.540 0.697  0.830   0.448  
     9     4 0.638 0.694  0.846   0.540  
    10     9 0.983 0.921  0.878   0.863  
    11     7 0.825 0.147  0.933   0.770  

## Error handling for arguments

``` r
calculate_c <- function (side_a, side_b, squared = FALSE) {
  
  if (side_a <= 0) {
    
    stop ("side_a must be positive")
    
  }
  
  if (side_b <= 0) {
    
    stop ("side_b must be negative")
    
  }
  
  if (length(side_a) != length(side_b)) {
    
    stop ("side_a and side_by must have the same length")
    
  }
  
  if (!is.logical(squared)) {
    
    stop ("squared must be TRUE or FALSE")
    
  }
  
  side_c <- side_a ^ 2 + side_b ^ 2

  if (squared == TRUE) {
    
    return(side_c)
    
  } else {
    
    return(sqrt(side_c))
    
  }
}
```

## Using ellipsis

``` r
# Maybe you want to use some of the aesthetics for tweaking geom_point.
# Maybe you arent sure which ones, all you know is you will be doing a bunch
# of scatter plots of i and j.

ggplot(dummy, aes(x = i, y= j)) +
  geom_point(size = 5, shape = 14) +
  labs(title = "My nice plot")
```

![](writing-functions_files/figure-gfm/unnamed-chunk-9-1.png)

``` r
plotter <- function (plot_data, ..., title = "Placeholder title") {
  
  ggplot(plot_data, aes(x = i, y = j)) +
    geom_point(...) +
    labs(title = title)
  
}

plotter(dummy, alpha = 0.5, shape = 10, stroke = 10)
```

![](writing-functions_files/figure-gfm/unnamed-chunk-9-2.png)

## Functions written for their side effects

Let’s say we want to save a bunch of files to a folder called output

``` r
sample_and_write <- function (sizes) {
  
  output_path <- file.path(here(), "output")
  if (!dir.exists(output_path)) dir.create("output")
  
  samples <- map(sizes, sampler)
  
  files <- file.path(output_path, paste0("sample", sizes, ".rds"))
  
  walk2(samples, files, write_rds)
  
  return(invisible(sizes))
  
}

sample_and_write(1:5)
sample_and_write(30:32)
```
