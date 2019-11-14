library(shiny)

# Define UI for app that draws a histogram
ui <- fluidPage(
  
  # App title
  titlePanel("Algunos Elementos Visuales!"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      a(
        img(
          src='https://mms.businesswire.com/media/20190924005385/en/730151/23/GAP3lineLOGO.jpg', 
          width=250
          ), 
        href="http://www.wearegap.com"),
      p(
        "Por lo general los elementos visuales comparten los atributos que tendrían en su versión de HTML. La imagen de arriba usa ", 
        code("src"),
        "y",
        code("width")
      ),
      p(
        "La imagen de arriba se encuentra también rodeada por un tag de ",
        code("a"), 
        " que la convierte en un link"
        )
      
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      tabsetPanel(
        tabPanel("Tab #1",  
          h2("Un título"),
          h3("Un subtítulo"),
          p("Es posible incluir rich-text-formatting dentro de nuestra aplicación usando la misma gramática que se usa para html en forma de funciones."),
          p("Muchos de estos comandos reciben como argumentos atributos de HTML como el de style, y además pueden anidarse para replicar el comportamiento jerarquico de un documento HTML", style = "font-family: 'times'; font-si16pt"),
          strong(
            code("strong()"), 
            " genera texto en negrita."
            ),
          em(
            code("em()"), 
            " genera texto con ítalicas."
            ),
          br(),
          p(code("El tag de code es ideal para mostrar fragmentos de código.")),
          div("Incluso se pueden declarar divs para contener múltiples elementos", style = "color:blue"),
          br(),
          p(
            "span puede insertarse en medio de",
            span("grupos de palabras", style = "color:#c334eb"),
            "dentro de un parrafo."
          )
        ),
        tabPanel("Tab #2",
                 h6("Episode IV", align = "center"),
                 h6("A NEW HOPE", align = "center"),
                 h5("It is a period of civil war.", align = "center"),
                 h4("Rebel spaceships, striking", align = "center"),
                 h3("from a hidden base, have won", align = "center"),
                 h2("their first victory against the", align = "center"),
                 h1("evil Galactic Empire.", align = "center")
        )
      )
    )
  )
)

server <- function(input, output) {
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)