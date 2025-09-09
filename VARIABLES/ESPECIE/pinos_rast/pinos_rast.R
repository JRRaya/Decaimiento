paquetes <- c("sf", "terra")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'sf'
library(sf)
library(terra)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta_pinos <- "E:/SEGMENTACION/VARIABLES/E/pinos/pinos.shp"
ruta_ndvi <- "E:/SEGMENTACION/VARIABLES/E/ndvi_rep/ndvi_rep.tif"
ruta_temp <- "E:/R/RTemp"

# Comprobamos que existen los archivos
if (!file.exists(ruta_pinos)) {
  stop(paste("Archivo no encontrado:", ruta_pinos, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_pinos)}
if (!file.exists(ruta_ndvi)) {
  stop(paste("Archivo no encontrado:", ruta_ndvi, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_ndvi)}

# Cargamos las capas
pinos <- st_read(ruta_pinos, quiet = FALSE)
pinos <- vect(pinos) # Lo convertimos a un objeto SpatVector que terra pueda interpretar
ndvi <- rast(ruta_ndvi)

# Rasterizamos la capa de pinos a partir de la de ndvi (que toma como plantilla la función rasterize())
pinos_rast <- rasterize(pinos, ndvi, field = "especie")

# Guardamos el resultado
writeRaster(pinos_rast, 
            "E:/SEGMENTACION/VARIABLES/E/pinos_rast/pinos_rast.tif", 
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))