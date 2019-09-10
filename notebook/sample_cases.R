# Test for Cause Numbers

# load dependencies
library(compstatr)
library(ggplot2)
library(magrittr)
library(mapview)
library(stringr)
library(tidyr)
library(chron)
library(lubridate)
library(dplyr)
library(here)
library(readr)
library(readxl)

here()

i <- cs_create_index()

yearList18 <- cs_get_data(year = 2018, index = i)
yearList19 <- cs_get_data(year = 2019, index = i)

cs_validate(yearList18, year = 2018)
cs_validate(yearList19, year = 2019)

crimes18 <- cs_collapse(yearList18)
crimes19 <- cs_collapse(yearList19)

testCrimes <- rbind(crimes18, crimes19)

causeNums <- c("18-059543", "19-010109", "19-005195", "19-006878", "19-005008")

casesTracked <- testCrimes %>% 
  cs_filter_count(., var = count)

casesTracked <- filter(casesTracked, complaint %in% causeNums) 

casesTrackedClean <- cs_missingXY(casesTracked, varX = x_coord, varY = y_coord, newVar = missing)
table(casesTrackedClean$missing)

casesTrackedClean <- casesTrackedClean %>% 
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) %>% 
  filter(., missing == FALSE)

# project data
casesTrackedClean_sf <- cs_projectXY(casesTrackedClean, varX = x_coord, varY = y_coord)

# preview data
casesMap <- mapview(casesTrackedClean_sf)

# export image
mapshot(casesMap, file = here("data/results/cases_test.jpeg"), 
        remove_controls = c("zoomControl", "layersControl", "homeButton",
                            "scaleBar"))

# export cases
write_csv(casesTrackedClean, here("data/results/sample_cases.csv"), col_names = TRUE)
