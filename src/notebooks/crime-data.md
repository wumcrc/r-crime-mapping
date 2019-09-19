Saint Louis City Crime Data - Monthly Reports
================
Jes Stevens, M.A.
(September 19, 2019)

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

### Create an Index

``` r
i <- cs_create_index()
```

### Get Data - 2019

``` r
update <- cs_last_update()
update <- strsplit(update, " ")[[1]]
c_month <- update[[1]]
c_year <- as.numeric(update[[2]])
yearList19 <- cs_get_data(year = c_year, index = i)
```

### Download Current Month

``` r
cs_validate(yearList19, year = 2019)
```

    ## [1] TRUE

``` r
totalCrimes19 <- cs_collapse(yearList19)
```

``` r
print(c_month)
```

    ## [1] "August"

``` r
crimes19 <- cs_extract_month(yearList19, month = "August") 
rm(yearList19)
```

### Clean & Categorize Data - 2019

`cs_filter_count` removes negative counts. Negative counts, -1, in the
count column means that the crime, or charge in this specific
observation has either been deemed unfounded, or the crime has been up
coded. We do not want to map this data.

Many of the analyses we conduct include comparisons between violent &
non-violent crime, comparisons on the amount of crimes happening in each
crime cateogy over time, and if crimes occur during the day or at night.
The following code ceates variables to conduct these analyses.

`cs_crime_cat` creates a variable with the names of the crime.

`cs_crime` creates a logic variable and codes violent crimes as `TRUE`
and non-violent crimes as `FALSE`

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
each crime that occurred, and creates another time of day variable

``` r
tidyCrimes19 <- crimes19 %>% 
  cs_filter_count(., var = count) %>%
  cs_filter_crime(., var = crime, "part 1") %>%
  cs_crime_cat(., var = crime, crimeCatNum, "numeric") %>%
  cs_crime_cat(., var = crime, crimeCatName, "string") %>%
  cs_crime(., var = crime, violent, "violent") %>%
  cs_crime(., var = crime, property, "property") %>%
  cs_parse_date(., date_occur, dateVar = dateOcc, timeVar = timeOcc) %>%
  filter(dateOcc >= as.Date("2019-08-01")) %>%
  filter(district == 2 | district == 5) %>%
  mutate(weekday = wday(dateOcc, label = TRUE)) %>%
  mutate(tod = timeOcc)

tidyCrimes19$neighborhood <- as.numeric(tidyCrimes19$neighborhood)
```

`strptime` and `format` takes the new time variable and formats it to a
character so that we can determine if the crime occured at day or at
night, and creates a second coded variable that labels each observations
as day or night based on the newly formated time variable.

`select` drops the unneeded variables.

`cs_missing_XY` determines what data does not have x & y coordinates,
and therefore cannot be accurately mapped.

`cs_replace0` replaces missing x & y coordinates with `NA`, and drops
the missing data.

``` r
tidyCrimes19$tod <- strptime(tidyCrimes19$tod, tz = "America/Chicago", "%H:%M")
tidyCrimes19$tod <- format(tidyCrimes19$tod, format = "%H%M%S")

tidyCrimes19 <- tidyCrimes19 %>%
  mutate(., dayNight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day")) %>% 
  dplyr::select(-dateTime, -tod, -flag_crime, -flag_administrative, -flag_unfounded, -flag_cleanup)

tidyCrimes19 <- cs_missingXY(tidyCrimes19, varX = x_coord, varY = y_coord, newVar = missing)
table(tidyCrimes19$missing)
```

    ## 
    ## FALSE  TRUE 
    ##   735     4

``` r
tidyCrimes19 <- tidyCrimes19 %>% 
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) %>% 
  filter(., missing == FALSE) 
```

### Get Data - 2018

``` r
yearList18 <- cs_get_data(year = 2018, index = i)
```

### Data Preperation

``` r
cs_validate(yearList18, year = 2018)
```

    ## [1] TRUE

### Download Last Year’s Month

``` r
totalCrimes18 <- cs_collapse(yearList18)
monthCrimes18 <- cs_extract_month(yearList18, month = "August")
rm(yearList18)
```

### Clean & Categorize Data - 2018

