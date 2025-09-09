# Carga de librerías necesarias 
required_packages <- c("raster", "Kendall", "snow", "parallel")
new_packages <- required_packages[!required_packages %in% installed.packages()[, "Package"]]
if (length(new_packages)) install.packages(new_packages)

suppressPackageStartupMessages({
  library(raster)
  library(Kendall)
  library(snow)
  library(parallel)
})

# Análisis de Tendencias (Mann–Kendall) 
ndvis <- brick("E:/INDICES/VI/NDVI_MAX/stack_1984_2024/ndvi_1984_2024.tif")  

fun_k <- function(x) {
  x <- na.omit(x)
  if (length(x) < 2) return(c(tau = NA, sl = NA))
  mk <- MannKendall(x)
  c(tau = mk$tau, sl = mk$sl)
}

beginCluster(n = 4)
kendall_result <- clusterR(
  ndvis,
  calc,
  args   = list(fun = fun_k),
  export = "fun_k",
  progress = "text"
)
endCluster()

# Exportación de Resultados y Limpieza 
names(kendall_result) <- c("tau", "sl")

tau_layer <- kendall_result[["tau"]]
sl_layer  <- kendall_result[["sl"]]

writeRaster(
  tau_layer,
  filename  = "E:/INDICES/VI/NDVI_MAX/stack_1984_2024/kendall_1984_2024/tau_1984_2024.tif",
  format    = "GTiff",
  overwrite = TRUE,
  progress  = "text"
)

# Arreglo estructural para sl
sl_layer_fixed <- raster(ndvis)
values(sl_layer_fixed) <- values(sl_layer)
names(sl_layer_fixed) <- "sl"

writeRaster(
  sl_layer_fixed,
  filename  = "E:/INDICES/VI/NDVI_MAX/stack_1984_2024/kendall_1984_2024/sl_1984_2024.tif",
  format    = "GTiff",
  overwrite = TRUE,
  progress  = "text"
)

# Exportación completa multibanda
writeRaster(
  kendall_result,
  filename  = "E:/INDICES/VI/NDVI_MAX/stack_1984_2024/kendall_1984_2024/complete_1984_2024.tif",
  format    = "GTiff",
  overwrite = TRUE,
  progress  = "text"
)

# Limpiar temporales
removeTmpFiles(h = 0)