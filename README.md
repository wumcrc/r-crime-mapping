# UPDATE

**The code for our automated monthly crime reports is now located here: <https://github.com/wumcrc/monthly-crime-reports>.**

## R Crime Mapping - St. Louis neighborhoods

This repository provides code for the analysis and visualization of SLMPD Crime Data at the multi-year level, and creates an output of historical crime data that can be analyzed in excel.

## About SLMPD Crime Data

The original source of the crime data is found here: <http://slmpd.org/crimereports.shtml>. If you have questions regarding the crime data visit <http://slmpd.org/Crime/CrimeDataFrequentlyAskedQuestions.pdf>.

In it's original form, the St. Louis Metropolitan Police Department (SLMPD) crime data can be downloaded as a `csv` file. The raw data can be challenging to work with. In an effort to simplify & reduce the time it takes to compile our reports, `r`, `tidyverse`, and `compstatr` are all packages that streamline and help our process.

## Acknowledgements

[`compstatr`](https://slu-opengis.github.io/compstatr/index.html) was developed by [Christopher Prener, Ph.D.](https://chris-prener.github.io/) & the [SLU Data Science Seminar openGIS Project](https://github.com/slu-openGIS). This automation would not be possible without the `compstatr` package.

## Repository Contents

*   `/src` - Base Files and Rendered Files for the __r-crime-mapping__ project.
*   `/src/multi-year-analysis`
*   `/src/r-historic-data`
*   `LICENSE`
*   `README`

### About Washington University Medical Center Redevelopment Corporation

**WUMCRC** is a partnership between **BJC HealthCare** and **Washington University School of Medicine**, working to improve the quality of life for the neighborhoods surrounding the medical campus. In order to achieve this goal in **Forest Park Southeast** and the **Central West End**, **WUMCRC** has invested millions of dollars toward regenerating the market for private investment in businesses and real estate, enhancing human and social service opportunities, and improving the level of physical and personal security.

**WUMCRC** fosters public-private partnerships to strengthen the **Forest Park Southeast** and **Central West End** neighborhoods by facilitating measures to improve security, promoting the development of diverse housing options, enhancing the lives of residents by implementing human and social service initiatives and enriching neighborhoods with infrastructure upgrades and beautification measures. Security, housing, social service provision and physical infrastructure allow for the cultivation of economic development to ensure the long-term vitality of the **Central West End** and **Forest Park Southeast** neighborhoods.
