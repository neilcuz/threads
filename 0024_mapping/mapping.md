Mapping
================

This notebook contains the code underpinning the *Mapping* Twitter
thread.

- For online courses, training and consultancy visit my website
  [shoogle.co](shoogle.co)

- Subscribe to my YouTube channel for videos on R and data science
  @shoogle [youtube.com/@shoogle](www.youtube.com/@shoogle)

- Follow me on Twitter for weekly threads on data and coding
  @neilgcurrie [twitter.com/neilgcurrie](www.twitter.com/neilgcurrie)

You can find links to all my threads
[here](https://github.com/neilcuz/threads).

## Setup

First we need to load `purrr`, `tibble` and `here`. This piece of code
will check if the `pacman` package is installed and, if not, it will
download it from CRAN. Then it loads the required libraries, downloading
if need be.

``` r
if (!require(pacman)) install.packages("pacman")
pacman::p_load(purrr, tibble, here)
```

## for loops

First let’s write some code - a for loop. A bit of a daft example but
here I want to take the mean of the top 5 elements of some input. And I
want to do that multiple times.

``` r
inputs <- list(runif(10), runif(10), runif(10), runif(10))
outputs1 <- vector("list", length = length(inputs)) # initialise

for (i in seq_along(inputs)) {
  
  input <- inputs[[i]]
  input_ordered <- sort(input, decreasing = TRUE)
  input_top_5 <- input_ordered[1:5]
  
  outputs1[[i]] <- mean(input_top_5)
  
}

print(outputs1)
```

    [[1]]
    [1] 0.9176403

    [[2]]
    [1] 0.7317301

    [[3]]
    [1] 0.6684233

    [[4]]
    [1] 0.838242

You could rewrite that with a function

``` r
mean_top_5 <- function (x) {
  
  x_ordered <- sort(x, decreasing = TRUE)
  x_top_5 <- x_ordered[1:5]
  
  return(mean(x_top_5))
  
}

outputs2 <- vector("list", length = length(inputs)) # initialise

for (i in seq_along(inputs)) {
  
  outputs2[[i]] <- mean_top_5(inputs[[i]])
  
}

print(outputs2)
```

    [[1]]
    [1] 0.9176403

    [[2]]
    [1] 0.7317301

    [[3]]
    [1] 0.6684233

    [[4]]
    [1] 0.838242

## mapping

We can simplify further with map.

``` r
outputs3 <- map(inputs, mean_top_5)

print(outputs3)
```

    [[1]]
    [1] 0.9176403

    [[2]]
    [1] 0.7317301

    [[3]]
    [1] 0.6684233

    [[4]]
    [1] 0.838242

## mapping with atomic vector output

A numeric output, here using outputs_dbl though outputs_int also
available.

``` r
outputs_dbl <- map_dbl(inputs, mean_top_5)

print(outputs_dbl)
```

    [1] 0.9176403 0.7317301 0.6684233 0.8382420

A logical output

``` r
big_top_5_mean <- function (x) {
  
  x_top_5_mean <- mean_top_5(x)
  
  big <- x_top_5_mean > 0.75
  
  return (big)
  
}

outputs_lgl <- map_lgl(inputs, big_top_5_mean)

print(outputs_lgl)
```

    [1]  TRUE FALSE FALSE  TRUE

A character output. You can use \~ to write an anonymous function
instead of defining the function separately.

``` r
subjects <- c("english", "maths", "physics", "economics")

outputs_chr <- map_chr(subjects, ~paste(., "is difficult"))

print(outputs_chr)
```

    [1] "english is difficult"   "maths is difficult"     "physics is difficult"  
    [4] "economics is difficult"

## mapping with tibble output

Here we combine by row

``` r
get_grade <- function (subject) {
  
  mark <- round(rnorm(1, mean = 65, sd = 14))
  
  if (mark > 100) mark <- 100
  if (mark < 0) mark <- 0
  
  if (mark >= 80) {
    
    grade <- "A"
    
  } else if (mark >= 60) {
    
    grade <- "B"
    
  } else if (mark >= 45) {
    
    grade <- "C"
    
  } else {
    
    grade <- "Fail"
    
  }
  
  report_card <- tibble(subject, grade, mark)
  
  return (report_card)
}

output_grade <- map_dfr(subjects, get_grade)
print(output_grade)
```

    # A tibble: 4 × 3
      subject   grade  mark
      <chr>     <chr> <dbl>
    1 english   B        70
    2 maths     A        97
    3 physics   B        76
    4 economics B        72

``` r
output_grade_col <- map_dfc(inputs, mean_top_5)
```

    New names:
    • `` -> `...1`
    • `` -> `...2`
    • `` -> `...3`
    • `` -> `...4`

``` r
output_grade_col
```

    # A tibble: 1 × 4
       ...1  ...2  ...3  ...4
      <dbl> <dbl> <dbl> <dbl>
    1 0.918 0.732 0.668 0.838

## map over 2 arguments

``` r
# Calculates the sum of squares error
sse <- function (actual, predicted) {
  
   sum((actual - predicted) ^ 2)
  
}

actuals <- list(runif(10), runif(10), runif(10))
predicteds <- list(runif(10), runif(10), runif(10))

output_sse <- map2(actuals, predicteds, sse)
output_sse_dbl <- map2_dbl(actuals, predicteds, sse)

print(output_sse)
```

    [[1]]
    [1] 0.770295

    [[2]]
    [1] 1.098818

    [[3]]
    [1] 2.299806

``` r
print(output_sse_dbl)
```

    [1] 0.770295 1.098818 2.299806

## map over more than 2 arguments

``` r
pets <- c("dog", "cat", "hamster")
ages <- c(4, 7, 1.5)
multipliers <- c(7, 6, 26)

pinput <- list(pet = pets, age = ages, mutiplier = multipliers)

make_pet_info <- function (pet, age, mutiplier) {
  
  tibble(pet,
         age,
         human_years = age * mutiplier)
  
}

output_pets <- pmap_dfr(pinput, make_pet_info)
print(output_pets)
```

    # A tibble: 3 × 3
      pet       age human_years
      <chr>   <dbl>       <dbl>
    1 dog       4            28
    2 cat       7            42
    3 hamster   1.5          39

## walk instead of map

Walk returns its value invisibly - great for writing multiple files.

``` r
# Add a data folder if need be
data_folder <- file.path(here(), "data")
if (!dir.exists(data_folder)) dir.create(data_folder)

# Build file paths and outputs list
file_paths <- file.path(data_folder, c("grades.csv", "pets.csv"))
outputs_to_save <- list(output_grade, output_pets)

# Iterate over and write
walk2(outputs_to_save, file_paths, write.csv)
```
