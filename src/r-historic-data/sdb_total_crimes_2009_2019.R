# Load Library 
library(compstatr)
library(dplyr)
library(lubridate)
library(writexl)
library(here)

# Load Data
load(file = here("data", "crime-data", "total-crimes-10yrs.rda"))

# Extract Skinker DeBaliviere 
sdb_crimes <- filter(crimes, neighborhood == 46)

# Add Crime Details 
sdb_crimes_tidy <- sdb_crimes %>% 
  cs_filter_count(., var = count) %>%                                           # Removes Negative Counts
  cs_filter_crime(., var = crime, "part 1") %>%                                 # Filters Part 1 Crimes 
  cs_crime_cat(., var = crime, crimeCatNum, "numeric") %>%                      
  cs_crime_cat(., var = crime, crimeCatName, "string") %>%                      # Labels Crime Categories
  cs_crime(., var = crime, violent, "violent") %>%                              # Labels Violent Crimes 
  cs_crime(., var = crime, property, "property") %>%                            # Labels Property Crimes
  cs_crime(., var = crime, larceny, 6) %>%                                      # Labels Larceny Crimes
  cs_parse_date(., date_occur, dateVar = dateOcc, timeVar = timeOcc) %>%        # Parses Date Data
  mutate(weekday = wday(dateOcc, label = TRUE)) %>%                             # Labels Days of the Week
  mutate(monthVar = dateOcc) %>%
  mutate(tod = timeOcc)

sdb_crimes_tidy$monthVar <- month(as.Date(sdb_crimes_tidy$monthVar, 
                                      format="%d/%m/%Y"), label = TRUE)

sdb_crimes_tidy$tod <- strptime(sdb_crimes_tidy$tod, 
                            tz = "America/Chicago", "%H:%M")

sdb_crimes_tidy$tod <- format(sdb_crimes_tidy$tod, 
                          format = "%H%M%S")

sdb_crimes_tidy <- sdb_crimes_tidy %>%
  mutate(., dayNight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day")) %>% 
  dplyr::select(-dateTime, -tod, -flag_crime, 
                -flag_administrative, -flag_unfounded, -flag_cleanup)  %>%
  cs_missingXY(., varX = x_coord, varY = y_coord, newVar = missing) %>% 
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) 

sdb_crimes_tidy <- mutate(sdb_crimes_tidy, "type" = ifelse(grepl("ALL OTHER", description), "All Other", 
                                           ifelse(grepl("BICYCLE", description), "Bicycle", 
                                                  ifelse(grepl("FROM BUILDING", description), "From Building", 
                                                         ifelse(grepl("FROM COIN", description), "From Coin Machine", 
                                                                ifelse(grepl("FROM MTR VEH", description), "From Motor Vehicle", 
                                                                       ifelse(grepl("MTR VEH PARTS", description), "Motor Vehicle Parts",
                                                                              ifelse(grepl("PURSE", description), "Purse Snatching",
                                                                                     ifelse(grepl("SHOPLIFT", description), "Shoplifting",
                                                                                            ifelse(grepl("FRM PRSN", description), "From Person", NA))))))))))

sdb_crimes_tidy <- mutate(sdb_crimes_tidy, "value" = ifelse(grepl("UNDER", description), "Under $500",
                                            ifelse(grepl("\\$500 - \\$24,999", description), "$500 - $24,999",
                                                   ifelse(grepl("OVER \\$25,000", description), "Over $25,000", NA))))

write_xlsx(sdb_crimes_tidy, here("results", "historic-data", "sdb_total_crimes_2009_2019.xlsx"))