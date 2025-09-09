terra <- c("terra")
inst_terra <- terra[!(terra %in% installed.packages()[, "Package"])]

# Descargamos 'terra' si no está instalado
if (length(inst_terra)) {install.packages(terra)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta del ráster y la del directorio de los archivos temporales
ruta <- "E:/SEGMENTACION/VARIABLES/TWI/TWI_Final_5m.tif"
ruta_temp <- "E:/R/RTemp"

# Configuración para el paquete 'terra'.
terraOptions(
  todisk = TRUE,       # Obliga a terra a usar el disco para operaciones intermedias grandes (previene errores de memoria)
  tempdir = ruta_temp, # Dirige los temporales de terra al mismo lugar
  progress = 2         # Controla la barra de progreso (0=ninguno, 1=por defecto, 2=detallado)
)

# CRS objetivo final: EPSG:4326
ref_crs_epsg <- "EPSG:4326"  # CRS generico
ref_crs <- crs(ref_crs_epsg)  # Con la función terra::crs() lo convertimos a un formato que terra pueda interpretar

# Comprobamos que existe el archivo
# La función stop() detiene la ejecución del script y muestra un mensaje de error
if (!file.exists(ruta)) {
  stop(paste("Archivo ráster no encontrado:", ruta, "- Deteniendo el script."))
} else {paste("Archivo ráster encontrado:", ruta)}

# Cargamos el ráster
# terra::rast() lee el archivo y lo carga como un objeto SpatRast de terra
raster <- rast(ruta)

#Comprobamos que se haya cargado adecuadamente
if (is.null(raster)) {
  stop("No se pudo cargar el raster.")
} else {paste("Ráster cargado correctamente:", ruta)}

# Asignar CRS a la fuerza
# Ya que conoces el CRS real de la capa, lo asignas directamente
# sin importar si R lo detecta o no
crs(raster) <- "EPSG:25830" # Esto se comprobó empleando QGIS

# Reproyectar el ráster al CRS objetivo (EPSG:4326)
# Comprobamos si el CRS de la capa es el mismo que el de referencia (objetivo)
# En caso de que sean distintos, (condición TRUE, ya que especificamos la condición de que sean distintos) se reproyecta al CRS objetivo
# Para ello, se emplea la función terra::project(), que reproyecta un  objeto espacial al CRS de otro objeto
# Con el parámetro method definimos el método de reproyección (en este caso "bilinear")
if (!same.crs(raster, ref_crs)) {
  raster_rep <- project(raster, ref_crs, method = "bilinear")
} else {
  raster_rep <- raster  # Se genera la variable raster_rep para contemplar ambos casos
}

# Guardamos cada una de las capas
writeRaster(raster_rep, 
            "E:/SEGMENTACION/VARIABLES/TWI/TWI_rep/TWI_rep.tif", 
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))