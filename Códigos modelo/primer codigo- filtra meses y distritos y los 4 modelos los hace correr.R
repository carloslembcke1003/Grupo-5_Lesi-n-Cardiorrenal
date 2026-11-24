
install.packages("DHARMa")
install.packages("car")
install.packages("performance")
install.packages("glmmTMB")
install.packages("readxl")
install.packages("lme4")

library(car)
library(performance) ## Colinealidad
library(glmmTMB) ### modelo BN
library(DHARMa)
library(readxl)
library(lme4)

muert3 <- read_excel("muert3.xlsx")
View(muert3)


## Limpiar los distritos: San Bartolo, Santa Maria del Mar, Santa Rosa, Punta Negra, Pucusana y
## Punta Hermosa.

muert4=muert3[-which(muert3$DISTR %in% c(29,38,39,27,24,26)),]

## Limpiar los meses enero-abril 2022

muert5=muert4[-which(muert4$FECHA1 %in% c("2022-01","2022-02","2022-03","2022-04")),]
muert5$sin_mes <- sin(2 * pi * as.numeric(muert5$MES) / 12)
muert5$cos_mes <- cos(2 * pi * as.numeric(muert5$MES) / 12)

muert5$TEMP_z <- as.numeric(scale(muert5$TEMP))
muert5$HUMED_z <- as.numeric(scale(muert5$HUMED))

#### modelo lineal sin transformación logarítmica
model1 <- lmer(TASA_M ~ TEMP+HUMED+ sin_mes+cos_mes + (1 | DISTR), data = muert5)
summary(model1)

#### modelo lineal con transformación logarítmica
model2 <- lmer(log(TASA_M) ~ TEMP+HUMED+ sin_mes+cos_mes + (1 | DISTR), data = muert5)
summary(model2)

#### modelo Poisson
model.po=glmer(TNUM ~ TEMP_z+HUMED_z+ sin_mes+cos_mes+ offset(log(Pob))+(1 | DISTR), data = muert5,
               family = poisson(link = "log"))

# Revisar colinealidad de los efectos fijos
check_collinearity(model.po)

# Revisar sobredisperciÃ³n
check_overdispersion(model.po)


#### Binomial Negativa

model.nb <- glmmTMB(
  TNUM ~ TEMP_z + HUMED_z + sin_mes + cos_mes + offset(log(Pob)) + (1 | DISTR),
  data = muert5,
  family = nbinom2 # Binomial negativa estÃ¡ndar
)

summary(model.nb)


# Comparar AIC (el valor mÃ¡s bajo indica el mejor ajuste)
AIC(model.po, model.nb)


#_____________________________________________________________
# Predicciones
#_____________________________________________________________
# 1. Modelo Normal (lmer sobre TASA_M) -> Devuelve la Tasa predicha

muert5$pred_normal <- predict(model1)*muert5$Pob/10000
muert5$pred_normal2 <- exp(predict(model2))*muert5$Pob/10000 ## con transformaciÃ³n log

# 2. Modelo de Poisson (glmer con offset) -> Devuelve el conteo esperado de muertes
muert5$pred_poisson <- predict(model.po, type = "response")

# 3. Modelo Binomial Negativo (glmmTMB con offset) -> Devuelve el conteo esperado de muertes
muert5$pred_nb <- predict(model.nb, type = "response")

##################################################################################
##################################################################################


