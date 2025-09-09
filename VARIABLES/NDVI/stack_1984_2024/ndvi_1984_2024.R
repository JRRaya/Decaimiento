# Configuración Inicial 
required_packages <- c("raster", "progressr", "future.apply")
new_packages <- required_packages[!required_packages %in% installed.packages()[, "Package"]]
if (length(new_packages)) install.packages(new_packages)

# Carga de librerías y configuración de progressr 
suppressPackageStartupMessages({
  library(raster)
  library(progressr)
  library(future.apply)
})
handlers(
  handler_progress(
    format = "[:bar] :percent (:current/:total) — :message",
    clear  = FALSE
  )
)

# Preparar Datos y Carga con Progreso 
setwd("E:/INDICES/VI/NDVI_MAX")
lista_imagenes <- list.files(pattern = "\\.tif$", full.names = TRUE)

with_progress({
  p_load <- progressor(steps = length(lista_imagenes))
  rasters_list <- future_lapply(
    lista_imagenes,
    function(f) {
      p_load(message = basename(f))
      raster(f)
    }
  )
})

# Construir un RasterStack manualmente 
st <- stack()
with_progress({
  p_stack <- progressor(steps = length(rasters_list))
  for (i in seq_along(rasters_list)) {
    st <- addLayer(st, rasters_list[[i]])
    p_stack(message = sprintf("Stack: %d/%d", i, length(rasters_list)))
  }
})

# Escribir multibanda a disco 
out_tmp <- "ndvi_1984_2024_tmp.tif"
writeRaster(
  st,
  filename  = out_tmp,
  format    = "GTiff",
  overwrite = TRUE,
  progress  = "text"
)

# Cargar el Brick ya escrito 
ndvis <- brick(out_tmp)

# Visualización y Exportación Final 
plot(ndvis)
writeRaster(
  ndvis,
  filename  = "E:/INDICES/VI/NDVI_MAX/stack_1984_2024/ndvi_1984_2024.tif",
  format    = "GTiff",
  overwrite = TRUE,
  progress  = "text"
)