``` r
tidyMonthCrimes18 <- monthCrimes18 %>% 
  cs_filter_count(., var = count) %>%
  cs_filter_crime(., var = crime, "part 1") %>%
  cs_crime_cat(., var = crime, crimeCatNum, "numeric") %>%
  cs_crime_cat(., var = crime, crimeCatName, "string") %>%
  cs_crime(., var = crime, violent, "violent") %>%
  cs_crime(., var = crime, property, "property") %>%
  cs_parse_date(., date_occur, dateVar = dateOcc, timeVar = timeOcc) %>%
  filter(dateOcc >= as.Date("2018-08-01") & dateOcc <= as.Date("2018-08-31")) %>%
  filter(district == 2 | district == 5) %>%
  mutate(weekday = wday(dateOcc, label = TRUE)) %>%
  mutate(tod = timeOcc)

tidyMonthCrimes18$neighborhood <- as.numeric(tidyMonthCrimes18$neighborhood)

tidyMonthCrimes18$tod <- strptime(tidyMonthCrimes18$tod, tz = "America/Chicago", "%H:%M")
tidyMonthCrimes18$tod <- format(tidyMonthCrimes18$tod, format = "%H%M%S")

tidyMonthCrimes18 <- tidyMonthCrimes18 %>%
  mutate(., dayNight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day")) %>% 
  dplyr::select(-dateTime, -tod, -flag_crime, -flag_administrative, -flag_unfounded, -flag_cleanup)

tidyMonthCrimes18 <- cs_missingXY(tidyMonthCrimes18, varX = x_coord, varY = y_coord, newVar = missing)
table(tidyMonthCrimes18$missing)
```

    ## 
    ## FALSE  TRUE 
    ##   747     9

``` r
tidyMonthCrimes18 <- tidyMonthCrimes18 %>% 
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) %>% 
  filter(., missing == FALSE)
```

``` r
tidyTotalCrimes18 <- totalCrimes18 %>% 
  cs_filter_count(., var = count) %>%
  cs_filter_crime(., var = crime, "part 1") %>%
  cs_crime_cat(., var = crime, crimeCatNum, "numeric") %>%
  cs_crime_cat(., var = crime, crimeCatName, "string") %>%
  cs_crime(., var = crime, violent, "violent") %>%
  cs_crime(., var = crime, property, "property") %>%
  cs_parse_month(., var = coded_month, yearVar = reportYear, month = monthVar) %>%
  cs_parse_date(., date_occur, dateVar = dateOcc, timeVar = timeOcc) %>%
  filter(district == 2 | district == 5) %>%
  mutate(weekday = wday(dateOcc, label = TRUE)) %>%
  mutate(tod = timeOcc) 

tidyTotalCrimes18$neighborhood <- as.numeric(tidyTotalCrimes18$neighborhood)

tidyTotalCrimes18$tod <- strptime(tidyTotalCrimes18$tod, tz = "America/Chicago", "%H:%M")
tidyTotalCrimes18$tod <- format(tidyTotalCrimes18$tod, format = "%H%M%S")

tidyTotalCrimes18 <- tidyTotalCrimes18 %>%
  mutate(., dayNight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day")) %>% 
  dplyr::select(-dateTime, -tod, -flag_crime, -flag_administrative, -flag_unfounded, -flag_cleanup)

tidyTotalCrimes18 <- cs_missingXY(tidyTotalCrimes18, varX = x_coord, varY = y_coord, newVar = missing)
table(tidyTotalCrimes18$missing)
```

    ## 
    ## FALSE  TRUE 
    ##  7729   139

``` r
tidyTotalCrimes18 <- tidyTotalCrimes18 %>% 
  cs_replace0(., var = x_coord) %>%
  cs_replace0(., var = y_coord) %>% 
  filter(., missing == FALSE)

rm(totalCrimes18)
```

### Combine 2018 & 2019

``` r
augustCrimes <- rbind(tidyMonthCrimes18, tidyCrimes19)
```

### Create Spatial Objects

``` r
crimes19_sf <- cs_projectXY(tidyCrimes19, varX = x_coord, varY = y_coord, crs = 102696)
augustCrimes_sf <- cs_projectXY(augustCrimes, varX = x_coord, varY = y_coord, crs = 102696)
```

### Prep for Data by Neighborhood

``` r
sa <- c(39,28,38,51,53,54,58,46,47,48,48)
dst2 <- c(7:15,27:29, 39:45,81,82,87,88)
dst5 <- c(38,46:58,78)
```

## Mapping

One way we work to improve the level of physical & personal security is
the analysis and distribution of crime data and statistics. The original
source of this crime data is <http://slmpd.org/crimereports.shtml>. This
notebook takes the data that was previously cleaned and maps the data.

