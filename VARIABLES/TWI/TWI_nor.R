# Cargamos el paquete necesario
library(terra)

# Cargamos el r?ster de la variable
raster <- rast("E:/SEGMENTACION/VARIABLES/TWI/TWI_rep/TWI_rep.tif")

# Establecemos el nuevo m?nimo y m?ximo
# Tamb?n establecemos el m?ximo y m?nimo originales
min <- min(values(raster), na.rm = TRUE)
max <- max(values(raster), na.rm = TRUE)

# Creamos la funci?n de normalizaci?n
nor <- function(x) {
  ((x - min) / (max - min)) * (1 - 0) + 0
}

# Normalizamos el r?ster
raster_nor <- nor(raster)

# Guardamos el resultado
writeRaster(raster_nor,
            "E:/SEGMENTACION/VARIABLES/TWI/TWI_nor/TWI_nor.tif",
            overwrite = TRUE)