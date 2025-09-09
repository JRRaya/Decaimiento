library(terra)

tau_largo <- rast("E:/INDICES/VI/NDVI_MAX/stack_1984_2024/kendall_1984_2024/tau_1984_2024.tif")
tau_corto <- rast("E:/INDICES/VI/NDVI_MAX/stack_2015_2024/kendall_2015_2024/tau_2015_2024.tif")
pinos <- rast("E:/SEGMENTACION/VARIABLES/E/pinos_rast/pinos_rast.tif")

crs_objetivo <- crs(pinos)

if (crs(tau_largo) != crs_objetivo) {
  tau_largo <- project(tau_largo, crs_objetivo)
}

if (crs(tau_corto) != crs_objetivo) {
  tau_corto <- project(tau_corto, crs_objetivo)
}

tau_l_rec <- mask(tau_largo, pinos)
writeRaster(tau_l_rec, 
            "E:/AUTOCORRELACION/tendencia/tendencia_10/mk_rec/tau_l_rec.tif", 
            overwrite = TRUE)

tau_c_rec <- mask(tau_corto, pinos)
writeRaster(tau_c_rec, 
            "E:/AUTOCORRELACION/tendencia/tendencia_10/mk_rec/tau_c_rec.tif", 
            overwrite = TRUE)