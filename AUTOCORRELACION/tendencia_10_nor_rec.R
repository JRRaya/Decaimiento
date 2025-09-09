library(terra)

# Cargar ráster
r <- rast("E:/AUTOCORRELACION/tendencia/tendencia_10/tendencia_10_nor/tendencia_10_nor.tif")

# Reclasificación por intervalos de valores
m <- matrix(c(
  -Inf, -0.4, 1,    # Muy negativo
  -0.4, -0.2, 2,    # Negativo
  -0.2, 0.2, 3,     # Neutro
  0.2, 0.4, 4,      # Positivo
  0.4, Inf, 5       # Muy positivo
), ncol = 3, byrow = TRUE)

r_reclasificado <- classify(r, m, include.lowest = TRUE)

# Visualización del ráster reclasificado
colores <- c("#313695", "#74ADD1", "#FFFFCC", "#F46D43", "#A50026")
plot(r_reclasificado, col = colores, type = "classes", 
     main = "Diferencias reclasificadas entre tendencias",
     xlab = "Longitud", ylab = "Latitud")

# Guardar
writeRaster(r_reclasificado, 
            "E:/AUTOCORRELACION/tendencia/tendencia_10/tendencia_10_nor/tendencia_10_nor_rec/tendencia_10_nor_rec.tif", 
            overwrite = TRUE)