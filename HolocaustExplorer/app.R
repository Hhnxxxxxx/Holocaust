library(shiny)
library(shinyWidgets)
library(ggplot2)
library(readr)
library(dplyr)
library(tibble)

# 读取清理后的数据集
cleaned_data <- read_csv("cleaned_data.csv")

# 对出生地点进行排序和分组
sorted_birthplaces <- cleaned_data %>%
  arrange(Birthplace) %>%
  distinct(Birthplace) %>%
  mutate(First_Letter = toupper(substr(Birthplace, 1, 1))) %>%
  group_by(First_Letter) %>%
  summarise(Birthplaces = list(Birthplace)) %>%
  ungroup() %>%
  deframe()

# 定义用户界面
ui <- fluidPage(
  titlePanel("Holocaust Victims by Birthplace and Religion"),
  sidebarLayout(
    sidebarPanel(
      # 使用pickerInput来代替checkboxGroupInput，允许按字母分组选择出生地点
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

# 定义服务器逻辑
server <- function(input, output) {
  # 生成柱状图的逻辑
  output$birthplacePlot <- renderPlot({
    data_to_plot <- cleaned_data %>%
      filter(Birthplace %in% input$selectedBirthplaces) %>%
      group_by(Religion) %>%
      summarise(Number_of_Victims = n()) %>%
      ungroup() %>%
      arrange(desc(Number_of_Victims))
    
    ggplot(data_to_plot, aes(x = Religion, y = Number_of_Victims, fill = Religion)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      labs(y = "Number of Victims", x = "Religion", title = "Number of Victims by Religion for Selected Birthplaces")
  })
}

# 运行Shiny应用程序
shinyApp(ui = ui, server = server)