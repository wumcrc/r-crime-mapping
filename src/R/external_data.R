# Load Dependencies

library(readxl)
library(here)

# Read in Neighborhood Population Data

here()
nbhd_pop10 <- read_xlsx(here("data/external/nbhd_pop10.xlsx")) %>% 
  rename(neighborhood = nbhdNum)

#Save as R Data File


save(nbhd_pop10, file = "data/nbhd_pop10.rda")
