paquetes <- c("terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta_pinos <- "E:/SEGMENTACION/VARIABLES/E/pinos_rast_agrupado/pinos_rast_agrupado.tif"
ruta_temperatura <- "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_rep/temperatura_rep.tif"
ruta_temp <- "E:/R/RTemp"

# Comprobamos que existen los archivos
if (!file.exists(ruta_pinos)) {
  stop(paste("Archivo no encontrado:", ruta_pinos, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_pinos)}
if (!file.exists(ruta_temperatura)) {
  stop(paste("Archivo no encontrado:", ruta_temperatura, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_temperatura)}

# Cargamos las capas
pinos <- rast(ruta_pinos)
temperatura <- rast(ruta_temperatura)

# Creamos una plantilla para el resampleo
plantilla <- rast(extent = ext(pinos),
                  resolution = res(pinos),
                  crs = crs(pinos))

# Remuestrear al grid (extensión y resolución) de la máscara de pinos
temperatura_rem <- resample(temperatura, pinos, method = "bilinear")

# Guardamos el resultado
writeRaster(temperatura_rem, 
            "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_rem/temperatura_rem.tif", 
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))