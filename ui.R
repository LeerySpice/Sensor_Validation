

library(shiny)
library(plotly)

shinyUI(fluidPage(theme = "bootstrap.css",
                br(),
                titlePanel(title="Validación DMI"),
                sidebarLayout(
                    sidebarPanel(
                        textInput(inputId = "dmi", "NÚMERO DMI"),
                        numericInput(inputId="n", "POSICION MESA", value=1, min = 1, max = 12),
                        dateInput(inputId = "date", "FECHA VALIDACIÓN (DESDE)"),
                        dateInput(inputId = "date2", "FECHA VALIDACIÓN (HASTA)"),
                        br(),
                        submitButton("Aplicar cambios"),
                        br(),
                        downloadButton('report', "Download the PDF report")
                    ),
                    mainPanel(
                        h4('KEY'),
                        verbatimTextOutput("outvalue0"),
                        h4('Cantidad de mediciones (>40)'),
                        verbatimTextOutput("outvalue1"),
                        h4('Porcentaje mediciones completas % (>90%)'),
                        verbatimTextOutput("outvalue2"),
                        h4('Bateria (>95%)'),
                        verbatimTextOutput("outvalue3"),
                        h4('Promedio tiempo entre mediciones'),
                        verbatimTextOutput("outvalue4"),
                        br(),
                        br(),
                        h3('Espectro'),
                        plotlyOutput('plot'),
                    )
                ),
                fluidRow(column(width = 12,
                                h3('Dataframe'),
                                dataTableOutput("outvalue5")))
))