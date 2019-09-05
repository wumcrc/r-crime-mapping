Saint Louis City Crime Data
================
Jes Stevens, M.A.
(September 05, 2019)

Introduction
------------

[Washington University Medical Center Redevelopment Corporation](http://wumcrc.com) is a partnership between BJC Health Care and Washington University School of Medicine and works to improve the quality of life for the neighborhoods surrounding the medical campus. In order to achieve this goal in Forest Park Southeast and the Central West End , WUMCRC has invested millions of dollars toward regenerating the market for private investment in businesses and real estate, enhancing human and social service opportunities, and improving the level of physical and personal security.

One way we work to improve the level of physical & personal security is the analysis and distribution of data. The original source of this crime data is <http://slmpd.org/crimereports.shtml>. This notebook uses primarily `compstatr` to access and clean the crime data.

R Markdown
----------

### Create an Index

``` r
i <- cs_create_index()
```

### Download Current Month

``` r
update <- cs_last_update()
update <- strsplit(update, " ")[[1]]
c_month <- update[[1]]
c_year <- as.numeric(update[[2]])
crimes <- cs_get_data(year = c_year, month = c_month, index = i)
```

### Clean & Categorize Data

`cs_filter_count` removes negative counts. Negative counts, -1, in the count column means that the crime, or charge in this specific observation has either been deemed unfounded, or the crime has been up coded. We do not want to map this data.

`cs_crime_cat` creates a variable with the names of the crime.

`cs_crime` creates a logic variable and codes violent crimes as `TRUE` and non-violent crimes as `FALSE`

`separate` creates multiple columns from the data in one column. In this case we use `separate` to split the date and time from the `date_occur` variable into two seperate `date` & `time` variables.

``` r
july19 <- crimes %>% 
  cs_filter_count(var = count) %>%
  cs_crime_cat(., var = crime, name, "string") %>%
  cs_crime(., var = crime, violent, "violent") %>%
  separate(., date_occur, c("date", "time"), " ", remove = FALSE)
```

### Time Code Data

``` r
july19$date <- as.Date(july19$date, "%m/%d/%Y")
july19$time <- strptime(july19$time, tz = "America/Chicago", "%H:%M")
july19$tod <- format(july19$time, format = "%H%M%S")

july19 <- mutate(july19, daynight = ifelse(tod >= "180000" & tod < "600000", "Night", "Day"))
```
