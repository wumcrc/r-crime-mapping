# Tiles from Mapbox 

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

cwe_tiles <- raster::extent(xycwe) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

bot_tiles <- raster::extent(xybot) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)

dbp_tiles <- raster::extent(xydbp) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

sdb_tiles <- raster::extent(xysdb) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)

we_tiles <- raster::extent(xywe) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

vp_tiles <- raster::extent(xyvp) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)

ac_tiles <- raster::extent(xyac) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

fp_tiles <- raster::extent(xyfp) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

lp_tiles <- raster::extent(xylp) %>%
  cc_location(., type = "mapbox.streets", max_tiles = 15)

vd_tiles <- raster::extent(xyvd) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

mc_tiles <- raster::extent(xymc) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

ctx_tiles <- raster::extent(xyctx) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

grv_tiles <- raster::extent(xygrv) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

dst2_tiles <- raster::extent(xydst2) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

dst5_tiles <- raster::extent(xydst5) %>% 
  cc_location(., type = "mapbox.streets", max_tiles = 15)

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
