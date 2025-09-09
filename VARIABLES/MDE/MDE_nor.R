# Cargamos el paquete necesario
library(terra)

# Cargamos el ráster de la variable
raster <- rast("E:/SEGMENTACION/VARIABLES/MDE/MDE.tif")

# Establecemos el nuevo mínimo y máximo
# Tambín establecemos el máximo y mínimo originales
min <- min(values(raster), na.rm = TRUE)
max <- max(values(raster), na.rm = TRUE)

# Creamos la función de normalización
nor <- function(x) {
  ((x - min) / (max - min)) * (1 - 0) + 0
}

# Normalizamos el ráster
raster_nor <- nor(raster)

# Guardamos el resultado
writeRaster(raster_nor,
            "E:/SEGMENTACION/VARIABLES/MDE/MDE_nor/MDE_nor.tif",
            overwrite = TRUE)