library(shiny)

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
      
      sliderInput("weight", label = "Weight (kg)", min = 0, 
                  max = 100, value = c(0, 100) ),
      
      sliderInput("height", label = "Height (m)", min = 0, 
                  max = 100, value = c(0, 100) ),
      
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