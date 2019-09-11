# Crime Data Analysis Example - compstatr

# load dependencies
library(compstatr)
library(ggplot2)
library(magrittr)
library(mapview)

# subset homicides and removed unfounded incidents
janHomicides <- january2018 %>%
  cs_filter_count(var = count) %>%
  cs_filter_crime(var = crime, crime = "homicide")

# identify missing spatial data
janHomicides <- cs_missingXY(janHomicides, varX = x_coord, varY = y_coord, newVar = missing)

# check for any TRUE values
table(janHomicides$missing)

# project data
janHomicides_sf <- cs_projectXY(janHomicides, varX = x_coord, varY = y_coord)

# preview data
mapview(janHomicides_sf)
