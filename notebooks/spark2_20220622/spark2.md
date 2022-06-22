Using Spark for Modelling in R
================

## Setup

``` r
library(ggplot2)
library(rsample)
library(dplyr)
library(sparklyr)
library(tidymodels)
```

## Initial split

For prediction problems it is good practice to split your data into a
training and test set. 

In a standard approach the rsample package in the tidymodels ecosystem
makes this easy.

``` r
# Approach 1 - standard

sets <- initial_split(diamonds, prop = 0.7)

train_raw_tbl <- training(sets)

head(train_raw_tbl)
```

    # A tibble: 6 × 10
      carat cut       color clarity depth table price     x     y     z
      <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
    1  1.5  Very Good G     VS2      63.5    54 13239  7.26  7.22  4.6 
    2  0.53 Ideal     G     VS1      62.7    55  1721  5.16  5.18  3.24
    3  0.31 Ideal     G     VS2      62.2    53   562  4.37  4.38  2.72
    4  0.7  Good      E     VS2      64.1    55  2793  5.6   5.66  3.61
    5  1    Good      D     VS2      65.7    55  6163  6.17  6.22  4.07
    6  1.03 Ideal     J     SI1      61.6    57  4175  6.46  6.49  3.99

With sparklyr the process isn’t too different. We create a spark
connection, load the diamonds data with copy_to and split the data into
training and test sets with sdf_random_split. The sets can be easily
accessed with \$ notation.

``` r
# Approach 2 - sparklyr

sc <- spark_connect(master = "local")

diamonds_sdf <- copy_to(sc, diamonds)

sets_sdf <- sdf_random_split(diamonds_sdf, train = 0.7, test = 0.3)

train_raw_sdf <- sets_sdf$train

head(train_raw_sdf)
```

    # Source: spark<?> [?? x 10]
      carat cut     color clarity depth table price     x     y     z
      <dbl> <chr>   <chr> <chr>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
    1   0.2 Ideal   D     VS2      61.5    57   367  3.81  3.77  2.33
    2   0.2 Ideal   E     VS2      59.7    55   367  3.86  3.84  2.3 
    3   0.2 Ideal   E     VS2      62.2    57   367  3.76  3.73  2.33
    4   0.2 Premium E     SI2      60.2    62   345  3.79  3.75  2.27
    5   0.2 Premium E     VS2      59      60   367  3.81  3.78  2.24
    6   0.2 Premium E     VS2      59.7    62   367  3.84  3.8   2.28

## Feature engineering

A typical dplyr approach is displayed. Notice the use of the scale
function. It outputs a matrix so I wrap it in as.vector to keep things
nice and clean.

``` r
# Approach 1 - standard

train_tbl <- train_raw_tbl |> 
  mutate(xyz = x * y * z) |> 
  select(price, carat, cut, xyz) |> 
  mutate(carat = as.vector(scale(carat)),
         xyz = as.vector(scale(xyz)))
```

And now for sparklyr. If you used the scale or as.vector functions this
will throw an error when we collect.

Why is that? 

This is because sparklyr cannot translate these functions into Spark
SQL. Spark doesn’t know them.

``` r
# Approach 2 - sparklyr (with an error!)

train_sdf <- train_raw_sdf |>
  mutate(xyz = x * y * z) |>
  select(price, carat, cut, xyz) |>
  mutate(carat = as.vector(mean(carat)),
         xyz = as.vector(mean(xyz)))

head(train_sdf)
```

We need to use functions that can be translated. You have already seen
some - mutate and select. Luckily mean and sd can be translated and
these are used to standardise.

We could have used the mean and sd functions in approach 1 but this is a
good lesson.

``` r
# Approach 2 - sparklyr

train_sdf <- train_raw_sdf |> 
  mutate(xyz = x * y * z) |> 
  select(price, carat, cut, xyz) |> 
  mutate(carat = (carat - mean(carat)) / sd(carat),
         xyz = (xyz - mean(xyz)) / sd(xyz))

head(train_sdf)
```

    # Source: spark<?> [?? x 4]
      price carat cut       xyz
      <int> <dbl> <chr>   <dbl>
    1   367 -1.26 Ideal   -1.26
    2   367 -1.26 Ideal   -1.25
    3   367 -1.26 Ideal   -1.27
    4   345 -1.26 Premium -1.28
    5   367 -1.26 Premium -1.28
    6   367 -1.26 Premium -1.26

## Fitting a model on the training set

Now we fit a model. Firstly a standard approach. 

You could also use the lm function from base R but I like the workflow
from tidymodels, particularly for more complex modelling.

``` r
# Approach 1 - standard

fit1 <- linear_reg() |> fit(price ~ ., data = train_tbl)

fit1
```

    parsnip model object


    Call:
    stats::lm(formula = price ~ ., data = data)

    Coefficients:
    (Intercept)        carat        cut.L        cut.Q        cut.C        cut^4  
         3591.6       3140.2       1201.0       -497.6        331.9         69.4  
            xyz  
          588.2  

With Spark the steps are similar but we use the ml_linear_regression
function.

