# Códigos de filtrado y extracción de datos

Esta carpeta reúne los cuadernos de **Google Colab** (`.ipynb`) utilizados para preparar los datos del **Reto 4 – Grupo 5**. Los cuadernos documentan el proceso desde la lectura de los archivos originales hasta la exportación de las tablas para el análisis.

## Fuentes y procesamiento

| Fuente | ¿Qué se hizo? |
| --- | --- |
| **SINADEF** | Se filtraron los registros de defunción de personas de 60 años a más en la provincia de Lima. Se revisaron las fechas, los distritos de domicilio y los códigos CIE-10. |
| **SENAMHI** | Se organizaron los registros de temperatura y humedad relativa de cuatro estaciones meteorológicas de Lima y se revisaron los datos faltantes y los valores atípicos. |
| **INEI** | Se preparó la tabla de población distrital proyectada para 2022–2024. Las cifras corresponden a todas las edades. |

## Cómo ejecutar los cuadernos

1. Abre el archivo `.ipynb` en **Google Colab**.
2. Carga los archivos de entrada que indica el cuaderno.
3. Ejecuta las celdas en orden, de arriba hacia abajo.
4. Revisa los conteos y las fechas de salida antes de descargar los CSV generados.

Las tablas preliminares de defunciones se organizaron por **distrito y día**. El modelo final del proyecto trabajó con observaciones agregadas por **distrito y mes**.

**Responsable de datos y procesamiento:** Carlos Lembcke Vasquez.