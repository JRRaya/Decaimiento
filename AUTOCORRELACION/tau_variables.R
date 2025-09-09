# 1. Cargamos las librerías necesarias
library(terra)
library(ggplot2)
library(dplyr)
library(tidyr)
library(openxlsx)
library(nortest)
library(rstatix)
library(effectsize)

# 2. Rutas de entrada y carga de la capa de recorte
rutas <- c(
  "E:/SEGMENTACION/VARIABLES/E/pinos_rast_agrupado/pinos_rast_agrupado.tif",
  "E:/SEGMENTACION/VARIABLES/MDE/MDE_rec/MDE_rec.tif",
  "E:/SEGMENTACION/VARIABLES/P/P_YEARLY/precipitacion_1984_2024/precipitacion_rep/precipitacion_rep.tif",
  "E:/SEGMENTACION/VARIABLES/T/T_MAX_ANUAL/temperatura_rep/temperatura_rep.tif",
  "E:/SEGMENTACION/VARIABLES/R/radiacion_rep/radiacion_rep.tif",
  "E:/SEGMENTACION/VARIABLES/TWI/TWI_rec/TWI_rec.tif",
  "E:/AUTOCORRELACION/tendencia/tendencia_10/tendencia_10.tif",
  "E:/AUTOCORRELACION/tendencia/tendencia_10/mk_rec/tau_c_rec.tif",
  "E:/AUTOCORRELACION/tendencia/tendencia_10/mk_rec/tau_l_rec.tif",
  "E:/AUTOCORRELACION/tendencia/tendencia_10/tendencia_10.tif"
)

vector <- vect("E:/SEGMENTACION/VARIABLES/E/pinos_recorte_incendios/pinos_rec.shp")

# 3. Definimos el nombre para cada uno de los ráster
nombres <- c(
  "Especie",
  "MDE",
  "Precipitacion",
  "Temperatura",
  "Radiacion",
  "TWI",
  "tau",
  "Tau_c",
  "Tau_l",
  "∆Tau"
)

# 4. Usar la primera capa como plantilla
plantilla <- rast(rutas[1])

# 5. Crear una lista para guardar capas reescaladas
alineadas <- list()

# 6. Recorrer rutas y reescalar cada capa a la plantilla
for (i in seq_along(rutas)) {
  # 6.1. Leemos la ruta i
  ruta <- rutas[i]
  
  # 6.2. Cargar ráster
  capa <- rast(ruta)
  
  # 6.3. Reescalar para que coincida en resolución y extensión
  resampleada <- resample(capa, plantilla, method = "bilinear")
  
  # 6.4. Recortar al bounding box del polígono
  recortado <- crop(resampleada, vector)
  
  # 6.5. Enmascarar: conservar solo lo dentro del polígono
  enmascarado <- mask(recortado, vector)
  
  # 6.6. Reemplazar NA por 9999 (para evitar pérdida de datos al usar na.rm=TRUE después)
  # values(enmascarado)[is.na(values(enmascarado))] <- 9999
  
  # 6.7. Guardar en lista
  alineadas[[length(alineadas) + 1]] <- enmascarado
}

# 7. Asignamos los nombres a los ráster de la lista antes de crear el stack
names(alineadas) <- nombres

# 8. Función para traducir las especies 
especies <- function(df) { 
  df %>% 
    mutate(especie = case_when( 
      especie == 1 ~ "P. pinea", 
      especie == 2 ~ "P. pinaster", 
      especie == 3 ~ "P. halepensis", 
      especie == 4 ~ "P. nigra", 
      especie == 5 ~ "Pinus", 
      especie == 6 ~ "P. canariensis", 
      especie == 7 ~ "P. sylvestris", 
      especie == 8 ~ "P. radiata" 
    )) 
  }

# 9. Dataframes por variable abiótica
# 9.1. Creamos los df
# 9.1.1. Dataframes variables abióticas
nombres_df <- c("MDE","Precipitacion","Temperatura","Radiacion","TWI")

