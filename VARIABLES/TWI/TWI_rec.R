paquetes <- c("terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'terra' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta de la capa y la del directorio de los archivos temporales
ruta_TWI <- "E:/SEGMENTACION/VARIABLES/TWI/TWI_rem/TWI_rem.tif"
ruta_precipitacion <- "E:/SEGMENTACION/VARIABLES/P/P_YEARLY/precipitacion_rem/precipitacion_rem.tif"
ruta_temp <- "E:/R/RTemp"

# Cargamos las capas
precipitacion <- rast(ruta_precipitacion)
TWI <- rast(ruta_TWI)

#Remuestrear
TWI_rem <- resample(TWI, precipitacion)

# Recortar
TWI_rec <- mask(TWI_rem, precipitacion)

# Reemplazar valores NA por 9999
TWI_rec[is.na(TWI_rec)] <- 9999

# Guardar resultado
writeRaster(TWI_rec, 
            "E:/SEGMENTACION/VARIABLES/TWI/TWI_rec/TWI_rec.tif", 
            overwrite = TRUE, 
            NAflag = 9999,
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS")
)