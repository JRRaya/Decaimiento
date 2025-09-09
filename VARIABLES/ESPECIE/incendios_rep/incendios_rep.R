paquetes <- c("sf")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'sf'
library(sf)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta <- "E:/SEGMENTACION/VARIABLES/E/incendios_cor/incendios_cor.shp"
ruta_temp <- "E:/R/RTemp"

# CRS objetivo final: EPSG:4326
ref_crs_epsg <- "EPSG:4326"  # CRS generico
ref_crs <- st_crs(ref_crs_epsg)  # Con la función sf::st_crs() lo convertimos a un formato que sf pueda interpretar

# Comprobamos que existe el archivo
# La función stop() detiene la ejecución del script y muestra un mensaje de error
if (!file.exists(ruta)) {
  stop(paste("Archivo no encontrado:", ruta, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta)}

# Cargamos la capa de incendios
incendios <- st_read(ruta, quiet = FALSE)

# Comprobamos que se haya cargado adecuadamente
if (is.null(incendios)) {
  stop("No se pudo cargar la capa vectorial.")
} else {paste("Capa vectorial cargada correctamente:", ruta)}

# Asignamos el CRS de la capa (EPSG:3042, que se ha comprobado en QGIS) si R no lo detecta
# Primero, comprobasmos que exista el archivo en la ruta especificada empleando file.exists()
# Si la ruta es correcta, se ejecuta el código dentro de las primeras llaves
# En caso contrario, se ejecuta el mensaje de error y se detiene la ejecución del script
if (file.exists(ruta)) {
  message(paste("Inciando procesamiento de:", ruta))
  
  # Asignar CRS si está indefinido
  # Esto es conveniente ya que, a veces, R no detecta correctamente el CRS de la capa
  # Por ello, también es conveniente verificar el CRS de cada capa desde QGIS
  # Una vez comprobado, lo más comodo es definirlo directamente, para evitar errores de lectura
  # La función st_crs() obtiene o asigna el CRS de la capa. Con describe = TRUE devuelve una descripción más completa
  # La función is.na() es base de R y comprueba si el objeto o propiedad que se evalua
  # Si el resultado es NA, la condición se cumple (es TRUE), por lo que se ejecuta el proceso de asignación de CRS
  # En caso contrario, se obtiene y se muestra el CRS original de la capa
  if (is.na(st_crs(incendios))) {
    message("  CRS de la capa indefinido. Asignando EPSG:3042...")
    st_crs(incendios) <- "EPSG:3042" # Esto se comprobó empleando QGIS
  }
  message(paste("  CRS original de la capa:", st_crs(incendios, parameters=TRUE)$proj4string))
  
  # Reproyectar el ráster al CRS objetivo (EPSG:4326)
  # Comprobamos si el CRS de la capa es el mismo que el de referencia (objetivo)
  # En caso de que sean distintos, (condición TRUE, ya que especificamos la condición de que sean distintos) se reproyecta al CRS objetivo
  # Para ello, se emplea la función sf::st_transform(), que reproyecta un  objeto espacial al CRS de otro objeto
  if (st_crs(incendios) != ref_crs) {
    message(paste("  Reproyectando capa a", st_crs(ref_crs, parameters=TRUE)$proj4string, "..."))
    incendios_rep <- st_transform(incendios, crs = ref_crs)
  } else {
    incendios_rep <- incendios  # Se genera la variable raster_rep para contemplar ambos casos
    message("  La capa ya está en el CRS objetivo.")
  }
  
} else {   # En caso de que el archivo no se encontrase en la ruta especificada
  stop(paste("Archivo no encontrado:", ruta, "- Deteniendo el script.")) 
}

# Corregimos inconsistencias
incendios_rep <- st_make_valid(incendios_rep)

# Comprobamos si contiene inconsistencias tras reproyeccion
st_is_valid(incendios_rep)

# Exportamos la capa vectorial
if (nrow(incendios_rep) > 0 && st_is_valid(incendios_rep) == TRUE) {
  message(paste("Exportando el mapa de incendios"))
  st_write(incendios_rep,
           dsn = "E:/SEGMENTACION/VARIABLES/E/incendios_rep/",                  
           layer = sub("\\.shp$", "", "incendios_rep"),
           driver = "ESRI Shapefile",
           delete_layer = TRUE,                  # Sobrescribe si ya existe
           quiet = FALSE)
} else { message(paste("La capa no contiene polígonos o contiene geometrías inválidas"))}