## Load Spatial Data

### Coordinates

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
```

### Open Street Map from Mapbox - Basemap Tile Imagery

### Load External Data

#### Population Data

``` r
load(here("data/nbhd_pop10.rda"))
```

#### Spatial

### Combine Population & Neighborhood Spatial Data by Police District

#### Oganize & Filter Crime Data by Neighborhood

``` r
dst_2 <- tidyCrimes19 %>% 
  filter(., neighborhood %in% dst2) %>% 
  group_by(., neighborhood) %>%
  count() %>% 
  rename(crimeTotal = n) %>%
  left_join(nbhd_pop10, by = "neighborhood") %>% 
  mutate(., crimeRate = (crimeTotal/pop10)*1000) %>% 
  drop_na()
```

``` r
dst_5 <- tidyCrimes19 %>% 
  filter(., neighborhood %in% dst5) %>% 
  group_by(., neighborhood) %>%
  count() %>% 
  rename(crimeTotal = n) %>%
  left_join(nbhd_pop10, by = "neighborhood") %>% 
  mutate(., crimeRate = (crimeTotal/pop10)*1000) %>% 
  drop_na()
```

``` r
dst_2_pop <- left_join(nhoods_sf, dst_2, by = "neighborhood") %>% 
  st_transform(crs = 102696) %>%
  drop_na() %>% 
  subset(., neighborhood != 88)
```

``` r
dst_5_pop <- left_join(nhoods_sf, dst_5, by = "neighborhood") %>% 
  st_transform(crs = 102696) %>%
  drop_na()
```

### FPSE, BOT, CWE, MC

#### Map Creation

##### FPSE

``` r
fpse_total_tm <- tm_shape(fpse_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 39) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 39) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "crimeCatName", 
               palette = "Set1", 
               title.col = "Part 1 Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "FPSE Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

fpse_total_tm
```

![](crime-data_files/figure-gfm/FPSE%20Total%20Crime-1.png)<!-- -->

``` r
fpse_dn_tm <- tm_shape(fpse_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 39) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 39) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "dayNight", 
               palette = "-RdBu", 
               title.col = "Time of Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "FPSE Time of Crimes - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

fpse_dn_tm
```

![](crime-data_files/figure-gfm/FPSE%20Day%20&%20Night-1.png)<!-- -->

``` r
fpse_vlnt_tm <- tm_shape(fpse_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 39) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 39) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "violent", 
               palette = "Reds", 
               title.col = "Violent") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "FPSE Violent Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

fpse_vlnt_tm
```

![](crime-data_files/figure-gfm/FPSE%20Crimes%20Against%20Persons-1.png)<!-- -->

``` r
crimes19_sf %>%
  filter(neighborhood == 39) %>%
  smooth_map(., bandwidth = 0.5, style = "pretty",
  cover = fpse) -> fpse_densities
```

    ## 
      |                                                                       
      |                                                                 |   0%
      |                                                                       
      |======                                                           |  10%
      |                                                                       
      |====================                                             |  30%
      |                                                                       
      |================================                                 |  50%
      |                                                                       
      |==============================================                   |  70%
      |                                                                       
      |==========================================================       |  90%
      |                                                                       
      |=================================================================| 100%

``` r
fpse_den_tm <- tm_shape(fpse_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 39) %>% 
  tm_shape() +
    tm_fill(col = NA, 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  tm_shape(fpse_densities$polygons) +
  tm_fill(col = "level", palette = "BuPu", alpha = .60, 
    title = expression("Crimes per " * km^2)) +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "FPSE Crime Density - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

fpse_den_tm
```

![](crime-data_files/figure-gfm/FPSE%20Density%20Map%20Output-1.png)<!-- -->
\#\#\#\#\#\# Grove CID

``` r
grove_crimes <- st_intersection(crimes19_sf, grove_cid)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
fpse_grove_tm <- tm_shape(grv_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 39) %>% 
  tm_shape() +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  tm_shape(grove_cid) +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 1, 
               lty = "solid") +
  tm_shape(grove_crimes) +
    tm_bubbles(size = .25, 
               col = "crimeCatName", 
               palette = "Set1", 
               title.col = "Part 1 Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "Grove CID Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

fpse_grove_tm
```

![](crime-data_files/figure-gfm/Grove%20CID%20Total%20Crime-1.png)<!-- -->

##### CWE

``` r
cwe_total_tm <- tm_shape(cwe_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 38) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 38) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "crimeCatName", 
               palette = "Set1", 
               title.col = "Part 1 Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "CWE Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

