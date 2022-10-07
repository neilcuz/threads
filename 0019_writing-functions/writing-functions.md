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
```

And load them.

``` r
library(dplyr)
library(ggplot2)
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
          id     i     j      k
       <int> <dbl> <dbl>  <dbl>
     1     5 0.978 0.694 0.0390
     2     6 0.437 0.511 0.151 
     3     8 0.685 0.581 0.397 
     4     3 0.542 0.784 0.518 
     5    17 0.697 0.797 0.536 
     6    12 0.731 0.630 0.552 
     7    11 0.945 0.941 0.661 
     8     1 0.424 0.752 0.752 
     9     2 0.683 0.587 0.814 
    10    16 0.984 0.839 0.870 

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
          id     i      j      k      l
       <int> <dbl>  <dbl>  <dbl>  <dbl>
     1     5 0.978 0.694  0.0390 0.0382
     2     9 0.897 0.310  0.157  0.141 
     3     8 0.685 0.581  0.397  0.272 
     4     3 0.542 0.784  0.518  0.281 
     5    17 0.697 0.797  0.536  0.374 
     6    12 0.731 0.630  0.552  0.403 
     7    11 0.945 0.941  0.661  0.625 
     8     7 0.637 0.138  0.681  0.434 
     9    18 0.729 0.0265 0.722  0.527 
    10     2 0.683 0.587  0.814  0.556 
    11    16 0.984 0.839  0.870  0.856 

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

Let’s jut use the plotter function from the last example. Return the
first argument unmodified and invisibly.

``` r
plotter2 <- function (plot_data, ..., title = "Placeholder title") {
  
  ggplot(plot_data, aes(x = i, y = j)) +
    geom_point(...) +
    labs(title = title)
  
  return(invisible(plot_data))
  
}

plotter(dummy, size = 3, shape = 4, stroke = 5)
```

![](writing-functions_files/figure-gfm/unnamed-chunk-10-1.png)
