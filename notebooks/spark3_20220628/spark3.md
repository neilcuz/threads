spark3
================

## Quarto

Quarto enables you to weave together content and executable code into a
finished document. To learn more about Quarto see <https://quarto.org>.

## Running Code

### Setup

``` r
library(dplyr)
library(sparklyr)
```

``` r
id <- 1:4
animal <- c("crocodile", "shark", "goldfish", "monkey", "mole")
colour <- c("indigo", "red", "black", "lime")
num_rows <- 1000

data_frame1 <- tibble(
  id = sample(id, size = num_rows, replace = TRUE),
  animal = sample(animal, size = num_rows, replace = TRUE))

data_frame2 <- tibble(id, colour)

data_frame3 <- dplyr::left_join(data_frame1, data_frame2, by = "id")
print(data_frame3)
```

    # A tibble: 1,000 × 3
          id animal    colour
       <int> <chr>     <chr> 
     1     4 monkey    lime  
     2     3 crocodile black 
     3     2 goldfish  red   
     4     2 crocodile red   
     5     2 mole      red   
     6     3 mole      black 
     7     1 monkey    indigo
     8     4 shark     lime  
     9     1 monkey    indigo
    10     3 shark     black 
    # … with 990 more rows

``` r
# Create spark connection
sc <- spark_connect(master = "local")

# We will just use data_frame1 & 2 for the demo so use copy_to
# To read fresh data in use different functions e.g. spark_read_csv

sdf1 <- copy_to(sc, data_frame1)
sdf2 <- copy_to(sc, data_frame2)

# Do the join

sdf3 <- sparklyr::left_join(sdf1, sdf2, by = "id")

# Lets collect to have a look

df3 <- collect(sdf3)
print(df3)
```

    # A tibble: 1,000 × 3
          id animal    colour
       <int> <chr>     <chr> 
     1     1 monkey    indigo
     2     1 monkey    indigo
     3     1 crocodile indigo
     4     1 crocodile indigo
     5     1 shark     indigo
     6     1 mole      indigo
     7     1 goldfish  indigo
     8     1 mole      indigo
     9     1 monkey    indigo
    10     1 monkey    indigo
    # … with 990 more rows

``` r
sdf3_broadcast <- sparklyr::left_join(sdf1, 
                                      sdf_broadcast(sdf2),
                                      by = "id")

df3_broadcast <- collect(sdf3_broadcast)
print(df3_broadcast)
```

    # A tibble: 1,000 × 3
          id animal    colour
       <int> <chr>     <chr> 
     1     1 monkey    indigo
     2     1 monkey    indigo
     3     1 crocodile indigo
     4     1 crocodile indigo
     5     1 shark     indigo
     6     1 mole      indigo
     7     1 goldfish  indigo
     8     1 mole      indigo
     9     1 monkey    indigo
    10     1 monkey    indigo
    # … with 990 more rows

``` r
# Create dummy data

num_rows <- 100000

professions <- c("doctor", "nurse", "optician", "dentist")
working_pattern <- c("full time", "part time")

df1 <- tibble(
  id = sample(as.integer(c(1, 2)), num_rows, replace = TRUE, prob = c(0.9, 0.1)),
  profession = sample(professions, num_rows, replace = TRUE)
  )

df2 <- tibble(id = c(1, 2), working_pattern)

sdf1 <- copy_to(sc, df1, overwrite = TRUE)
sdf2 <- copy_to(sc, df2, overwrite = TRUE)

# Original method

sdf3_default <- sparklyr::left_join(sdf1, sdf2, by = "id")

df3_default <- collect(sdf3_default)

print(df3_default)
```

    # A tibble: 100,000 × 3
          id profession working_pattern
       <int> <chr>      <chr>          
     1     1 doctor     full time      
     2     1 doctor     full time      
     3     1 dentist    full time      
     4     1 optician   full time      
     5     1 doctor     full time      
     6     1 optician   full time      
     7     1 doctor     full time      
     8     1 optician   full time      
     9     1 nurse      full time      
    10     1 nurse      full time      
    # … with 99,990 more rows

``` r
# Salted method
num_salt <- 8

sdf1 <- sdf1 |> 
  mutate(salt = ceiling(rand() * num_salt),
         salt = as.integer(salt),
         id_salted = case_when(id == 2 ~ "2", 
                               TRUE ~ paste(id, salt, sep = "-")))

head(sdf1)
```

    # Source: spark<?> [?? x 4]
         id profession  salt id_salted
      <int> <chr>      <int> <chr>    
    1     1 doctor         6 1-6      
    2     1 doctor         6 1-6      
    3     1 dentist        7 1-7      
    4     1 optician       5 1-5      
    5     1 doctor         4 1-4      
    6     1 optician       6 1-6      

``` r
df2 <- tibble(id_salted = paste(1, 1:8, sep = "-")) |> 
  mutate(working_pattern = "full time") |> 
  add_row(id_salted = "2", working_pattern = "part time")

sdf2 <- copy_to(sc, df2, overwrite = TRUE)

sdf3_salted <- sparklyr::left_join(sdf1, sdf2, by = "id_salted")

df3_salted <- collect(sdf3_salted)

print(df3_salted)
```

    # A tibble: 100,000 × 5
          id profession  salt id_salted working_pattern
       <int> <chr>      <int> <chr>     <chr>          
     1     1 optician       7 1-7       full time      
     2     1 dentist        7 1-7       full time      
     3     1 optician       7 1-7       full time      
     4     1 nurse          7 1-7       full time      
     5     1 nurse          7 1-7       full time      
     6     1 optician       7 1-7       full time      
     7     1 optician       7 1-7       full time      
     8     1 dentist        7 1-7       full time      
     9     1 doctor         7 1-7       full time      
    10     1 optician       7 1-7       full time      
    # … with 99,990 more rows
