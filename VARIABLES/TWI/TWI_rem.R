paquetes <- c("terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta_pinos <- "E:/SEGMENTACION/VARIABLES/E/pinos_rast/pinos_rast.tif"
ruta_TWI <- "E:/SEGMENTACION/VARIABLES/TWI/TWI_rep/TWI_rep.tif"
ruta_temp <- "E:/R/RTemp"

# Cargamos las capas
pinos <- rast(ruta_pinos)
TWI <- rast(ruta_TWI)

# Remuestrear al grid (extensión y resolución) de la máscara de pinos
TWI_rem <- resample(TWI, pinos, method = "bilinear")

# Guardamos el resultado
writeRaster(TWI_rem, 
            "E:/SEGMENTACION/VARIABLES/TWI/TWI_rem/TWI_rem.tif", 
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))