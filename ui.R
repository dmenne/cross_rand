library(shinyjs)
library(shinythemes)

shinyUI(fluidPage(
  theme = shinytheme("cosmo"),
  useShinyjs(),
  tags$style(HTML("ul{margin-left:-30px}")),
  titlePanel("Balanced Crossover Randomization"),
  sidebarLayout(
    sidebarPanel("",
      textInput("study", "Study Name (> 3 characters)",
        #        "My clinical study",
                placeholder = "My clinical study"),
        textInput("treatments", "Treatment names, separated by space",
                  # "a b",
                  placeholder = "LE1 LE2 LE3 LE4"),
        helpText(HTML("Unbalanced designs can be forced by adding the requested numbers after a colon, e.g. LE1:8. If given, the sum of numbers must add up to <b>(#study days)*(#patients)</b>. If this is not the case, the table will be computed as if the weights were missing. Check the summary printed below the table to make sure that the weights have been used.")),
        numericInput("seed", "Enter random 5 digits", NA, width = "180px"),
        helpText("Keep this number in your documents to reproduce the list."),
        selectInput("model", "Model", names(models), names(models)[9]),
        helpText("Try 'No carry-over effects' first. Other combinations may fail or give unexpected result"),
        div(style = "display:inline-block;",
          numericInput("n_days", "# study days", 3, 2, 5, 1, "90px")),
        div(style = "display:inline-block;",
          numericInput("n_subjects", "# patients", 6, 4, 30, 1, "90px")),
        helpText("This program is running on a free account with limited computing power. Since searching for an optimal design is CPU intensive, please use small number of patients for your test runs, e.g. 6."),
      actionButton("computeButton","Compute", icon = icon("refresh")),
        helpText("Computation may need more than a minute. Be patient..."),
        hr(),
        helpText("Menne Biomed Consulting Tübingen (dieter.menne@menne-biomed.de) for University Hospital of Zürich and ETH, Project GI MRT. Uses R and packages shiny and Crossover.")
    ), # sidebarPanel
    mainPanel(NULL,
        tableOutput('table'),
        htmlOutput('caption')
    )
  ) # sidebarLayout
))

