paquetes <- c("sf", "dplyr", "stringr", "tools")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'sf'
library(sf)
library(dplyr)
library(stringr)
library(tools)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta <- "E:/TFG/mapas_vegetacion/VEG10/VEG10.shp"
ruta_temp <- "E:/R/RTemp"
ruta_salida <- "E:/SEGMENTACION/VARIABLES/E/pinos_vec/"

# Comprobamos que existe el archivo
# La función stop() detiene la ejecución del script y muestra un mensaje de error
if (!file.exists(ruta)) {
  stop(paste("Archivo no encontrado:", ruta, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta)}

# Cargamos la capa de vegetación, y asignamos CRS si este no se detecta
vegetacion <- st_read(ruta) %>%
  select(D_ARBO1_SP)  # Seleccionamos la columna correspondiente a la especie arbórea dominante 1

# Establecemos el CRS de la capa (comprobandolo en QGIS) si R no lo detecta
if (is.na(st_crs(vegetacion))) {
  message("  CRS de raster_presencia indefinido. Asignando EPSG:25830")
  st_crs(vegetacion) <- "EPSG:25830" # Esto se comprobó empleando QGIS
}

# Comprobamos que se haya cargado adecuadamente
if (is.null(vegetacion)) {
  stop("No se pudo cargar la capa vectorial.")
} else {
  paste("Capa vectorial cargada correctamente:", ruta)
  }

# Filtramos los pinos
# Para ello, filtramos polígonos que contienen "pinus", "p." o "pin." en la columna de especies
# La expresión regular \\b asegura que se buscan palabras completas
pinos <- vegetacion %>%
  filter(str_detect(tolower(D_ARBO1_SP), "\\b(pinus|p\\.|pin\\.)\\b")) %>%
  mutate(especie = as.factor(D_ARBO1_SP)) %>%
  select(especie, geometry) # Mantener solo la columna de especie y la geometría

# Comprobamos el CRS y la geometría de la capa
print("Tipo de geometría antes de guardar:")
print(st_geometry_type(pinos))
print("CRS antes de guardar:")
print(st_crs(pinos))

# Exportamos el mapa de pinos
if (nrow(pinos) > 0) {
  message(paste("Exportando el mapa de pinos"))
  st_write(pinos,
           dsn = dirname(ruta_salida),
           layer = basename(file_path_sans_ext(ruta_salida)),
           driver = "ESRI Shapefile",
           delete_layer = TRUE, # Sobrescribe el archivo si ya existe
           quiet = FALSE) # Muestra mensajes sobre la escritura
} else { message(paste("La capa no contiene polígonos"))}
