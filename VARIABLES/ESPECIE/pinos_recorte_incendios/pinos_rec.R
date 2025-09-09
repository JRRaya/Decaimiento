paquetes <- c("sf")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'sf'
library(sf)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta_pinos <- "E:/SEGMENTACION/VARIABLES/E/pinos_vec_rep/pinos_vec_rep.shp"
ruta_incendios <- "E:/SEGMENTACION/VARIABLES/E/incendios_rep/incendios_rep.shp"
ruta_temp <- "E:/R/RTemp"

# Comprobamos que existen los archivos
if (!file.exists(ruta_pinos)) {
  stop(paste("Archivo no encontrado:", ruta_pinos, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_pinos)}
if (!file.exists(ruta_incendios)) {
  stop(paste("Archivo no encontrado:", ruta_incendios, "- Deteniendo el script."))
} else {paste("Archivo encontrado:", ruta_incendios)}

# Cargamos las capas
pinos <- st_read(ruta_pinos, quiet = FALSE)
incendios <- st_read(ruta_incendios, quiet = FALSE)

# Comprobamos la validez geométrica de las capas:
all(st_is_valid(pinos))
st_is_valid(incendios)

# Realizamos el recorte con st_difference()
pinos_rec <- st_difference(pinos, incendios)

#Comprobamos la calidez de las geometrías
all(st_is_valid(pinos_rec))

# Guardamos el resultado
if (all(st_is_valid(pinos_rec))) {
  st_write(pinos_rec,
           dsn = "E:/SEGMENTACION/VARIABLES/E/pinos/",                  
           layer = sub("\\.shp$", "", "pinos"),
           driver = "ESRI Shapefile",
           delete_layer = TRUE,                  # Sobrescribe si ya existe
           quiet = FALSE)
} else {paste("La capa contiene geometrías inválidas")}