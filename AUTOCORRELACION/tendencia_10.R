library(terra)
library(RColorBrewer)
library(ggplot2)

# --- CARGA DE RÁSTERES ---
# NDVI tendencias: tau de Kendall largo plazo (41 años) y corto plazo (3 años)
tau_largo <- rast("E:/INDICES/VI/NDVI_MAX/stack_1984_2024/kendall_1984_2024/tau_1984_2024.tif")
tau_corto <- rast("E:/INDICES/VI/NDVI_MAX/stack_2015_2024/kendall_2015_2024/tau_2015_2024.tif")

# Capa de especies de pino (valores 0 a 12)
especies <- rast("E:/SEGMENTACION/VARIABLES/E/pinos_rast/pinos_rast.tif")
especies <- as.numeric(especies)

# Asegurar mismo CRS entre capas usando terra
crs_objetivo <- crs(especies)  # CRS de la capa de especies

# Reproyectar si el CRS no coincide
if (crs(tau_largo) != crs_objetivo) {
  tau_largo <- project(tau_largo, crs_objetivo)
}

if (crs(tau_corto) != crs_objetivo) {
  tau_corto <- project(tau_corto, crs_objetivo)
}

# --- ALINEAR Y RECORTAR TODAS LAS CAPAS ---
# Reproyectamos y recortamos todo al mismo marco de referencia y resolución
# Tomamos como referencia la capa de especies
tau_largo <- resample(tau_largo, especies, method = "bilinear")
tau_corto <- resample(tau_corto, especies, method = "bilinear")

# --- CALCULAR DIFERENCIA ABSOLUTA DIRECTAMENTE ---
# Calculamos la diferencia absoluta píxel por píxel
diferencia_absoluta <- (tau_corto - tau_largo)

# Aplicamos la máscara de especies para mantener solo píxeles con especies válidas
diferencia_absoluta <- mask(diferencia_absoluta, especies)

# --- VISUALIZACIÓN DEL RESULTADO FINAL ---
# Crear una paleta de colores continua
n_colores <- 100
colores <- colorRampPalette(c("blue", "cyan", "yellow", "orange", "red"))(n_colores)

plot(diferencia_absoluta, col = colores, 
     main = "Diferencia absoluta entre tendencias (corto vs largo plazo)",
     xlab = "Longitud", ylab = "Latitud")

# --- OPCIONAL: ESTADÍSTICAS DESCRIPTIVAS ---
print("Estadísticas de la diferencia absoluta:")
print(summary(diferencia_absoluta))

# Histograma de valores
hist(diferencia_absoluta,
     breaks = 50,
     main = "Distribución de diferencias absolutas",
     xlab = "Diferencia absoluta (tau corto - tau largo)",
     ylab = "Frecuencia",
     col = "lightblue",
     border = "black")

# --- PREPARAR DATOS PARA GGPLOT2 ---
vals <- values(diferencia_absoluta)
vals <- vals[!is.na(vals)]
datos_df <- data.frame(diferencia = vals)

# --- GUARDAR GRÁFICOS ---
# Histograma
png("E:/AUTOCORRELACION/tendencia/tendencia_10/h_tendencia_10.png", 
    width = 800, height = 600, res = 150)
hist(diferencia_absoluta, breaks = 30,
     main = "Distribución de diferencias",
     xlab = "Diferencia (tau corto - tau largo)",
     ylab = "Frecuencia", col = "lightblue", border = "black")
dev.off()

# Gráfico de densidad
p_densidad <- ggplot(datos_df, aes(x = diferencia)) +
  geom_density(fill = "lightblue", alpha = 0.7, color = "darkblue") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Distribución de densidad - Diferencias",
       x = "Diferencia (tau corto - tau largo)",
       y = "Densidad") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("E:/AUTOCORRELACION/tendencia/tendencia_10/d_tendencia_10.png", 
       plot = p_densidad, width = 8, height = 6, dpi = 150)

# Gráfico combinado
p_combinado <- ggplot(datos_df, aes(x = diferencia)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, 
                 fill = "lightblue", alpha = 0.6, color = "darkblue") +
  geom_density(color = "red", alpha = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Distribución combinada: Histograma + Densidad",
       subtitle = "Diferencias (tau corto - tau largo)",
       x = "Diferencia (tau corto - tau largo)",
       y = "Densidad") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12))

ggsave("E:/AUTOCORRELACION/tendencia/tendencia_10/hd_tendencia_10.png", 
       plot = p_combinado, width = 10, height = 7, dpi = 150)

print(p_densidad)
print(p_combinado)

# --- GUARDAR RÁSTER ---
writeRaster(diferencia_absoluta, 
            "E:/AUTOCORRELACION/tendencia/tendencia_10/tendencia_10.tif", 
            overwrite = TRUE)