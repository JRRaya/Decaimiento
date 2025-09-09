library(sf)

paquetes <- c("sf")
inst_paquetes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

# Descargamos 'sf' si no está instalado
if (length(inst_paquetes)) {install.packages(inst_paquetes)}

# Cargamos el paquete 'sf'
library(sf)

# Establecemos la ruta de la capa vectorial y la del directorio de los archivos temporales
ruta <- "E:/SEGMENTACION/VARIABLES/E/incendios/incendios_historico_2023_06.shp"
ruta_temp <- "E:/R/RTemp"

# Cargamos la capa de incendios
incendios <- st_read(ruta, quiet = FALSE)

# Aplicamos un buffer con una distancia mínima para corregir inconsistencias
incendios <- st_make_valid(incendios) %>%
  st_buffer(dist = 0.000001)

# Comprobamos si aún persistenten las inconsistencias
# Necesario para poder aplicar la unión posterior
st_is_valid(incendios)

# Creamos un objeto multipolígono a partir de todos los parches donde se hayan producido incendios
incendios <- st_union(incendios)

# Guardamos la capa corregida
st_write(incendios,
         dsn = "E:/SEGMENTACION/VARIABLES/E/incendios_cor/",                  
         layer = sub("\\.shp$", "", "incendios_cor"),
         driver = "ESRI Shapefile",
         delete_layer = TRUE,                  # Sobrescribe si ya existe
         quiet = FALSE)
