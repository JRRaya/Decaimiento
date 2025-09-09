paquetes <- c("terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'terra' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta de la capa y la del directorio de los archivos temporales
ruta_MDE <- "E:/SEGMENTACION/VARIABLES/MDE/MDE.tif"
ruta_precipitacion <- "E:/SEGMENTACION/VARIABLES/P/P_YEARLY/precipitacion_rem/precipitacion_rem.tif"
ruta_temp <- "E:/R/RTemp"

# Cargamos las capas
precipitacion <- rast(ruta_precipitacion)
MDE <- rast(ruta_MDE)

#Remuestrear
MDE_rem <- resample(MDE, precipitacion)

# Recortar
MDE_rec <- mask(MDE_rem, precipitacion)

# Reemplazar valores NA por 9999
MDE_rec[is.na(MDE_rec)] <- 9999

# Guardar resultado
writeRaster(MDE_rec, 
            "E:/SEGMENTACION/VARIABLES/MDE/MDE_rec/MDE_rec.tif", 
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