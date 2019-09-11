# Load Dependencies
library(compstatr)

# Load Index & Data
i <- cs_create_index()
june2018 <- cs_get_data(year = 2018, month = "june", index = i)

# add Categories
june2018 <- cs_filter_count(june2018, var = count)
june2018 <- cs_crime_cat(june2018, var = crime, crimeCatNum, "numeric")
june2018 <- cs_crime_cat(june2018, var = crime, crimeCatName, "string")

# subset rapes and removed unfounded incidents
juneRapes <- cs_filter_count(june2018, var = count)
juneRapes <- cs_filter_crime(juneRapes, var = crime, crime = "rape")



# View First Part of Object
juneRapes
