paquetes <- c("terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta_pinos <- "E:/SEGMENTACION/VARIABLES/E/pinos_rast_agrupado/pinos_rast_agrupado.tif"
ruta_radiacion <- "E:/SEGMENTACION/VARIABLES/R/radiacion_rep/radiacion_rep.tif"
ruta_temp <- "E:/R/RTemp"

# Comprobamos que existen los archivos
if (!file.exists(ruta_pinos)) {
  stop(paste("Archivo no encontrado:", ruta_pinos, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_pinos)}
if (!file.exists(ruta_radiacion)) {
  stop(paste("Archivo no encontrado:", ruta_radiacion, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_radiacion)}

# Cargamos las capas
pinos <- rast(ruta_pinos)
radiacion <- rast(ruta_radiacion)

# Remuestrear al grid (extensión y resolución) de la máscara de pinos
radiacion_rem <- resample(radiacion, pinos, method = "bilinear")

# Guardamos el resultado
writeRaster(radiacion_rem, 
            "E:/SEGMENTACION/VARIABLES/R/radiacion_rem/radiacion_rem.tif",
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))