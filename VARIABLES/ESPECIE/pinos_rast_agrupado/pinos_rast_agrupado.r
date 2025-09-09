library(terra)
library(dplyr)

# Cargar el ráster
pinos_rast <- rast("E:/SEGMENTACION/VARIABLES/E/pinos_rast/pinos_rast.tif")

# Convertir a data.frame
df <- as.data.frame(pinos_rast, xy = TRUE)
df <- filter(df, !is.na(df[[3]]))

# Agrupar especies
df$especie <- case_when(
  grepl("^Pinus nigra", df$especie) ~ "Pinus nigra",
  grepl("^Pinus pinaster", df$especie) ~ "Pinus pinaster",
  TRUE ~ df$especie
)

# Crear códigos numéricos para las especies
especies_unicas <- unique(df$especie)
df$codigo <- match(df$especie, especies_unicas)

# Guardar tabla de correspondencia
tabla_correspondencia <- data.frame(
  codigo = 1:length(especies_unicas),
  especie = especies_unicas
)
write.csv(tabla_correspondencia, "E:/SEGMENTACION/VARIABLES/E/pinos_rast_agrupado/correspondencia_especies.csv", row.names = FALSE)

# Crear nuevo ráster con códigos
pinos_agrupado <- rast(pinos_rast)
values(pinos_agrupado) <- NA
pinos_agrupado[cellFromXY(pinos_agrupado, df[,1:2])] <- df$codigo

# Guardar
writeRaster(pinos_agrupado, 
            "E:/SEGMENTACION/VARIABLES/E/pinos_rast_agrupado/pinos_rast_agrupado.tif", 
            overwrite = TRUE)