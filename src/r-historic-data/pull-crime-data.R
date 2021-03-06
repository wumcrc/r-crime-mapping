# Historic Crime Data 
# Load Library 
library(compstatr)
library(dplyr)
library(lubridate)
library(writexl)
library(here)

# Create Index
i <- cs_create_index()

# Get data 
yearlist09 <- cs_get_data(year = 2009, index = i)
yearlist10 <- cs_get_data(year = 2010, index = i)
yearlist11 <- cs_get_data(year = 2011, index = i)
yearlist12 <- cs_get_data(year = 2012, index = i)
yearlist13 <- cs_get_data(year = 2013, index = i)
yearlist14 <- cs_get_data(year = 2014, index = i)
yearlist15 <- cs_get_data(year = 2015, index = i)
yearlist16 <- cs_get_data(year = 2016, index = i)
yearlist17 <- cs_get_data(year = 2017, index = i)
yearlist18 <- cs_get_data(year = 2018, index = i)
yearlist19 <- cs_get_data(year = 2019, index = i)

# Validate Data 
cs_validate(yearlist09, year = 2009)
cs_validate(yearlist10, year = 2010)
cs_validate(yearlist11, year = 2011)
cs_validate(yearlist12, year = 2012)
cs_validate(yearlist13, year = 2013, verbose = TRUE)
cs_validate(yearlist14, year = 2014)
cs_validate(yearlist15, year = 2015)
cs_validate(yearlist16, year = 2016)
cs_validate(yearlist17, year = 2017, verbose = TRUE)
cs_validate(yearlist18, year = 2018)
cs_validate(yearlist19, year = 2019)

# Standardize Data 
# Months prior to 2013 and approximately half of the months during 2013, SLMPD data are released with 18 variables.
yearlist09 <- cs_standardize(yearlist09, config = 18, month = "all")
yearlist10 <- cs_standardize(yearlist10, config = 18, month = "all")
yearlist11 <- cs_standardize(yearlist11, config = 18, month = "all")
yearlist12 <- cs_standardize(yearlist12, config = 18, month = "all")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "January")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "February")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "March")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "April")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "May")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "July")
yearlist13 <- cs_standardize(yearlist13, config = 18, month = "August")
yearlist17 <- cs_standardize(yearlist17, config = 26, month = "May")

# Collapse Data
reports09 <- cs_collapse(yearlist09)
reports10 <- cs_collapse(yearlist10)
reports11 <- cs_collapse(yearlist11)
reports12 <- cs_collapse(yearlist12)
reports13 <- cs_collapse(yearlist13)
reports14 <- cs_collapse(yearlist14)
reports15 <- cs_collapse(yearlist15)
reports16 <- cs_collapse(yearlist16)
reports17 <- cs_collapse(yearlist17)
reports18 <- cs_collapse(yearlist18)
reports19 <- cs_collapse(yearlist19)

# Total Crimes 
crimes09 <- cs_combine(type = "year", date = 2009, reports09, reports10)
crimes10 <- cs_combine(type = "year", date = 2010, reports10, reports11)
crimes11 <- cs_combine(type = "year", date = 2011, reports11, reports12)
crimes12 <- cs_combine(type = "year", date = 2012, reports12, reports13)
crimes13 <- cs_combine(type = "year", date = 2013, reports13, reports14)
crimes14 <- cs_combine(type = "year", date = 2014, reports14, reports15)
crimes15 <- cs_combine(type = "year", date = 2015, reports15, reports16)
crimes16 <- cs_combine(type = "year", date = 2016, reports16, reports17)
crimes17 <- cs_combine(type = "year", date = 2017, reports17, reports18)
crimes18 <- cs_combine(type = "year", date = 2018, reports18, reports19)
crimes19 <- cs_combine(type = "year", date = 2019, reports18, reports19)

# Join Crimes
crimes1 <- full_join(crimes09, crimes10)
crimes2 <- full_join(crimes11, crimes12)
crimes3 <- full_join(crimes13, crimes14)
crimes4 <- full_join(crimes15, crimes16)
crimes5 <- full_join(crimes17, crimes18)
crimes6 <- full_join(crimes19, crimes1) # Crimes 2009, 2010, 2019
crimes7 <- full_join(crimes2, crimes3)  # Crimes 2011, 2012, 2013, 2014
crimes8 <- full_join(crimes4, crimes5)  # Crimes 2015, 2016, 2017, 2018
crimes9 <- full_join(crimes7, crimes8)  # Crimes 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018
crimes <- full_join(crimes9, crimes6)   # Crimes 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019

# Save Data 
save(crimes,  file = here("data", "crime-data", "total-crimes-10yrs.rda"))

# Clean Environment
rm(list = ls())