# codigo con transparencias
# app.R — ¿Más triples = más victorias?
library(tidyverse)
library(shiny)

# 1. Carga de datos
team_tr <- read_csv("data/team_stats_traditional_rs.csv", show_col_types = FALSE)
team_sc <- read_csv("data/team_stats_scoring_rs.csv",    show_col_types = FALSE)

# 2. Preparación
# uso como base TRADITIONAL porque tiene W/L/FG3/FGA
teams_base <- team_tr %>%
  rename(
    season  = SEASON,
    team    = TEAM_NAME,
    w       = W,
    l       = L,
    win_pct = W_PCT,
    fga     = FGA,
    fg3a    = FG3A,
    fg3m    = FG3M,
    fg3_pct = FG3_PCT
  ) %>%
  mutate(
    win_pct = ifelse(is.na(win_pct), w / (w + l), win_pct),
    three_pa_rate = fg3a / fga
  ) %>%
  select(season, team, w, l, win_pct, fga, fg3a, fg3m, fg3_pct, three_pa_rate)

# Traemos de SCORING el % de puntos desde el triple y % de FGA que son triples
teams <- teams_base %>%
  left_join(
    team_sc %>%
      rename(season = SEASON, team = TEAM_NAME,
             share_pts_3pt = PCT_PTS_3PT,
             pct_fga_3pt   = PCT_FGA_3PT),
    by = c("season","team")
  )

# Listas para inputs
seasons <- sort(unique(teams$season))
teams_list <- sort(unique(teams$team))

# 3. UI con pestañas y el fondo de la NBA
ui <- navbarPage(
  title = "¿Más triples = más victorias? (NBA RS)",
  
  # CSS para usar www/fondo_nba.png como fondo de la app
  header = tagList(
    tags$head(
      tags$style(HTML("
      body {
        background-image: url('fondo_nba.jpg');
        background-size: cover;
        background-attachment: fixed;
        background-position: center;
      }
      /* Panel principal */
      .tab-content, .main-panel, .well {
        background-color: rgba(255,255,255,0.85); /* blanco semitransparente */
        border-radius: 10px;
        padding: 15px;
      }
      /* Sidebar */
      .sidebar {
        background-color: rgba(255,255,255,0.9);
        border-radius: 10px;
        padding: 10px;
      }
      /* Tablas */
      table {
        background-color: white;
      }
    "))
    )
  ),
  
  # Pestaña 1: Exploración 
  tabPanel("Exploración",
           sidebarLayout(
             sidebarPanel(
               selectInput("season", "Temporada", choices = seasons, selected = max(seasons)),
               radioButtons(
                 "xvar", "Elegí la métrica en X",
                 choices = c(
                   "3PA rate (FG3A/FGA)"            = "three_pa_rate",
                   "FG3% (FG3_PCT)"                 = "fg3_pct",
                   "Share puntos de 3 (PCT_PTS_3PT)"= "share_pts_3pt"
                 ),
                 selected = "three_pa_rate"
               ),
               selectInput("team_filter", "Equipo (opcional)", choices = c("Todos", teams_list), selected = "Todos"),
               checkboxInput("show_lm", "Mostrar línea de tendencia (lm)", TRUE)
             ),
             mainPanel(
               plotOutput("scatter", height = 340),
               tags$hr(),
               tableOutput("tabla")
             )
           )
  ),
  
  # Pestaña 2: Información general
  tabPanel("Información general",
           fluidPage(
             h3("Limpieza y preparación de datos"),
             tags$ul(
               tags$li("Se renombraron columnas: `TEAM_NAME → team`, `SEASON → season`, etc."),
               tags$li("Se calculó `three_pa_rate = FG3A / FGA` (volumen relativo de triples)."),
               tags$li("Se unieron métricas de `team_stats_traditional_rs.csv` (FG3A, FG3M, FG3_PCT, FGA, W, L, W_PCT) con `team_stats_scoring_rs.csv` (PCT_PTS_3PT, PCT_FGA_3PT)."),
               tags$li("Se aseguraron variables finales por equipo-temporada: `win_pct`, `three_pa_rate`, `fg3_pct`, `share_pts_3pt`."),
               tags$li("Se usó `tidyverse` para transformar y `shiny` para la interfaz (estructura `sidebarLayout`).")
             ),
             h3("Qué permite explorar la app"),
             tags$ul(
               tags$li("Elegir temporada y métrica de triples en el eje X."),
               tags$li("Ver la relación con el porcentaje de victorias (Win%) en un gráfico de dispersión con recta de regresión opcional."),
               tags$li("Consultar una tabla con equipos ordenados por Win% y sus métricas de triples.")
             ),
             h3("Nota"),
             tags$ul(
               tags$li("Análisis de temporada regular (no incluye playoffs, lesiones ni calendario).")
             )
           )
  )
)

# 4. Server
server <- function(input, output, session){
  
  # Datos filtrados por temporada y equipo (reactive)
  datos <- reactive({
    d <- teams %>% filter(season == input$season)
    if (input$team_filter != "Todos") d <- d %>% filter(team == input$team_filter)
    d
  })
  
  output$scatter <- renderPlot({
    d <- datos()
    xlab <- switch(
      input$xvar,
      "three_pa_rate" = "3PA rate (FG3A/FGA)",
      "fg3_pct"       = "FG3% (FG3_PCT)",
      "share_pts_3pt" = "Share puntos de 3 (PCT_PTS_3PT)"
    )
    
    ggplot(d, aes_string(x = input$xvar, y = "win_pct")) +
      geom_point(color = "steelblue") +
      geom_smooth(method = "lm", se = TRUE, formula = y ~ x, color = "grey") +
      labs(x = xlab, y = "Win %", title = paste("Temporada", input$season)) +
      theme_minimal()
  })
  
  output$tabla <- renderTable({
    datos() %>%
      select(team, win_pct, three_pa_rate, fg3_pct, share_pts_3pt, fg3a, fg3m, fga) %>%
      arrange(desc(win_pct)) %>%
      head(12)
  }, digits = 3)
}

shinyApp(ui, server)