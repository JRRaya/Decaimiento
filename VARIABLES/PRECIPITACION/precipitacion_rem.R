paquetes <- c("terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta_pinos <- "E:/SEGMENTACION/VARIABLES/E/pinos_rast_agrupado/pinos_rast_agrupado.tif"
ruta_precipitacion <- "E:/SEGMENTACION/VARIABLES/P/P_YEARLY/precipitacion_1984_2024/precipitacion_rep/precipitacion_rep.tif"
ruta_temp <- "E:/R/RTemp"

# Comprobamos que existen los archivos
if (!file.exists(ruta_pinos)) {
  stop(paste("Archivo no encontrado:", ruta_pinos, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_pinos)}
if (!file.exists(ruta_precipitacion)) {
  stop(paste("Archivo no encontrado:", ruta_precipitacion, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_precipitacion)}

# Cargamos las capas
pinos <- rast(ruta_pinos)
precipitacion <- rast(ruta_precipitacion)

# Remuestrear al grid (extensión y resolución) de la máscara de pinos
precipitacion_rem <- resample(precipitacion, pinos, method = "bilinear")

# Guardamos el resultado
writeRaster(precipitacion_rem, 
            "E:/SEGMENTACION/VARIABLES/P/P_YEARLY/precipitacion_1984_2024/precipitacion_rem/precipitacion_rem.tif", 
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))