library(shiny)
library(shinyWidgets)
library(ggplot2)
library(readr)
library(dplyr)
library(tibble)

# Read the cleaned data set
cleaned_data <- read_csv("../Data/cleaned_data.csv")

# Sort and group birth locations
sorted_birthplaces <- cleaned_data %>%
  arrange(Birthplace) %>%
  distinct(Birthplace) %>%
  mutate(First_Letter = toupper(substr(Birthplace, 1, 1))) %>%
  group_by(First_Letter) %>%
  summarize(Birthplaces = list(Birthplace)) %>%
  ungroup() %>%
  deframe()

# Define user interface
ui <- fluidPage(
  titlePanel("Holocaust Victims by Birthplace and Religion"),
  sidebarLayout(
    sidebarPanel(
      # Use pickerInput instead of checkboxGroupInput to allow selection of birthplace by alphabetical grouping
      pickerInput("selectedBirthplaces", "Select Birthplaces:",
                  choices = sorted_birthplaces,
                  multiple = TRUE,
                  options = list(`actions-box` = TRUE, `live-search` = TRUE, `selected-text-format` = "count > 3", `size` = 10),
                  selected = names(sorted_birthplaces)[1]
      )
    ),
    mainPanel(
      plotOutput("birthplacePlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  # Logic for generating histogram
  output$birthplacePlot <- renderPlot({
    data_to_plot <- cleaned_data %>%
      filter(Birthplace %in% input$selectedBirthplaces) %>%
      group_by(Religion) %>%
      summarize(Number_of_Victims = n()) %>%
      ungroup() %>%
      arrange(desc(Number_of_Victims))
    
    ggplot(data_to_plot, aes(x = Religion, y = Number_of_Victims, fill = Religion)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      labs(y = "Number of Victims", x = "Religion", title = "Number of Victims by Religion for Selected Birthplaces")
  })
}

# Run Shiny application
shinyApp(ui = ui, server = server)