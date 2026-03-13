library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(ggplot2)
library(janitor)

# Load data
data <- read_csv("data/raw/supply_chain_data.csv")
data <- data |>
  clean_names()

# UI
ui <- page_fillable(
  title = "Supply Chain Dashboard",
  h2("Supply Chain Dashboard"),
  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      h4("Global Filters"),
      
      selectInput(
        inputId = "product_dropdown",
        label = "Product Category",
        choices = c("All", unique(data$product_type)),
        selected = "All"
      ),
      checkboxGroupInput(
        inputId = "checkbox_group",
        label = "Transportation Mode",
        choices = unique(data$transportation_modes),
        selected = unique(data$transportation_modes)
      )
    ),
    layout_columns(
      fill = TRUE,
      card(
        card_header("Avg. Cost per Unit"),
        h2(textOutput("avg_cost")),
        full_screen = FALSE
      ),
      card(
        card_header("Inspection Pass Rate"),
        h2(textOutput("pass_rate")),
        full_screen = FALSE
      )
    ),
    layout_columns(
      fill = TRUE,
      card(
        card_header("Defect Rates by SKU"),
        plotlyOutput("scatterplot"),
        full_screen = TRUE
      ),
      card(
        card_header("Shipping Cost Matrix (Route vs. Mode)"),
        plotlyOutput("heatmap"),
        full_screen = TRUE
      ),
      col_widths = c(6, 6)
    )
  )
)

# Server
server <- function(input, output, session) {
  filtered_data <- reactive({
    df <- data
    
    if (input$product_dropdown != "All") {
      df <- df |> filter(product_type == input$product_dropdown)
    }
    
    df |>
      filter(transportation_modes %in% input$checkbox_group)
  })
  
  output$avg_cost <- renderText({
    round(mean(filtered_data()$costs, na.rm = TRUE), 2)
  })
  
  output$pass_rate <- renderText({
    pass <- mean(filtered_data()$inspection_results == "Pass")
    paste0(round(pass * 100, 1), "%")
  })

  output$scatterplot <- renderPlotly({
    p <- ggplot(
      filtered_data(),
      aes(
        x = sku,
        y = defect_rates,
        color = supplier_name
      )
    ) +
      geom_point(alpha = 0.8, size = 2) +
      labs(
        x = "SKU",
        y = "Defect Rate",
        color = "Supplier"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })

  output$heatmap <- renderPlotly({
    heat <- filtered_data() |>
      group_by(transportation_modes, routes) |>
      summarise(avg_cost = mean(costs, na.rm = TRUE), .groups = "drop")
    
    p <- ggplot(
      heat,
      aes(
        x = routes,
        y = transportation_modes,
        fill = avg_cost
      )
    ) +
      geom_tile() +
      scale_fill_viridis_c() +
      labs(
        x = "Route",
        y = "Transportation Mode",
        fill = "Avg Cost"
      ) +
      theme_minimal()
    
    ggplotly(p)
    
  })
}

# Create app
shinyApp(ui = ui, server = server)