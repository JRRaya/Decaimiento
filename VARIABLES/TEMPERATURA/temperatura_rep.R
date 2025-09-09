terra <- c("terra")
inst_terra <- terra[!(terra %in% installed.packages()[, "Package"])]

# Descargamos 'terra' si no está instalado
if (length(inst_terra)) {install.packages(terra)}

# Cargamos el paquete 'terra'
library(terra)

# Establecemos la ruta del ráster y la del directorio de los archivos temporales
ruta <- "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_1984_2024/kendall_t_1984_2024/tau_t_1984_2024.tif"
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

# Comprobamos que se haya cargado adecuadamente
if (is.null(raster)) {
  stop("No se pudo cargar el raster.")
} else {paste("Ráster cargado correctamente:", ruta)}

# Primero, comprobasmos que exista el archivo en la ruta especificada empleando file.exists()
# Si la ruta es correcta, se ejecuta el código dentro de las primeras llaves
# En caso contrario, se ejecuta el mensaje de error y se detiene la ejecución del script
if (file.exists(ruta)) {
  message(paste("Inciando procesamiento de:", ruta))
  
  # Asignar CRS si está indefinido
  # Esto es conveniente ya que, a veces, R no detecta correctamente el CRS de la capa
  # Por ello, también es conveniente verificar el CRS de cada capa desde QGIS
  # Una vez comprobado, lo más comodo es definirlo directamente, para evitar errores de lectura
  # La función crs() obtiene o asigna el CRS de la capa. Con describe = TRUE devuelve una descripción más completa
  # La función is.na() es base de R y comprueba si el objeto o propiedad que se evalua
  # Si el resultado es NA, la condición se cumple (es TRUE), por lo que se ejecuta el proceso de asignación de CRS
  # En caso contrario, se obtiene y se muestra el CRS original de la capa
  if (is.na(crs(raster))) {
    message("  CRS de raster_presencia indefinido. Asignando EPSG:3345...")
    crs(raster) <- "EPSG:3345" # Esto se comprobó empleando QGIS
  }
  message(paste("  CRS original del ráster:", crs(raster, describe=TRUE)$name))
  
  # Reproyectar el ráster al CRS objetivo (EPSG:4326)
  # Comprobamos si el CRS de la capa es el mismo que el de referencia (objetivo)
  # En caso de que sean distintos, (condición TRUE, ya que especificamos la condición de que sean distintos) se reproyecta al CRS objetivo
  # Para ello, se emplea la función terra::project(), que reproyecta un  objeto espacial al CRS de otro objeto
  # Con el parámetro method definimos el método de reproyección (en este caso "bilinear")
  if (crs(raster) != ref_crs) {
    message(paste("  Reproyectando ráster", crs(raster, describe=TRUE)$name, "a", crs(ref_crs, describe=TRUE)$name, "..."))
    raster_rep <- project(raster, ref_crs, method = "bilinear")
  } else {
    raster_rep <- raster  # Se genera la variable raster_rep para contemplar ambos casos
    message("  Ráster ya está en el CRS objetivo.")
  }
  
} else {   # En caso de que el archivo no se encontrase en la ruta especificada
  stop(paste("Archivo ráster no encontrado:", ruta, "- Deteniendo el script.")) 
}

# Guardamos cada una de las capas
writeRaster(raster_rep, 
            "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_rep/temperatura_rep.tif", 
            overwrite = TRUE, 
            datatype = "FLT8S",
            gdal = c(
              "COMPRESS = DEFLATE",
              "PREDICTOR = 3",
              "BIGTIFF = YES",
              "TILED = YES",
              "NUM_THREADS = ALL_CPUS"  # Usar todos los núcleos disponibles
            ))