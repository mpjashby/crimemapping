<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

# `crimemapping` package

This package provides an introductory course in crime mapping: using maps and 
spatial analysis to understand and respond to crime. The course consists of 
interactive tutorials built using the 
[`learnr` package](https://rstudio.github.io/learnr/).



## Installation

We will use R and RStudio to produce most of the maps and spatial analysis that 
we will work on in this module. Most of the sessions will take the form of 
interactive tutorials inside RStudio. As a first step, install R and RStudio on 
your computer – both are free software and available for Mac, Windows and Linux.

  1. [Download R](https://cran.r-project.org/) (**choose the 'latest
     release'**) for your computer from the R website and install it. If you 
     already have R installed on your machine, please update it to the latest 
     release. If you need help, [watch this Install R 
     video](https://vimeo.com/203516510).
  2. [Download **RStudio 
     Desktop**](https://rstudio.com/products/rstudio/download/) (Open Source 
     License) for your computer from the RStudio website and install. If you 
     already have RStudio Desktop installed on your machine, please update it to 
     the latest release. If you need help, [watch this Install RStudio 
     video](https://vimeo.com/203516968).
  3. Open RStudio and paste the following two lines of code exactly as they
     are into the Console panel just to the right of the `>` symbol in the 
     bottom-left corner (there may be a flashing cursor to the right of the `>` 
     symbol).

```r
install.packages("remotes")
remotes::install_github("mpjashby/crimemapping")
```

  4. Load the first tutorial by pasting the following line of code into Console.

```r
crimemapping::tutorial("01_getting_started")
```


## Usage

You can see a list of available tutorials by typing:

```r
crimemapping::tutorial()
```

You can load any tutorial by specifying the short name of the tutorial, e.g.

```r
crimemapping::tutorial("02_your_first_crime_map")
```
