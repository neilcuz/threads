Unit Testing in R
================

This notebook contains the code underpinning the Unit Testing in R
thread. You can find links to all my threads
[here](twitter.com/neilgcurrie).

## Setup

First install the following packages.

``` r
install.packages("testthat")
install.packages("usethis")
install.packages("here")
```

And load them.

``` r
library(testthat)
library(usethis)
library(here)
```

Now for initial setup of your tests use the `use_testthat` function from
the `testthat` package. This will create a `tests` folder which contains
a folder `tests/testhat/` where your tests will live and a file
`testthat.R` which will organise things for you. You only need to run
`use_testthat` once.

``` r
use_testthat()
```

    ✔ Setting active project to '/Users/neilcurrie/threads'
    • Call `use_test()` to initialize a basic test file and open it for editing.

## Unit Testing Example

The corresponding test file `test-sse.R` (and all the test files we will
use) can be found
[here](https://github.com/neilcuz/threads/tree/master/tests/testthat).

``` r
sse <- function (actual, predicted) {
  
  sum((actual - predicted) ^ 2)
  
}
```

To run the tests inside `test-sse.R` I can use the `test_file` function
or if you open the file in R Studio you can press the Run Tests button.

``` r
# I like to store folder and file names in lists
wd <- list()

wd$wd <- paste0(here(), "/")
wd$testthat <- paste0(wd$wd, "tests/testthat/")

files <- list()

files$test_sse <- paste0(wd$testthat, "test-sse.r")

# Run the test
test_file(files$test_sse)
```


    ══ Testing test-sse.r ══════════════════════════════════════════════════════════

    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 2 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 3 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 4 ] Done!

Now we want to write a new function `mape` and an `error` function which
calls the `sse` or `mape` functions depending on what method the user
asks for.

``` r
mape <- function (actual, predicted) {
  
  sum(abs((actual - predicted) / actual)) / length (actual)
  
}

error <- function (actual, predicted, method) {
  
  if (method == "sse") {
    
    return(sse(actual, -predicted))
    
  }
  
  if (method == "mape") {
    
    return(mape(actual, predicted))
    
  }
  
  stop ("bad method supplied")

}
```

Now we can test those functions.

``` r
files$test_mape <- paste0(wd$testthat, "test-mape.r")
files$test_error <- paste0(wd$testthat, "test-error.r")

test_file(files$test_mape)
```


    ══ Testing test-mape.r ═════════════════════════════════════════════════════════

    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 2 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 3 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 4 ] Done!

``` r
test_file(files$test_error)
```


    ══ Testing test-error.r ════════════════════════════════════════════════════════

    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 1 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 1 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 2 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 3 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 4 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 5 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 6 ]

    ── Failure (]8;line=4:col=3;file:///Users/neilcurrie/threads/tests/testthat/test-error.rtest-error.r:4:3]8;;): sse calculations work ───────────────────────────
    error(4, 2, method = "sse") not equal to sse(4, 2).
    1/1 mismatches
    [1] 36 - 4 == 32

    ── Failure (]8;line=6:col=3;file:///Users/neilcurrie/threads/tests/testthat/test-error.rtest-error.r:6:3]8;;): sse calculations work ───────────────────────────
    error(c(1, 2, 3), c(2, 3, 4), method = "sse") not equal to sse(c(1, 2, 3), c(2, 3, 4)).
    1/1 mismatches
    [1] 83 - 3 == 80


    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 6 ]

So there was an mistake in the `error` function - I was accidently using
`-predicted` when calling the `sse` function. We will fix and re-run.

``` r
error <- function (actual, predicted, method) {
  
  if (method == "sse") {
    
    return(sse(actual, predicted))
    
  }
  
  if (method == "mape") {
    
    return(mape(actual, predicted))
    
  }
  
  stop ("bad method supplied")

}

test_file(files$test_error)
```


    ══ Testing test-error.r ════════════════════════════════════════════════════════

    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 2 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 3 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 4 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 6 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 7 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 8 ] Done!

Now we want to do some development of the `mape` function so it returns
a percentage or decimal depending on what output type the user asks for.

``` r
mape <- function (actual, predicted, output = "decimal") {
  
  value <- 100 * sum(abs((actual - predicted) / actual)) / length (actual)
  
  if (output == "percent") {
    
    return(value * 100)
    
  }
    
  if (output == "decimal") {
    
    return(value)
    
  }
    
  stop ("bad output supplied")
  
}

# In practice you would have a single mape test file

files$test_mape2 <- paste0(wd$testthat, "test-mape2.r")
test_file(files$test_mape2)
```


    ══ Testing test-mape2.r ════════════════════════════════════════════════════════

    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 1 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 2 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 3 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 4 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 4 | WARN 0 | SKIP 0 | PASS 1 ]
    [ FAIL 4 | WARN 0 | SKIP 0 | PASS 2 ]

    ── Failure (]8;line=3:col=3;file:///Users/neilcurrie/threads/tests/testthat/test-mape2.rtest-mape2.r:3:3]8;;): basic calculations work ─────────────────────────
    mape(20, 15, output = "decimal") not equal to 0.25.
    1/1 mismatches
    [1] 25 - 0.25 == 24.8

    ── Failure (]8;line=4:col=3;file:///Users/neilcurrie/threads/tests/testthat/test-mape2.rtest-mape2.r:4:3]8;;): basic calculations work ─────────────────────────
    mape(c(15, 10, 15), c(20, 5, 25), output = "decimal") not equal to 0.5.
    1/1 mismatches
    [1] 50 - 0.5 == 49.5

    ── Failure (]8;line=5:col=3;file:///Users/neilcurrie/threads/tests/testthat/test-mape2.rtest-mape2.r:5:3]8;;): basic calculations work ─────────────────────────
    mape(20, 15, output = "percent") not equal to 25.
    1/1 mismatches
    [1] 2500 - 25 == 2475

    ── Failure (]8;line=6:col=3;file:///Users/neilcurrie/threads/tests/testthat/test-mape2.rtest-mape2.r:6:3]8;;): basic calculations work ─────────────────────────
    mape(c(15, 10, 15), c(20, 5, 25), output = "percent") not equal to 50.
    1/1 mismatches
    [1] 5000 - 50 == 4950


    [ FAIL 4 | WARN 0 | SKIP 0 | PASS 2 ]

Now let’s fix that error - I multipled by 100 in multiple places.

``` r
mape <- function (actual, predicted, output = "decimal") {
  
  value <- sum(abs((actual - predicted) / actual)) / length (actual)
  
  if (output == "percent") {
    
    return(value * 100)
    
  }
    
  if (output == "decimal") {
    
    return(value)
    
  }
    
  stop ("bad output supplied")
  
}

# In practice you would have a single mape test file

files$test_mape2 <- paste0(wd$testthat, "test-mape2.r")
test_file(files$test_mape2)
```


    ══ Testing test-mape2.r ════════════════════════════════════════════════════════

    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 2 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 3 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 4 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 6 ] Done!

## Running all your tests

Running your tests one a time is good when developing those functions
but you will often want to run all your tests to check everything is
passing.

``` r
test_dir(wd$testthat)
```

    ✔ | F W S  OK | Context

    ⠏ |         0 | error                                                           
    ✔ |         8 | error

    ⠏ |         0 | mape                                                            
    ✔ |         4 | mape

    ⠏ |         0 | mape2                                                           
    ✔ |         6 | mape2

    ⠏ |         0 | sse                                                             
    ✔ |         4 | sse

    ══ Results ═════════════════════════════════════════════════════════════════════
    [ FAIL 0 | WARN 0 | SKIP 0 | PASS 22 ]
