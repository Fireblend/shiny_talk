library(shiny)
library(dplyr)
library(ggplot2)
library(gridExtra)

base <-
  read.csv(
    "https://raw.githubusercontent.com/fireblend-clases/pandas-tutorial/master/data/pokemon.csv"
  )
base <-
  select(
    base,
    -c(
      starts_with("against"),
      starts_with("base"),
      "abilities",
      "capture_rate",
      "classfication",
      "experience_growth",
      "percentage_male",
      "japanese_name",
      "pokedex_number"
    )
  )

max_w = max(base$weight_kg, na.rm=TRUE)
min_w = min(base$weight_kg, na.rm=TRUE)

max_h = max(base$height_m, na.rm=TRUE)
min_h = min(base$height_m, na.rm=TRUE)

# Elemento de UI
ui <- fluidPage(
  # Titulo de la Aplicación
  titlePanel("The (In)Complete Pokemon Dataset"),
  
  sidebarLayout(
    sidebarPanel(
      # Imagen
      img(src = 'https://i.imgur.com/61hshKI.png',
          width = 250),
      h2("Context"),
      p(
        "This dataset contains information on all 802 Pokemon from all Seven Generations of Pokemon. The information contained in this dataset include Base Stats, Performance against Other Types, Height, Weight, Classification, Egg Steps, Experience Points, Abilities, etc. The information was scraped from http://serebii.net/"
      ),
      h2("Poke-Filter"),
      
      # Agregamos inputs para filtrar el dataset. Los contenidos de estos
      # inputs van a llenarse dinamicamente:
      
      selectizeInput("gen", "Generation", choices = NULL, selected = NULL),
      selectizeInput("type1", "Main Type", choices = NULL, selected = NULL),
      selectizeInput("type2", "Secondary Type", choices = NULL, selected = NULL
      ),
      
      # Sliders de peso y altura
      
      sliderInput("weight", label = "Weight (kg)", min = min_w, 
                  max = max_w, value = c(min_w, max_w) ),
      
      sliderInput("height", label = "Height (m)", min = min_h, 
                  max = max_h, value = c(min_h, max_h) ),
      
      radioButtons(
        "legendary",
        label = "Legendary Status",
        choices = list(
          "Yes" = 1,
          "No" = 2,
          "Any" = 3
        ),
        selected = 3
      )
      
    ),
    
    # Panel principal
    mainPanel(tabsetPanel(
      tabPanel(
        "Pokemon Subsets",
        br(),
        p(
          "This tab updates automatically based on the selection made on the left panel."
        ),
        br(),
        
        # Elemento de Datatable para mostrar
        # selección basada en el filtro
        
        DT::dataTableOutput("table"),
        br(),
        
        # Botón para descarga
        downloadButton('downloadData', 'Download Filtered Data')
        
      ),
      tabPanel(
        "Type Distributions",
        br(),
        p(
          "This tab shows a distribution of a specific type for all generations, or types for a specific generation!"
        ),
        br(),
        
        # Gráfico de Barras
        
        plotOutput("distro")
      ),
      tabPanel(
        "Stat Correlations",
        
        # Layout horizontal para selectores:
        
        fluidRow(
          column(3, selectInput(
            "stat1",
            "Stat #1:",
            c("attack", "defense", "speed", "sp_attack", "sp_defense")
          )),
          column(3, selectInput(
            "stat2",
            "Stat #2:",
            c("attack", "defense", "speed", "sp_attack", "sp_defense"),
            selected = "defense"
          )),
          column(3, selectInput(
            "color",
            "Color:",
            c("generation", "is_legendary", "type1", "type2")
          )),
        ),
        
        # 2 Gráficos que se modifican basados en los selectores:
        
        plotOutput("corr"),
        br(),
        plotOutput("corr2")
      )
    ))
  )
)

server <- function(input, output, session) {
  # Actualiza los valores en los selectores de la barra lateral:
  
  updateSelectizeInput(session,
                       'gen',
                       choices = c('Any', unique(base$generation)),
                       server = TRUE)
  updateSelectizeInput(session,
                       'type1',
                       choices = c("Any", levels(unique(base$type1))),
                       server = TRUE)
  updateSelectizeInput(session,
                       'type2',
                       choices = c("Any", levels(unique(base$type2))),
                       server = TRUE)
  
  # Fragmento reactivo, carga y filtra el dataset de acuerdo a las modificaciones de los filtros de la barra lateral:
  
  pokemon <- reactive({
    data <- base
    if (input$gen != "Any") {
      data <- data[data$generation == input$gen, ]
    }
    if (input$type1 != "Any") {
      data <- data[data$type1 == input$type1, ]
    }
    if (input$type2 != "Any") {
      data <- data[data$type2 == input$type2, ]
    }
    if (input$legendary == 1) {
      data <- data[data$is_legendary == 1, ]
    }
    if (input$legendary == 2) {
      data <- data[data$is_legendary == 0, ]
    }
    
    data <- na.omit(data[data$weight_kg >= input$weight[1] & data$weight_kg <= input$weight[2], ])
    
    data <- na.omit(data[data$height_m >= input$height[1] & data$height_m <= input$height[2], ])
    
    data
  })
  
  # El Datatable solo muestra el estado actual del dataset
  # basado en el filtro
  
  output$table <- DT::renderDataTable(DT::datatable({
    pokemon()
  }))
  
  # Manejador de descargas
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('pokemon-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(pokemon(), con)
    }
  )
  
  # Gráfico de barras:
  
  output$distro <- renderPlot({
    # Decidimos los parámetros del gráfico
    # basándonos en el estado del filtro:
    
    if (input$gen != "Any") {
      ggplot(pokemon(), aes(x = factor(type1))) +
        geom_bar(aes(fill = type2))
    } else {
      ggplot(pokemon(), aes(x = factor(generation))) +
        geom_bar(aes(fill = type1))
    }
  })
  
  # Gráfico de puntos:
  
  output$corr <- renderPlot({
    data <- pokemon()
    
    # Extraemos los valores de los selectores
    # de este tab:
    
    stat1 <- input$stat1
    stat2 <- input$stat2
    color <- input$color
    
    # Para usar strings, usamos aes_string() en vez de aes()
    ggplot(data, aes_string(x = stat1, y = stat2)) +
      geom_point(aes_string(col = color))
    
  })
  
  # Gráficos de distribución:
  
  output$corr2 <- renderPlot({
    data <- pokemon()
    stat1 <- input$stat1
    stat2 <- input$stat2
    color <- input$color
    
    # Gráfico 1
    g1 <- ggplot(data, aes_string(stat1)) +
      geom_density(aes_string(fill = sprintf("factor(%s)", color)), alpha =
                     0.8) +
      labs(fill = color)
    
    # Gráfico 2
    g2 <- ggplot(data, aes_string(stat2)) +
      geom_density(aes_string(fill = sprintf("factor(%s)", color)), alpha =
                     0.8) +
      labs(fill = color)
    
    # Graficándolos juntos con 2 columnas
    grid.arrange(g1, g2, ncol = 2)
    
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