for (i in seq_along(nombres_df)) {
  # Especie (1), variable ambiental (2..6 => i+1) y tau (7)
  capas <- c(alineadas[[1]], alineadas[[i + 1]], alineadas[[7]])
  names(capas) <- c("especie", nombres_df[i], "tau")
  
  df <- as.data.frame(capas, xy = TRUE, na.rm = TRUE)
  df <- especies(df)
  
  assign(paste0("df_", nombres_df[i]), df)
  rm(df, capas)
  gc()
}

# 9.1.2. Dataframe especie-tau
especie_tau <- c(alineadas[[1]], alineadas[[7]])
names(especie_tau) <- c("especie", "tau")
df_especie_tau <- as.data.frame(especie_tau, xy = TRUE, na.rm = TRUE) %>%
  especies()
gc()

# 9.1.3. Dataframes tau corto y largo
tau <- c("tau_corto" = alineadas[[8]], "tau_largo" = alineadas[[9]], "diferencia_tau" = alineadas[[10]])
df_tau <- as.data.frame(tau, xy = TRUE, na.rm = TRUE) %>%
  rename('Tau corto' = 1, 'Tau largo' = 2, '∆Tau' = 3)
gc()

#9.1.3. Lista para guardar los df creados
df <- list(
  df_MDE, 
  df_Precipitacion, 
  df_Temperatura,
  df_Radiacion, 
  df_TWI,
  df_especie_tau
)

# 9.2. Tomamos una muestra para evitar errores por por tamaño de muestra
muestrear_especies <- function(df, n_sample = 2500, seed = 123) {
  set.seed(seed)
  
  df %>%
    group_by(especie) %>%
    group_modify(~{
      n_rows <- nrow(.x)
      if(n_rows <= n_sample) {
        return(.x)
      } else {
        return(.x[sample(n_rows, n_sample), ])
      }
    }) %>%
    ungroup()
}

df_MDE_sample <- muestrear_especies(df_MDE, 2500)
df_Precipitacion_sample <- muestrear_especies(df_Precipitacion, 2500)
df_Temperatura_sample <- muestrear_especies(df_Temperatura, 2500)
df_Radiacion_sample <- muestrear_especies(df_Radiacion, 2500)
df_TWI_sample <- muestrear_especies(df_TWI, 2500)
df_especie_tau_sample <- muestrear_especies(df_especie_tau, 2500)

df_muestra <- list(
  MDE = df_MDE_sample,
  Precipitacion = df_Precipitacion_sample,
  Temperatura = df_Temperatura_sample,
  Radiacion = df_Radiacion_sample,
  TWI = df_TWI_sample,
  Tau = df_especie_tau_sample
)

# 10. Cálculo de estadísticas
# 10.1. Creamos la función
cor_tau_especie <- function(df, var){
  df %>%
    group_by(especie) %>%
    group_modify(~{
      # Quitar NA
      d2 <- na.omit(.x[, c("tau", var)])
      if(nrow(d2) < 3){
        return(tibble(
          R2 = NA_real_, r = NA_real_, p = NA_real_, Significance = "insufficient data"
        ))
      }
      
      # Modelo lineal
      f <- as.formula(paste("tau ~", var))
      modelo <- lm(f, data = d2)
      r2 <- summary(modelo)$r.squared
      r  <- cor(d2$tau, d2[[var]])
      p  <- summary(modelo)$coefficients[2,4]
      
      # Formatear p
      signif <- ifelse(p < 0.05, "Significativo", "No significativo")
      
      tibble(
        n = nrow(d2),
        R2 = round(r2, 3),
        r = round(r, 3),
        p = round(p, 3),
        Significance = signif
      )
    }) %>%
    ungroup() %>%
    mutate(Variable = var) %>%
    select(especie, Variable, everything())
}

# 10.2. Calculamos las estadísticas para cada df, creamos sus tablas y guardamos las tablas
est_MDE <- cor_tau_especie(df_MDE_sample,  "MDE")
est_P <- cor_tau_especie(df_Precipitacion_sample,  "Precipitacion")
est_T <- cor_tau_especie(df_Temperatura_sample,  "Temperatura")
est_R <- cor_tau_especie(df_Radiacion_sample,  "Radiacion")
est_TWI <- cor_tau_especie(df_TWI_sample,  "TWI")

