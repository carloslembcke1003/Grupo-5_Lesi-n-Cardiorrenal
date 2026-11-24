# Códigos del modelo

Esta carpeta reúne los cuadernos de **Google Colab** (`.ipynb`) utilizados para ajustar y comparar los modelos estadísticos del **Reto 4 – Grupo 5**.

## ¿Qué hacen los cuadernos?

1. Cargan la base integrada de defunciones, temperatura, humedad y población.
2. Preparan las observaciones por **distrito y mes** para el ajuste.
3. Comparan cuatro modelos: normal, log-normal, Poisson y binomial negativo.
4. Aplican el **modelo binomial negativo de efectos mixtos** a las condiciones meteorológicas de enero a septiembre de 2026.

Las salidas de 2026 son **estimaciones del modelo**, no conteos observados de defunciones. El DLNM se planteó como una extensión para analizar datos diarios y no se ajustó en esta etapa.

## Cómo ejecutar los cuadernos

Abre el archivo `.ipynb` en **Google Colab**, carga la base procesada que indica el cuaderno y ejecuta las celdas de arriba hacia abajo. Los pasos previos de extracción y limpieza están documentados en la carpeta **Códigos filtrado y extracción de datos**.

**Responsable del modelamiento:** Iris Lucana Macedo.