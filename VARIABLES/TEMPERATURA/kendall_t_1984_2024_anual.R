# Carga de librerías
library(raster)
library(Kendall)

# Cargar datos
ndvis <- brick("E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_1984_2024/temperatura_1984_2024.tif")

# Función Mann-Kendall
fun_k <- function(x) {
  x <- na.omit(x)
  if (length(x) < 3) return(c(tau = NA, sl = NA))
  mk <- MannKendall(x)
  c(tau = mk$tau, sl = mk$sl)
}

# Análisis
kendall_result <- calc(ndvis, fun = fun_k)
names(kendall_result) <- c("tau", "sl")

# Extraer capas
tau_layer <- kendall_result[["tau"]]
sl_layer <- kendall_result[["sl"]]

# Exportar tau
writeRaster(
  tau_layer,
  filename = "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_1984_2024/kendall_t_1984_2024/tau_t_1984_2024.tif",
  format = "GTiff",
  overwrite = TRUE
)

# Exportar sl
sl_layer_fixed <- raster(ndvis)
values(sl_layer_fixed) <- values(sl_layer)
writeRaster(
  sl_layer_fixed,
  filename = "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_1984_2024/kendall_t_1984_2024/sl_t_1984_2024.tif",
  format = "GTiff",
  overwrite = TRUE
)

# Exportar completo
writeRaster(
  kendall_result,
  filename = "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_1984_2024/kendall_t_1984_2024/complete_t_1984_2024.tif",
  format = "GTiff",
  overwrite = TRUE
)

# Limpiar temporales
removeTmpFiles(h = 0)