# 10.3. Creamos una lista de tablas
lista_de_tablas <- list(
  "Est_MDE" = est_MDE,
  "Est_Precipitacion" = est_P,
  "Est_Temperatura" = est_T,
  "Est_Radiacion" = est_R,
  "Est_TWI" = est_TWI
)

# 11. Exportamos los resultados a una hoja de cálculo
ruta_salida_tau_especie <- "E:/AUTOCORRELACION/tau_variables/tau_especie.xlsx" 
ruta_salida_df_muestra <- "E:/AUTOCORRELACION/tau_variables/df_muestra.xlsx"
#ruta_salida_df <- "E:/AUTOCORRELACION/tau_variables/df.xlsx"

openxlsx::write.xlsx(lista_de_tablas, file = ruta_salida_tau_especie)
openxlsx::write.xlsx(df_muestra, file = ruta_salida_df_muestra)
#openxlsx::write.xlsx(df, file = ruta_salida_df)

# 12. Gráficos
# 12.1. Gráfico de densidad para tau_corto
g_tau_corto <- ggplot(df_tau_c_l, aes(x = `Tau corto`)) +
  geom_density(fill = "#FF9999", color = "#FF6666", alpha = 0.8) +
  labs(
    title = "Densidad de Tau Corto",
    x = "Valor de Tau Corto",
    y = "Densidad"
  ) +
  theme_minimal()

ggsave("E:/AUTOCORRELACION/tau_variables/densidad_tau_corto.png", 
       plot = g_tau_corto, 
       width = 8, 
       height = 6, 
       units = "in", 
       dpi = 300)

# 12.2. Gráfico de densidad para tau_largo
g_tau_largo <- ggplot(df_tau, aes(x = `Tau largo`)) +
  geom_density(fill = "#66CC99", color = "#339966", alpha = 0.8) +
  labs(
    title = "Densidad de Tau Largo",
    x = "Valor de Tau Largo",
    y = "Densidad"
  ) +
  theme_minimal()

ggsave("E:/AUTOCORRELACION/tau_variables/densidad_tau_largo.png", 
       plot = g_tau_largo, 
       width = 8, 
       height = 6, 
       units = "in", 
       dpi = 300)

# 12.3. Gráfico de densidad combinado
df_tau_grafico <- df_tau %>%
  pivot_longer(
    cols = c(`Tau corto`, `Tau largo`, `∆Tau`),
    names_to = "Tipo_Tau",
    values_to = "Valor"
  )

g_tau_combinado <- ggplot(df_tau_grafico, aes(x = Valor, fill = Tipo_Tau, color = Tipo_Tau)) +
  geom_density(alpha = 0.6) +
  labs(
    title = "Densidad de Tau Corto, Tau Largo y ∆Tau",
    x = "Valor de Tau",
    y = "Densidad",
    fill = "Tipo de Tau",
    color = "Tipo de Tau"
  ) +
  theme_minimal()

ggsave("E:/AUTOCORRELACION/tau_variables/densidad_tau_combinado.png", 
       plot = g_tau_combinado, 
       width = 8, 
       height = 6, 
       units = "in", 
       dpi = 300)

# 12.4. Gráfico de densidad de diferencia de tau
g_diferencia_tau <- ggplot(df_tau, aes(x = `∆Tau`)) +
  geom_density(fill = "#9370DB", color = "#483D8B", alpha = 0.8) +
  labs(
    title = "Densidad de ∆Tau",
    x = "Valor de ∆Tau",
    y = "Densidad"
  ) +
  theme_minimal()

ggsave("E:/AUTOCORRELACION/tau_variables/densidad_diferencia_tau.png", 
       plot = g_diferencia_tau, 
       width = 8, 
       height = 6, 
       units = "in", 
       dpi = 300)

# 12.5. Gráfico de de densidad tau en facetas por especie
# Calcular medias
medias_especie_tau <- df_especie_tau_sample %>%
  group_by(especie) %>%
  summarise(media_tau = mean(tau, na.rm = TRUE)) %>%
  ungroup()

