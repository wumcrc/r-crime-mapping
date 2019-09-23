Forest Park Southeast, Botanical Heights, Central West End, Medical
Campus
================
Washington University Medical Center
(September 23, 2019)

## Summary Notes: FPSE August 2019

``` r
tc18 <- nrow(monthCrimes18[monthCrimes18$neighborhood == 39,])
tc19 <- nrow(monthCrimes19[monthCrimes19$neighborhood == 39,])
cap19 <- nrow(monthCrimes19[monthCrimes19$neighborhood == 39 & monthCrimes19$crimeCatNum == 4 | monthCrimes19$neighborhood == 39 & monthCrimes19$crimeCatNum == 3,])

pct_chg <- (tc19 - tc18)/tc18*100 
pct_chg <- round(pct_chg, digits = 2)

sprintf("%s Total Crimes in 2019", tc19)
```

    ## [1] "20 Total Crimes in 2019"

``` r
sprintf("%s Percent Change compared to August 2018 (%s Total Crimes)", pct_chg, tc18)
```

    ## [1] "11.11 Percent Change compared to August 2018 (18 Total Crimes)"