``` r
# Approach 2 - sparklyr

fit2 <- ml_linear_regression(train_sdf, price ~ .)

summary(fit2)
```

    Deviance Residuals:
         Min       1Q   Median       3Q      Max 
    -17542.0   -791.3    -34.9    523.2  12257.4 

    Coefficients:
      (Intercept)         carat     cut_Ideal   cut_Premium cut_Very Good 
        2462.2144     3242.6165     1746.2624     1396.2164     1450.5451 
         cut_Good           xyz 
        1067.7157      490.6864 

    R-Squared: 0.8567
    Root Mean Squared Error: 1511

diamonds is a small dataset. Fitting a model can be computationally
heavy.

With big data we can improve performance by executing the data wrangling
steps prior to fitting the model.

We do this with the compute function. It saves the cached data in Spark
memory.

``` r
# Approach 2 - sparklyr

train_sdf_cached <- compute(train_sdf, "train_sdf_cached") 

fit2 <- ml_linear_regression(train_sdf_cached, price ~ .)

summary(fit2)
```

    Deviance Residuals:
         Min       1Q   Median       3Q      Max 
    -17542.0   -791.3    -34.9    523.2  12257.4 

    Coefficients:
      (Intercept)         carat     cut_Ideal   cut_Premium cut_Very Good 
        2462.2144     3242.6165     1746.2624     1396.2164     1450.5451 
         cut_Good           xyz 
        1067.7157      490.6864 

    R-Squared: 0.8567
    Root Mean Squared Error: 1511

Evaluating a model on the training set is easy with the yardstick
package. The metrics function is particularly good. 

``` r
# Approach 1 - standard

train_metrics1 <- train_tbl |> 
  mutate(price_pred = predict(fit1, train_tbl)$.pred) |> 
  metrics(truth = price, estimate = price_pred)

train_metrics1
```

    # A tibble: 3 × 3
      .metric .estimator .estimate
      <chr>   <chr>          <dbl>
    1 rmse    standard    1510.   
    2 rsq     standard       0.857
    3 mae     standard     989.   

With Spark we also have a great option using ml_evaluate. We can then
use \$ notation to extract various statistics.

``` r
# eval-sparklyr, warning = FALSE
# Approach 2 - sparklyr

train_metrics2 <- ml_evaluate(fit2, train_sdf_cached)

train_metrics2$r2
```

    [1] 0.8566984

``` r
train_metrics2$mean_squared_error
```

    [1] 2281824

## Predicting the test set

Finally we want to make predictions on the test set and evaluate
performance. We already saw some evaluation of the training set and the
approach here is roughly the same.

First up the standard approach. Note my attempts to avoid data leakage
into the test set here.

``` r
# Approach 1 - standard

# To avoid data leakage we scale using the mean and sd values from the 
# training set

means_sds <- train_raw_tbl |> 
   mutate(xyz = x * y * z) |> 
  summarise(mean_xyz = mean(xyz),
            sd_xyz = sd(xyz),
            mean_carat = mean(carat),
            sd_carat = sd(carat))

test_tbl <- sets |> 
  testing() |> 
  mutate(xyz = x * y * z) |> 
  select(price, carat, cut, xyz) |> 
  mutate(carat = (carat - means_sds$mean_carat) / means_sds$sd_carat,
         xyz = (xyz - means_sds$mean_xyz) / means_sds$sd_xyz) 
 

test_predictions <- mutate(test_tbl, 
                           price_pred = predict(fit1, test_tbl)$.pred)

metrics(test_predictions, truth = price, estimate = price_pred)
```

    # A tibble: 3 × 3
      .metric .estimator .estimate
      <chr>   <chr>          <dbl>
    1 rmse    standard    1526.   
    2 rsq     standard       0.854
    3 mae     standard     988.   

And now the sparklyr approach. 

Notice I collect the means data and then save those means and standard
deviations as actual variables? 

This is because of the translation problem again. Spark SQL doesn’t like
the \$ notation.

``` r
# Approach 2 - sparklyr

means_sds <- train_raw_sdf |> 
   mutate(xyz = x * y * z) |> 
  summarise(mean_xyz = mean(xyz),
            sd_xyz = sd(xyz),
            mean_carat = mean(carat),
            sd_carat = sd(carat)) |> 
  collect()

mean_carat <- means_sds$mean_carat
sd_carat <- means_sds$sd_carat
mean_xyz <- means_sds$mean_xyz
sd_xyz <- means_sds$sd_xyz

test_sdf <- sets_sdf$test |> 
  mutate(xyz = x * y * z) |> 
  select(price, carat, cut, xyz) |> 
  mutate(carat = (carat - mean_carat) / sd_carat,
         xyz = (xyz - mean_xyz) / sd_xyz)
 
test_predictions <- fit2 |>
  ml_predict(test_sdf) |>
  collect()

test_metrics2 <- ml_evaluate(fit2, test_sdf)

test_metrics2$r2
```

    [1] 0.8546284

``` r
test_metrics2$mean_squared_error
```

    [1] 2310945