especie_tau_facetas <- ggplot(df_especie_tau_sample, aes(x = tau)) +
  geom_density(fill = "#56B4E9", color = "#0072B2", alpha = 0.8) +
  # Agregamos geom_vline() y le pasamos el nuevo dataframe con las medias
  geom_vline(
    data = medias_especie_tau, 
    aes(xintercept = media_tau),
    color = "red",
    linetype = "solid", # Opcional: para que la línea sea discontinua
    alpha = 0.8,
    linewidth = 1 # Opcional: para ajustar el grosor de la línea
  ) +
  facet_wrap(~ especie, scales = "free_y", ncol = 2) +
  labs(
    title = "Densidad de valores de ∆Tau por Especie",
    x = "Valor de ∆Tau",
    y = "Densidad"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold", size = 10),
    panel.spacing = unit(1, "lines")
  )

ggsave("E:/AUTOCORRELACION/tau_variables/densidad_facetas_especie_tau.png", 
       plot = especie_tau_facetas, 
       width = 8, 
       height = 6, 
       units = "in", 
       dpi = 300)

# 13. Test ANOVA
# 13.1. Test de Kolmogorov-Smirnov con corrección de Lilliefors
resultados_lillie <- df_especie_tau_sample %>%
  group_by(especie) %>% # Agrupar el dataframe por especie
  group_modify(~ {  # Aplicar la función a cada grupo
    # .x es el sub-dataframe de cada grupo (cada especie)
    # se omite los valores NA antes de aplicar el test
    test_result <- lillie.test(na.omit(.x$tau))
    
    tibble(  # Se extraen los valores importantes del resultado del test
      statistic = test_result$statistic,
      p.value = test_result$p.value
    )
  }) %>%
  ungroup()
print(resultados_lillie)
openxlsx::write.xlsx(resultados_lillie, 
                     file = "E:/AUTOCORRELACION/tau_variables/resultados_lillie.xlsx")

# 13.2. Test de Levene para comprobar homocedasticidad (homogeneidad de varianzas)
df_especie_tau_sample$especie <- as.factor(df_especie_tau_sample$especie)

resultados_levene <- df_especie_tau_sample %>%
  levene_test(tau ~ especie)

print(resultados_levene)

# 13.3. Test ANOVA de Welch
#resultados_anova_welch <- df_especie_tau_sample %>%
#  welch_anova_test(tau ~ especie)

resultados_anova_welch <- oneway.test(tau ~ especie, data = df_especie_tau_sample, var.equal = FALSE)

print(resultados_anova_welch)

# 13.4. Test post-hoc Games-Howell para comparaciones de medias por pares
resultados_games_howell <- df_especie_tau_sample %>%
  games_howell_test(tau ~ especie)

print(resultados_games_howell)

# 13.5. Calcular tamaño del efecto Cohen's d
especies <- levels(df_especie_tau_sample$especie)
resultados_cohen <- data.frame()

for(i in 1:(length(especies)-1)) {
  for(j in (i+1):length(especies)) {
    # Filtrar solo dos especies
    datos_dos_especies <- df_especie_tau_sample[df_especie_tau_sample$especie %in% c(especies[i], especies[j]), ]
    
    # Eliminar niveles no usados del factor
    datos_dos_especies$especie <- droplevels(datos_dos_especies$especie)
    
    # Calcular Cohen's d
    cohen_result <- cohens_d(tau ~ especie, 
                             data = datos_dos_especies,
                             pooled_sd = FALSE)
    
    # Agregar información de las especies comparadas
    cohen_result$Especie1 <- especies[i]
    cohen_result$Especie2 <- especies[j]
    
    # Combinar resultados
    resultados_cohen <- rbind(resultados_cohen, cohen_result)
  }
}

print(resultados_cohen)

# 13.6 Exportar tablas de resultados a excel
openxlsx::write.xlsx(resultados_lillie, file = "E:/AUTOCORRELACION/tau_variables/kolmogorov.xlsx")
openxlsx::write.xlsx(resultados_levene, file = "E:/AUTOCORRELACION/tau_variables/levene.xlsx")
openxlsx::write.xlsx(resultados_anova_welch, file = "E:/AUTOCORRELACION/tau_variables/anova.xlsx")
openxlsx::write.xlsx(resultados_games_howell, file = "E:/AUTOCORRELACION/tau_variables/games_howell.xlsx")
openxlsx::write.xlsx(resultados_cohen, file = "E:/AUTOCORRELACION/tau_variables/cohen.xlsx")