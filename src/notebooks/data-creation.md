Data Creation
================
Jes Stevens, M.A.
(September 26, 2019)

## Introduction

[Washington University Medical Center Redevelopment
Corporation](http://wumcrc.com) is a partnership between BJC Health Care
and Washington University School of Medicine and works to improve the
quality of life for the neighborhoods surrounding the medical campus. In
order to achieve this goal in Forest Park Southeast and the Central West
End , WUMCRC has invested millions of dollars toward regenerating the
market for private investment in businesses and real estate, enhancing
human and social service opportunities, and improving the level of
physical and personal security.

One way we work to improve the level of physical & personal security is
the analysis and distribution of data. The original source of this crime
data is <http://slmpd.org/crimereports.shtml>. This notebook uses
primarily `compstatr` to access and clean the crime data.

## R Markdown

## Tidy data

### Get Crime Data

``` r
i <- cs_create_index()
yearlist18 <- cs_get_data(year = params$pastyear, index = i)
yearlist19 <- cs_get_data(year = params$year, index = i) # Constructs a table for finding a table of crime data
cs_validate(yearlist18, year = 2018)
```

    ## [1] TRUE

``` r
cs_validate(yearlist19, year = 2019) # Identifies problems with SLMPD Data
```

    ## [1] TRUE

#### Standardize Data for Cleaning

``` r
totalCrimes18 <- cs_collapse(yearlist18)
ytdCrimes19 <- cs_collapse(yearlist19) 
```

### Clean & Categorize Data

#### 2019

`cs_filter_count` removes negative counts. Negative counts, -1, in the
count column means that the crime, or charge in this specific
observation has either been deemed unfounded, or the crime has been up
coded. We do not want to map this data.

Many of the analyses we conduct include comparisons between violent &
non-violent crime, comparisons on the amount of crimes happening in each
crime cateogy over time, and if crimes occur during the day or at night.
The following code ceates variables to conduct these analyses.

`cs_crime_cat` creates a variable with the names of the crime.

`cs_crime` creates a logic variable and codes categories of crimes as
either `TRUE` or `FALSE` based on the input.

`cs_parse_date` creates two columns separating the `Date Occur`
variable. The two colums are as follows: one contains the date - month,
date, and year, and the other contains the hour and minute. This is used
because crimes coded in the most recent month, can contain dates that
occured, in previous months or years & in this report we only want to
map the crimes that occured in the past month.

`filter` is a `dplyr` function that filters out any dates that occur
before the our selected date, and also filters out crimes that did not
happen in either District 2 or district 5.

`mutate` adds a variable that codes and labels the days of the week for
each crime that occurred, and creates another time of day variable.

`strptime` and `format` takes the new time variable and formats it to a
character so that we can determine if the crime occured at day or at
night, and creates a second coded variable that labels each observations
as day or night based on the newly formated time variable.

`select` drops the unneeded variables.

`cs_missing_XY` determines what data does not have x & y coordinates,
and therefore cannot be accurately mapped.

`cs_replace0` replaces missing x & y coordinates with `NA`, and drops
the missing data.

`strptime` and `format` takes the new time variable and formats it to a
character so that we can determine if the crime occured at day or at
night, and creates a second coded variable that labels each observations
as day or night based on the newly formated time variable.

`select` drops the unneeded variables.

`cs_missing_XY` determines what data does not have x & y coordinates,
and therefore cannot be accurately mapped.

`cs_replace0` replaces missing x & y coordinates with `NA`, and drops
the missing data.

`monthCrimes` is an object that holds crimes for the current month of
this year.

``` r
ytdCrimes19 <- ytdCrimes19 %>% 
  cs_filter_count(., var = count) %>%
  cs_filter_crime(., var = crime, "part 1") %>%
  cs_crime_cat(., var = crime, crimeCatNum, "numeric") %>%
  cs_crime_cat(., var = crime, crimeCatName, "string") %>%
  cs_crime(., var = crime, violent, "violent") %>%
  cs_crime(., var = crime, property, "property") %>%
  cs_parse_date(., date_occur, dateVar = dateOcc, timeVar = timeOcc) %>%
  filter(district == 2 | district == 5) %>%
  mutate(weekday = wday(dateOcc, label = TRUE)) %>%
  mutate(monthVar = dateOcc) %>%
  mutate(tod = timeOcc)

ytdCrimes19$monthVar <- month(as.Date(ytdCrimes19$monthVar, format="%d/%m/%Y"), label = TRUE)

ytdCrimes19$neighborhood <- as.numeric(ytdCrimes19$neighborhood)
ytdCrimes19$tod <- strptime(ytdCrimes19$tod, tz = "America/Chicago", "%H:%M")
ytdCrimes19$tod <- format(ytdCrimes19$tod, format = "%H%M%S")

ytdCrimes19 <- ytdCrimes19 %>%
  filter(dateOcc >= as.Date(params$ytd)) %>%
  mutate(., dayNight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day")) %>% 
  dplyr::select(-dateTime, -tod, -flag_crime, -flag_administrative, -flag_unfounded, -flag_cleanup)  %>%
  cs_missingXY(., varX = x_coord, varY = y_coord, newVar = missing) %>% 
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) %>% 
  filter(., missing == FALSE) 

monthCrimes19 <- ytdCrimes19 %>% 
    filter(dateOcc >= as.Date(params$date))
```

##### Larcenies

``` r
larceny <- monthCrimes19 %>% 
  filter(., crimeCatNum == 6)

larceny <- mutate(larceny, "type" = ifelse(grepl("ALL OTHER", description), "All Other", 
                                    ifelse(grepl("BICYCLE", description), "Bicycle", 
                                    ifelse(grepl("FROM BUILDING", description), "From Building", 
                                    ifelse(grepl("FROM COIN", description), "From Coin Machine", 
                                    ifelse(grepl("FROM MTR VEH", description), "From Motor Vehicle", 
                                    ifelse(grepl("MTR VEH PARTS", description), "Motor Vehicle Parts",
                                    ifelse(grepl("PURSE", description), "Purse Snatching",
                                    ifelse(grepl("SHOPLIFT", description), "Shoplifting",
                                    ifelse(grepl("FRM PRSN", description), "From Person", NA))))))))))

larceny <- mutate(larceny, "value" = ifelse(grepl("UNDER", description), "Under $500",
                                     ifelse(grepl("\\$500 - \\$24,999", description), "$500 - $24,999",
                                     ifelse(grepl("OVER \\$25,000", description), "Over $25,000", NA)))) 
```

#### 2018

``` r
totalCrimes18 <- totalCrimes18 %>% 
  cs_filter_count(., var = count) %>%
  cs_filter_crime(., var = crime, "part 1") %>%
  cs_crime_cat(., var = crime, crimeCatNum, "numeric") %>%
  cs_crime_cat(., var = crime, crimeCatName, "string") %>%
  cs_crime(., var = crime, violent, "violent") %>%
  cs_crime(., var = crime, property, "property") %>%
  cs_parse_date(., date_occur, dateVar = dateOcc, timeVar = timeOcc) %>%
  filter(district == 2 | district == 5) %>%
  mutate(weekday = wday(dateOcc, label = TRUE)) %>%
  mutate(monthVar = dateOcc) %>%
  mutate(tod = timeOcc) 

totalCrimes18$monthVar <- month(as.Date(totalCrimes18$monthVar, format="%d/%m/%Y"), label = TRUE)

totalCrimes18$neighborhood <- as.numeric(totalCrimes18$neighborhood)

totalCrimes18$tod <- strptime(totalCrimes18$tod, tz = "America/Chicago", "%H:%M")
totalCrimes18$tod <- format(totalCrimes18$tod, format = "%H%M%S")

totalCrimes18 <- totalCrimes18 %>%
  mutate(., dayNight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day")) %>% 
  dplyr::select(-dateTime, -tod, -flag_crime, -flag_administrative, -flag_unfounded, -flag_cleanup) %>%
  cs_missingXY(., varX = x_coord, varY = y_coord, newVar = missing) %>%
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) %>% 
  filter(., missing == FALSE) %>% 
  filter(dateOcc >= as.Date(params$pastdate))

monthCrimes18 <- totalCrimes18 %>% 
    filter(dateOcc >= as.Date(params$pstdtmonth) & dateOcc <= as.Date(params$pstdtmonth2))

ytdCrimes18 <- totalCrimes18%>% 
    filter(dateOcc <= as.Date(params$pstdtmonth2))
```

### Get Spatial Data

#### External Shapefiles

#### Tiles from Mapbox

``` r
xyfpse <- c(-90.2679, -90.2423, 38.6176, 38.6334)
xycwe <- c(-90.2759, -90.2368, 38.6286, 38.6552)
xybot <- c(-90.2619, -90.2409, 38.6165, 38.6296)
xydbp <- c(-90.2869, -90.2726, 38.6433, 38.6566)
xysdb <- c(-90.3026, -90.2827, 38.6456, 38.6571)
xywe <- c(-90.3020, -90.2712, 38.6517, 38.6710)
xyvp <- c(-90.2803, -90.2712, 38.6517, 38.6622)
xyac <- c(-90.2744, -90.2609, 38.6505, 38.6661)
xyfp <- c(-90.2648, -90.2543, 38.6493, 38.6655)
xylp <- c(-90.2588, -90.2437, 38.6481, 38.6624)
xyvd <- c(-90.2520, -90.2304, 38.6426, 38.6585)
xymc <- c(-90.2678, -90.2515, 38.6305, 38.6411)
xyctx <- c(-90.2581, -90.2419, 38.6299, 38.6386)
xygrv <- c(-90.2662, -90.2440, 38.6238, 38.6318)
xydst2 <- c(-90.3203, -90.2297, 38.5613, 38.6493)
xydst5 <- c(-90.3080, -90.2132, 38.6273, 38.6962)

fpse_tiles <- raster::extent(xyfpse) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 6 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
cwe_tiles <- raster::extent(xycwe) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 9 tiles at zoom = 14 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
bot_tiles <- raster::extent(xybot) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 9 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
dbp_tiles <- raster::extent(xydbp) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 6 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
sdb_tiles <- raster::extent(xysdb) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 6 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
we_tiles <- raster::extent(xywe) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 12 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
vp_tiles <- raster::extent(xyvp) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 9 tiles at zoom = 16 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
ac_tiles <- raster::extent(xyac) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 15 tiles at zoom = 16 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
fp_tiles <- raster::extent(xyfp) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 15 tiles at zoom = 16 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
lp_tiles <- raster::extent(xylp) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 6 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
vd_tiles <- raster::extent(xyvd) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 9 tiles at zoom = 15 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
mc_tiles <- raster::extent(xymc) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 12 tiles at zoom = 16 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
ctx_tiles <- raster::extent(xyctx) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 9 tiles at zoom = 16 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
grv_tiles <- raster::extent(xygrv) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 15 tiles at zoom = 16 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
dst2_tiles <- raster::extent(xydst2) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 9 tiles at zoom = 13 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
dst5_tiles <- raster::extent(xydst5) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)
```

    ## Preparing to download: 12 tiles at zoom = 13 from 
    ## https://api.mapbox.com/v4/mapbox.streets/

``` r
save(fpse_tiles, cwe_tiles, bot_tiles, dbp_tiles, sdb_tiles, we_tiles, vp_tiles, ac_tiles, fp_tiles, lp_tiles, vd_tiles, mc_tiles, ctx_tiles, grv_tiles, dst2_tiles, dst5_tiles, file = here("data", "basemap-files", "mapbox-tiles.rda"))

fpse <- filter(nhoods_sf, neighborhood == 39 )
cwe <- filter(nhoods_sf, neighborhood == 38 )
bot <- filter(nhoods_sf, neighborhood == 28 )
dbp <- filter(nhoods_sf, neighborhood == 47 )
sdb <- filter(nhoods_sf, neighborhood == 46 )
we <- filter(nhoods_sf, neighborhood == 48 )
vp <- filter(nhoods_sf, neighborhood == 49 )
ac <- filter(nhoods_sf, neighborhood == 51 )
fp <- filter(nhoods_sf, neighborhood == 53 )
lp <- filter(nhoods_sf, neighborhood == 54 )
vd <- filter(nhoods_sf, neighborhood == 58 )

save(fpse, cwe, bot, dbp, sdb, we, vp, ac, fp, lp, vd, file = here("data", "basemap-files", "nbhd-boundaries.rda"))
```

``` r
# all crimes 
totalCrimes18_sf <- cs_projectXY(totalCrimes18, varX = x_coord, varY = y_coord, crs = 102696)
ytdCrimes18_sf <- cs_projectXY(ytdCrimes18, varX = x_coord, varY = y_coord, crs = 102696)
ytdCrimes19_sf <- cs_projectXY(ytdCrimes19, varX = x_coord, varY = y_coord, crs = 102696)

monthCrimes18_sf <- cs_projectXY(monthCrimes18, varX = x_coord, varY = y_coord, crs = 102696)
monthCrimes19_sf <- cs_projectXY(monthCrimes19, varX = x_coord, varY = y_coord, crs = 102696)

larceny_sf <- cs_projectXY(larceny, varX = x_coord, varY = y_coord, crs = 102696)

# med campus
mc_crimes_month18_sf <- st_intersection(monthCrimes18_sf, med_campus) 
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
mc_crimes_month18 <- mc_crimes_month18_sf  %>% 
   as.data.frame() 

mc_crimes_month19_sf <- st_intersection(monthCrimes19_sf, med_campus)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
mc_crimes_month19 <- mc_crimes_month19_sf  %>% 
   as.data.frame()

mc_crimes_ytd18_sf <- st_intersection(ytdCrimes18_sf, med_campus) 
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
mc_crimes_ytd18 <- mc_crimes_ytd18_sf %>% 
   as.data.frame() 

mc_crimes_ytd19_sf <- st_intersection(ytdCrimes19_sf, med_campus)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
mc_crimes_ytd19 <- mc_crimes_ytd19_sf %>% 
   as.data.frame()

mc_crimes_total18_sf <- st_intersection(totalCrimes18_sf, med_campus)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
mc_crimes_total18 <- mc_crimes_total18_sf %>% 
   as.data.frame()

mc_larcenies_sf <- st_intersection(larceny_sf, med_campus)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
mc_larcenies <- mc_larcenies_sf %>% 
   as.data.frame()

# cortex
ctx_crimes_sf <- st_intersection(monthCrimes19_sf, cortex)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
# police districts 
dst_2 <- monthCrimes19 %>% 
  filter(., neighborhood %in% dst2) %>% 
  group_by(., neighborhood) %>%
  count() %>% 
  rename(crimeTotal = n) %>%
  left_join(nbhd_pop10, by = "neighborhood") %>% 
  mutate(., crimeRate = (crimeTotal/pop10)*1000) %>% 
  drop_na()

dst_5 <- monthCrimes19 %>% 
  filter(., neighborhood %in% dst5) %>% 
  group_by(., neighborhood) %>%
  count() %>% 
  rename(crimeTotal = n) %>%
  left_join(nbhd_pop10, by = "neighborhood") %>% 
  mutate(., crimeRate = (crimeTotal/pop10)*1000) %>% 
  drop_na()

dst_2_pop_sf <- left_join(nhoods_sf, dst_2, by = "neighborhood") %>% 
  st_transform(crs = 102696) %>%
  drop_na() %>% 
  subset(., neighborhood != 88)

dst_5_pop_sf <- left_join(nhoods_sf, dst_5, by = "neighborhood") %>% 
  st_transform(crs = 102696) %>%
  drop_na()

# Save
save(totalCrimes18_sf, ytdCrimes18_sf, ytdCrimes19_sf, monthCrimes18_sf, monthCrimes19_sf, mc_crimes_month18_sf, mc_crimes_month19_sf, mc_crimes_ytd18_sf, mc_crimes_total18_sf, mc_crimes_ytd19_sf, mc_larcenies_sf, ctx_crimes_sf, dst_2_pop_sf, dst_5_pop_sf, file = here("data", "spatial-crime-data.rda"))

save(ytdCrimes18, ytdCrimes19, monthCrimes18, monthCrimes19, totalCrimes18, larceny, mc_crimes_month18, mc_crimes_month19, mc_crimes_ytd18, mc_crimes_total18, mc_crimes_ytd19, mc_larcenies, dst_2, dst_5, file = here("data", "crime-data.rda"))
```

``` r
rm(list = ls())
```