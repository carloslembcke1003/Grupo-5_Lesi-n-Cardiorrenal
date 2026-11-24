
library(lme4)
library(glmmTMB)
library(ggplot2)
library(dplyr)
library(tidyr)
library(writexl)

# 2. Preparar datos limpios y variables necesarias (incluyendo componentes cíclicos)
c_offset <- 0.01 # Constante pequeña para evitar log(0) en el modelo Log-Normal

datos_limpios <- muert5 %>%
  filter(!is.na(TNUM), !is.na(TASA_M), !is.na(TEMP), !is.na(HUMED), 
         !is.na(MES), !is.na(Pob), !is.na(DISTR)) %>%
  mutate(
    TEMP_z = as.numeric(scale(TEMP)),
    HUMED_z = as.numeric(scale(HUMED)),
    sin_mes = sin(2 * pi * as.numeric(MES) / 12),
    cos_mes = cos(2 * pi * as.numeric(MES) / 12),
    log_TASA_M = log(TASA_M + c_offset) # Variable respuesta para el modelo Log-Normal
  )

# Detectar automáticamente el multiplicador de tu TASA_M (en tu script 1 usas 10000)
fila_ejemplo <- which(datos_limpios$TNUM > 0)[1]
multiplicador <- round((datos_limpios$TASA_M[fila_ejemplo] * datos_limpios$Pob[fila_ejemplo]) / datos_limpios$TNUM[fila_ejemplo])

# 3. Ajustar los 4 modelos usando el factor cíclico (sin_mes + cos_mes)
# Modelo 1: Normal directo sobre TASA_M
mod_normal <- lmer(
  TASA_M ~ TEMP_z + HUMED_z + sin_mes + cos_mes + (1 | DISTR),
  data = datos_limpios
)

# Modelo 2: Log-Normal sobre log(TASA_M + c)
mod_lognormal <- lmer(
  log_TASA_M ~ TEMP_z + HUMED_z + sin_mes + cos_mes + (1 | DISTR),
  data = datos_limpios
)

# Modelo 3: Poisson sobre conteos con offset
mod_poisson <- glmer(
  TNUM ~ TEMP_z + HUMED_z + sin_mes + cos_mes + offset(log(Pob)) + (1 | DISTR),
  data = datos_limpios,
  family = poisson(link = "log"),
  control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
)

# Modelo 4: Binomial Negativo sobre conteos con offset
mod_nb <- glmmTMB(
  TNUM ~ TEMP_z + HUMED_z + sin_mes + cos_mes + offset(log(Pob)) + (1 | DISTR),
  data = datos_limpios,
  family = nbinom2
)

# 4. Obtener todas las predicciones en la escala original de TASA_M
sigma2_ln <- sigma(mod_lognormal)^2

datos_limpios <- datos_limpios %>%
  mutate(
    tasa_pred_normal    = predict(mod_normal),
    tasa_pred_lognormal = pmax(0, exp(predict(mod_lognormal) + sigma2_ln / 2) - c_offset),
    tasa_pred_poisson   = (predict(mod_poisson, type = "response") / Pob) * multiplicador,
    tasa_pred_nb        = (predict(mod_nb, type = "response") / Pob) * multiplicador
  )

# 5. Tabla resumen de contraste evaluando errores en TASA_M
tabla_comparacion_4 <- data.frame(
  Modelo = c(
    "1. Normal (TASA_M)", 
    "2. Log-Normal (log TASA_M)", 
    "3. Poisson (glmer)", 
    "4. Binomial Negativo (glmmTMB)"
  ),
  AIC = c(NA, NA, AIC(mod_poisson), AIC(mod_nb)),
  RMSE_Tasa = c(
    sqrt(mean((datos_limpios$TASA_M - datos_limpios$tasa_pred_normal)^2)),
    sqrt(mean((datos_limpios$TASA_M - datos_limpios$tasa_pred_lognormal)^2)),
    sqrt(mean((datos_limpios$TASA_M - datos_limpios$tasa_pred_poisson)^2)),
    sqrt(mean((datos_limpios$TASA_M - datos_limpios$tasa_pred_nb)^2))
  ),
  MAE_Tasa = c(
    mean(abs(datos_limpios$TASA_M - datos_limpios$tasa_pred_normal)),
    mean(abs(datos_limpios$TASA_M - datos_limpios$tasa_pred_lognormal)),
    mean(abs(datos_limpios$TASA_M - datos_limpios$tasa_pred_poisson)),
    mean(abs(datos_limpios$TASA_M - datos_limpios$tasa_pred_nb))
  ),
  Tasas_Negativas = c(
    sum(datos_limpios$tasa_pred_normal < 0),
    sum(datos_limpios$tasa_pred_lognormal < 0),
    sum(datos_limpios$tasa_pred_poisson < 0),
    sum(datos_limpios$tasa_pred_nb < 0)
  )
)

print(tabla_comparacion_4)

# Exportar a Excel
write_xlsx(tabla_comparacion_4, "comparacion_4_modelos_ciclico.xlsx")

# 6. Gráfico comparativo de los 4 modelos
datos_grafico <- datos_limpios %>%
  select(TASA_M, starts_with("tasa_pred_")) %>%
  pivot_longer(cols = starts_with("tasa_pred_"), names_to = "Modelo", values_to = "Tasa_Predicha") %>%
  mutate(Modelo = recode(Modelo,
                         "tasa_pred_normal"    = "1. Normal",
                         "tasa_pred_lognormal" = "2. Log-Normal",
                         "tasa_pred_poisson"   = "3. Poisson",
                         "tasa_pred_nb"        = "4. Binomial Negativo"
  ))

ggplot(datos_grafico, aes(x = TASA_M, y = Tasa_Predicha, color = Modelo)) +
  geom_point(alpha = 0.4) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "black") +
  facet_wrap(~ Modelo, ncol = 2) +
  labs(
    title = "Comparación de 4 Modelos: Tasa Observada vs. Tasa Predicha",
    subtitle = "Evaluación en escala original de TASA_M con estacionalidad cíclica (sin/cos)",
    x = "Tasa Observada (TASA_M)",
    y = "Tasa Predicha"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

