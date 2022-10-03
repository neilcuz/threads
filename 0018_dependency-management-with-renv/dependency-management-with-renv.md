Dependency Management with renv
================

This notebook contains the code underpinning the Dependency Management
with renv in R thread.

Follow me on Twitter [@neilgcurrie](twitter.com/neilgcurrie) and visit
[torchdata.io](https://www.torchdata.io).

You can find links to all my threads
[here](https://github.com/neilcuz/threads).

## Using renv

To use `renv` we first need to install it.

``` r
install.packages("renv")
```

Now we initialise `renv` within the project.

``` r
renv::init()
```

Install, update and use packages as normal.

``` r
install.packages("dplyr")
library(dplyr)
```

To take a snapshot of the current project state call `snapshot`. If for
some reason you run into problems you can call the `restore` function to
revert to the previous lock file.

``` r
renv::snapshot()
renv::restore()
```

For a new user to recreate the project library in the same state you had
it share on GitHub and it should rebuild automatically when they open
the project for the first time.
