library(googlesheets4)

# Replace the URL with your Google Spreadsheet URL
spreadsheet_url <- "https://docs.google.com/spreadsheets/d/1tGFHHICtguU5_S_QuCBpW0awQIGF-X7gY30j0URRlok/edit#gid=864982580"

# Read the sheet
data <- googlesheets4::read_sheet(spreadsheet_url)

write.csv(data, "../Data/raw.csv", row.names = FALSE)
