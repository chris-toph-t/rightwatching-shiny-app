#expiremting with spatial interpolation 

library(librarian)
shelf(sf, doParallel, dplyr, kknn, foreach, lib = lib_paths()[1])

etrs <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

st_crs(kreise) <- 4326
kreise %>%
  st_transform(etrs) -> kreise

historic_filtered %>%
  filter(nsdap_percent_33 < 100) %>%
  st_as_sf(coords = c("lat", "lon"), crs = etrs) %>%
  st_transform(etrs) -> historic_filtered


land <- kreise %>%
  group_by(CNTR_CODE) %>% 
  summarize()



alt_grd_template_sf <- land %>% 
  st_bbox() %>% 
  st_as_sfc() %>% 
  st_make_grid(
    cellsize = c(1000, 1000),
    what = "centers"
  ) %>%
  st_as_sf() %>%
  cbind(., st_coordinates(.)) %>% 
  st_drop_geometry() %>% 
  mutate(Z = 0)


alt_grd_template_raster <- alt_grd_template_sf %>% 
  raster::rasterFromXYZ(
    crs = etrs
  )

fit_NN <- gstat::gstat( # using package {gstat} 
  formula = NH4 ~ 1,    # The column `NH4` is what we are interested in
  data = as(historic_filtered, "Spatial"), # using {sf} and converting to {sp}, which is expected
  nmax = 10, nmin = 3 # Number of neighboring observations used for the fit
)

interp_nn <- raster::interpolate(alt_grd_template_raster, fit_NN)


tmap_mode("view")

tm_shape(interp_nn) + 
  tm_raster(col = "var1.pred")


ggplot() + 
  geom_raster(data=land_raster, 
              aes(x=lon, y=lat, 
                  fill=votes))
