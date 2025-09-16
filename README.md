# Trabajo final individual

Repo con el enunciado y los materiales para la entrega del trabajo final individual.

# 📊 ¿Más triples = más victorias? (NBA Regular Season)

Este trabajo práctico utiliza **datos de equipos de la NBA** para explorar una pregunta sencilla:

👉 *¿Existe relación entre el uso del tiro de tres puntos y el porcentaje de victorias de un equipo?*

---

## 🎯 Objetivo
El objetivo es **visualizar y analizar** cómo el volumen, la efectividad y la importancia de los triples dentro del ataque de un equipo se relacionan con su rendimiento medido como **Win%** (porcentaje de victorias en la temporada regular).

---

## 🗂️ Datos utilizados
Los datos provienen del repositorio abierto [NBA Dataset Stats Player-Team](https://github.com/...), con estadísticas de la NBA (temporadas 1996–2023).

- `team_stats_traditional_rs.csv`: intentos y conversiones de tiros de campo, triples (`FG3A`, `FG3M`, `FG3_PCT`), partidos ganados/perdidos (`W`, `L`, `W_PCT`).  
- `team_stats_scoring_rs.csv`: distribución de puntos y tiros, incluyendo `PCT_FGA_3PT` (% de intentos que son triples) y `PCT_PTS_3PT` (% de puntos desde el triple).

---

## 🧹 Limpieza y preparación
1. Se renombraron columnas a nombres más simples (`TEAM_NAME → team`, `SEASON → season`, etc.).  
2. Se calculó **`three_pa_rate = FG3A / FGA`**, proporción de intentos que son triples.  
3. Se unieron métricas de los dos archivos para tener en un único dataset por equipo y temporada:
   - `three_pa_rate` (volumen relativo de triples).  
   - `fg3_pct` (porcentaje de acierto en triples).  
   - `share_pts_3pt` (porcentaje de puntos anotados desde el triple).  
   - `win_pct` (porcentaje de victorias).  

---

## 🔍 Exploración
La aplicación Shiny permite:

- Seleccionar una **temporada** 
- Elegir la métrica de triples a usar en el eje X (`3PA rate`, `FG3%`, o `Share puntos de 3`)  
- Visualizar un **gráfico de dispersión** con opción de recta de regresión  
- Consultar una **tabla con los equipos ordenados por Win%** y sus métricas de triples


Ejemplo: en la temporada 2022-23 se observa que equipos como **Milwaukee Bucks** y **Boston Celtics** muestran alto volumen de triples y también alto porcentaje de victorias.

---

## 🖥️ Comunicación
La app fue desarrollada con **R y Shiny** utilizando la estructura vista en clase:

- **UI:** `fluidPage()` con `sidebarLayout()`
- **Inputs:** `selectInput()`, `radioButtons()`, `checkboxInput()`
- **Outputs:** `plotOutput()` + `renderPlot()`, `tableOutput()` + `renderTable()`
- **Uso de reactividad:** `reactive()` para filtrar por temporada y equipo

---

## 🚀 Ejecución
Para correr la app localmente:

```r
shiny::runApp()
```