cwe_total_tm
```

![](crime-data_files/figure-gfm/CWE%20Total%20Crime-1.png)<!-- -->

``` r
cwe_dn_tm <- tm_shape(cwe_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 38) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 38) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "dayNight", 
               palette = "-RdBu", 
               title.col = "Time of Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "CWE Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

cwe_dn_tm
```

![](crime-data_files/figure-gfm/cwe%20Day%20&%20Night-1.png)<!-- -->

``` r
cwe_vlnt_tm <- tm_shape(cwe_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 38) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 38) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "violent", 
               palette = "Reds", 
               title.col = "Violent") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "CWE Time of Crimes - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

cwe_vlnt_tm
```

![](crime-data_files/figure-gfm/CWE%20Crimes%20Against%20Persons-1.png)<!-- -->

``` r
cwe_densities <- crimes19_sf %>%
  filter(neighborhood == 38) %>%
  smooth_map(., bandwidth = 0.5, style = "pretty",
  cover = cwe)
```

    ## 
      |                                                                       
      |                                                                 |   0%
      |                                                                       
      |======                                                           |  10%
      |                                                                       
      |====================                                             |  30%
      |                                                                       
      |================================                                 |  50%
      |                                                                       
      |==============================================                   |  70%
      |                                                                       
      |==========================================================       |  90%
      |                                                                       
      |=================================================================| 100%

``` r
cwe_den_tm <- tm_shape(cwe_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 38) %>% 
  tm_shape() +
    tm_fill(col = NA, 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  tm_shape(cwe_densities$polygons) +
  tm_fill(col = "level", palette = "BuPu", alpha = .60, 
    title = expression("Crimes per " * km^2)) +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "CWE Crime Density- August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

cwe_den_tm
```

![](crime-data_files/figure-gfm/CWE%20Density%20Map%20Output-1.png)<!-- -->
\#\#\#\#\#\# Medical Campus

``` r
mc_crimes <- st_intersection(crimes19_sf, med_campus)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
cwe_mc_tm <- tm_shape(mc_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 38) %>% 
  tm_shape() +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  tm_shape(med_campus) +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 1, 
               lty = "solid") +
  tm_shape(mc_crimes) +
    tm_bubbles(size = .25, 
               col = "crimeCatName", 
               palette = "Set1", 
               title.col = "Part 1 Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "Med. Campus Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

cwe_mc_tm
```

![](crime-data_files/figure-gfm/Medical%20Campus%20Total%20Crime-1.png)<!-- -->
\#\#\#\#\#\# Cortex

``` r
ctx_crimes <- st_intersection(crimes19_sf, cortex)
```

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
cwe_ctx_tm <- tm_shape(ctx_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 38) %>% 
  tm_shape() +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  tm_shape(cortex) +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 1, 
               lty = "solid") +
  tm_shape(ctx_crimes) +
    tm_bubbles(size = .25, 
               col = "crimeCatName", 
               palette = "Set1", 
               title.col = "Part 1 Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "Cortex Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

cwe_ctx_tm
```

![](crime-data_files/figure-gfm/Cortex%20Total%20Crime-1.png)<!-- -->

##### Botanical Heights

``` r
bot_total_tm <- tm_shape(bot_tiles) +
  tm_rgb() +
  nhoods_sf %>%
  filter(., neighborhood == 28) %>% 
  tm_shape() +
    tm_fill(col = "#9ecae1", 
            alpha = .5) +
    tm_borders(col = "black", 
               lwd = 2, 
               lty = "dashed") +
  filter(crimes19_sf, 
         neighborhood == 28) %>%
  tm_shape() +
    tm_bubbles(size = .25, 
               col = "crimeCatName", 
               palette = "Set1", 
               title.col = "Part 1 Crimes") +
  tm_credits("© Mapbox, © OpenStreetMap", position = c("left", "BOTTOM")) +
  tm_layout(
    main.title = "Botanical Heights Total Crime - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

bot_total_tm
```

![](crime-data_files/figure-gfm/Botanical%20Heights%20Total%20Crime-1.png)<!-- -->

##### District 2 Density Maps

``` r
dst2_rateMap <- tm_shape(dst2_tiles) +
  tm_rgb() +
  tm_shape(dst_2_pop) +
  tm_polygons(col = "crimeRate",
              palette = "BuPu",
              style = "jenks",
              title = "Crimes per 1,000 Residents") +
  tm_text("neighborhood", shadow=TRUE) +
  tm_layout(
    main.title = "District 2 Crime Rates - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

dst2_rateMap
```

![](crime-data_files/figure-gfm/Generate%20District%202%20Density%20Maps-1.png)<!-- -->

``` r
dst5_rateMap <- tm_shape(dst5_tiles) +
  tm_rgb() +
  tm_shape(dst_5_pop) +
  tm_polygons(col = "crimeRate",
              palette = "BuPu",
              style = "jenks",
              title = "Crimes per 1,000 Residents") +
  tm_text("neighborhood", shadow=TRUE) +
  tm_layout(
    main.title = "District 5 Crime Rates - August 2019",
    frame = FALSE,
    legend.bg.color = "white", 
    legend.frame=TRUE,
    legend.outside = TRUE,
    legend.position = c("right", "bottom")) 

dst5_rateMap
```

![](crime-data_files/figure-gfm/Generate%20District%205%20Density%20Maps-1.png)<!-- -->
\#\#\# Save Maps

### Clean Workspace

``` r
rm(fpse_total_tm, fpse_dn_tm, fpse_vlnt_tm, fpse_den_tm, fpse_grove_tm, cwe_total_tm, cwe_dn_tm, cwe_vlnt_tm, cwe_den_tm, cwe_mc_tm, cwe_ctx_tm, bot_total_tm, fpse_tiles, cwe_tiles, bot_tiles, mc_tiles, ctx_tiles, grv_tiles, dst_2, dst_5, dst2_tiles, dst5_tiles)
```

## Tables

``` r
tidyCrimes19 %>% 
  filter(., neighborhood == 39) %>% 
  group_by(crimeCatName) %>% 
  count() %>% 
  rename(., "Number of Crimes" = n, "Part 1 Crimes" = crimeCatName) -> fpse_crimeCat

tidyCrimes19 %>% 
  filter(., neighborhood == 39) %>% 
  group_by(weekday) %>% 
  count() %>%
  rename(., "Number of Crimes" = n, "Day of the Week" = weekday) -> fpse_weekDay

tidyCrimes19 %>% 
  filter(., neighborhood == 39) %>% 
  group_by(violent) %>% 
  count() %>%
  rename(., "Number of Crimes" = n, "Crimes Against Persons" = violent) -> fpse_violent


tidyCrimes19 %>% 
  filter(., neighborhood == 39) %>% 
  group_by(dayNight) %>% 
  count() %>%
  rename(., "Number of Crimes" = n, "Time of Day" = dayNight) -> fpse_dayNight

tidyTotalCrimes18 %>% 
  filter(., neighborhood == 39) %>% 
  group_by(monthVar) %>% 
  count(crimeCatName) %>% 
  rename(., "Number of Crimes" = n) %>% 
  pivot_wider(names_from = monthVar, values_from = "Number of Crimes") %>% 
  replace(., is.na(.), 0) %>% 
  rename(., "January" = "01",
         "February" = "02",
         "March" = "03",
         "April" = "04",
         "May" = "05",
         "June" = "06",
         "July" = "07",
         "August" = "08",
         "September" = "09",
         "October" = "10",
         "November" = "11",
         "December" = "12") %>% 
  adorn_totals(., "col", name = "Total")-> fpse_2018

head(fpse_2018)
```

    ##         crimeCatName January February March April May June July August
    ##   Aggravated Assault       2        2     0     3   7    5    4      3
    ##             Homicide       1        0     0     0   0    0    0      0
    ##              Larceny       5        3     6     7  20    5   13     12
    ##  Motor Vehicle Theft       2        1     2     0   3    3    3      2
    ##             Burgalry       0        1     1     3   0    1    1      1
    ##                Arson       0        0     1     0   0    0    0      0
    ##  September October November December Total
    ##          1       7        0        3    37
    ##          0       0        0        0     1
    ##         14       9       10        3   107
    ##          2       2        2        2    24
    ##          0       1        0        0     9
    ##          0       0        0        0     1

``` r
kable(fpse_crimeCat) %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = F, position = "center")
```

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Part 1 Crimes

</th>

<th style="text-align:right;">

Number of Crimes

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Burgalry

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

Larceny

</td>

<td style="text-align:right;">

17

</td>

</tr>

<tr>

<td style="text-align:left;">

Motor Vehicle Theft

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

Robbery

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>
