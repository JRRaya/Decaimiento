library(sf)
library(dplyr)

# Cargar la capa vectorial
pinos_vec <- st_read("E:/SEGMENTACION/VARIABLES/E/pinos_recorte_incendios/pinos_rec.shp")

# Filtrar registros válidos (eliminar NA en la columna de especies)
pinos_vec <- filter(pinos_vec, !is.na(especie))

# Agrupar especies usando las mismas reglas
pinos_vec$especie <- case_when(
  grepl("^Pinus nigra", pinos_vec$especie) ~ "Pinus nigra",
  grepl("^Pinus pinaster", pinos_vec$especie) ~ "Pinus pinaster",
  TRUE ~ pinos_vec$especie
)

pinos_vec <- pinos_vec %>% select(-FID)

# Guardar la capa con las especies agrupadas
st_write(pinos_vec, 
         "E:/SEGMENTACION/VARIABLES/E/pinos_vec_agrupado/pinos_vec_agrupado.shp", 
         append = FALSE)