Documenting code in R
================

This notebook contains the code underpinning the Documenting Code in R
thread. You can find links to all my threads
[here](twitter.com/neilgcurrie).

When writing comments, focus on the why.

``` r
# Bad ---

# Multiply dollars by exchange rate to get pounds value

sales_pounds <- sales_dollars * exchange_rate_pounds_to_dollars

# Good ---

# We are a UK based business but some of our transactions take place in dollars. 
# All sales must be reported in pounds to finance.

sales_pounds <- sales_dollars * exchange_rate_pounds_to_dollars
```

Well named objects and functions can improve readability, making some
comments unnecessary.

``` r
# Bad---
# x are the actual values
# y are the predicted values
# z is the sum of squares error

z <- sum((x - y) ^ 2)

# Good ---

sum_of_squares_error <- function (actual, predicted) {
  
   sum((actual - predicted) ^ 2)
  
}

error <- sum_of_squares_error(actual, predicted)
```

You can document your package code using roxygen2 using the following
syntax placed just before your function. This works inside of a package.
You will need to install the roxygen2 package first.

``` r
#' @title My Dummy Function
#' @description A fake dummy function for explaining roxygen2
#' @param x a numeric vector, the main input to my dummy function
#' @param xmax,xmin the maximum and minimum value that x can take
#' @returns a numeric vector
#' @details more detail about the returned value would go in here
#' @examples 
#' x <- runif(100)
#' xmax <- 0.8
#' xmin <- 0.2
#' 
#' my_dummy_function(x, xmax, xmin)
#' @export

my_dummy_function <- function (x, xmax, xmin) {
  
  x[x < xmax & x > xmin]
  
}
```
