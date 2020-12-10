library(shiny)
library(shinythemes)
library(shinydashboard)
library(leaflet)
library(jsonlite)
library(httr)
library(tidyverse)
library(DT)
library(anytime)
library(lubridate)
library(purrr)
library(datetime)

shinyUI(fluidPage(
                  br(),
                  fluidRow(column(12, align = "center",
                    img(src='logo_vacation.png', align = "center", alt="logo", width= "350", height="150")
                  )),
                  theme = shinytheme("united"),
                  fluid = TRUE,
                  collapsible = TRUE,
                  br(),
                  tags$style(HTML("
                                  br {
                                  line-height: 300%;
                                  }")),
                  tabsetPanel(
                    id = "panels",
                    # type = "hidden",
                    tabPanel("Home",
                             fluidRow(
                               column(12, align = "center",
                                      h2("Start planning your next vacation:"),
                                      tags$style(HTML("
                                                      h2 {
                                                      font-family: 'Lobster', cursive;
                                                      font-weight: 500;
                                                      font-size: 40px;
                                                      line-height: 1.1;
                                                      color: 	rgba(250, 70, 0, .85);
                                                      margin-bottom: 40px;
                                                      margin-top: 20px;
                                                      width: 600px;
                                                      }"
                                  )),

                                  img(src='camp.png', align = "center"),
                                  tags$style(HTML("
                                                  body {
                                                  height: 100%;
                                                  width: 100%;
                                                  padding: 0;
                                                  margin: 0;
                                                  background-image: url('background_color.png');
                                                  background-size: cover;
                                                  background-repeat: no-repeat;
                                                  background-attachment: fixed;
                                                  background-position: center;
                                                  }")),
                                  hr(),
                                  actionButton("link_to_tabpanel", "Get Started Now!"),
                                  tags$style(HTML("
                                                  #link_to_tabpanel{
                                                  font-family: 'Lobster', cursive;
                                                  font-weight: 500;
                                                  font-size: 15px;
                                                  line-height: 1.1;
                                                  color:#fffffa	;
                                                  padding: 1%;
                                                  background: rgba(250, 70, 0, .85);
                                                  }"))

                                  ))
                                  ),
                    tabPanel("Your Next Vacation",
                             fluidPage(theme = "bootstrap.css",

                                       tags$head(
                                         tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css"),
                                         tags$style(HTML("
                                                         @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
                                                         h1 {
                                                         font-family: 'Lobster', cursive;
                                                         font-weight: 500;
                                                         line-height: 1.1;
                                                         color: 	rgba(250, 70, 0, .85);
                                                         margin-bottom: 40px;
                                                         margin-top: 20px;
                                                         }
                                                         nav{
                                                         width: 0 auto;
                                                         margin: 0 auto;
                                                         border-width: 2px 0;
                                                         text-align: center;
                                                         margin-top: 2em;
                                                         }
                                                         "))),

                                       headerPanel("Vacation Awaits You!"),
                                       hr(),
                                       # Copy the line below to make a date range selector

                                       dateRangeInput(inputId = "dates", label = "Vacation Dates",
                                                      start = Sys.Date() + 1,
                                                      end = Sys.Date() + 3,
                                                      min = Sys.Date() + 1,
                                                      max = Sys.Date() + 13,

                                                      format = "mm/dd/yyyy",
                                                      separator = "-"),
                                       hr(),
                                       p("Addresses must be in the form: Street Address, City, State"),
                                       textInput(
                                         'StartState', label = "Type in Starting Address",
                                         "12 Garden St, Chatham, NJ"
                                       ),
                                       textInput(
                                         'EndState', label = "Type in Ending Address",
                                         "275 Lincoln St, San Luis Obispo, CA"
                                       ),
                                       actionButton("goButton", "Go!"),
                                       tags$style(HTML("
                                                       #goButton{
                                                       font-family: 'Lobster', cursive;
                                                       font-weight: 500;
                                                       font-size: 15px;
                                                       line-height: 1.1;
                                                       background: #fffffa	;
                                                       color: rgba(250, 70, 0, .85);
                                                       }")),
                                br(),
                                fluidRow(
                                  column(6,
                                         hr(),
                                         verbatimTextOutput("dir_title"),
                                         tags$head(tags$style(
                                           "#dir_title{color: #fffffa;
                                           font-family: 'Lobster', cursive;
                                           font-size:20px;
                                           font-stretch: expanded;
                                           background: 	rgba(250, 70, 0, .85);}")),
                                         dataTableOutput("directions_table")
                                         ),
                                  column(6,
                                         hr(),
                                         verbatimTextOutput("map_title"),
                                         tags$head(tags$style(
                                           "#map_title{color: #fffffa;
                                           font-family: 'Lobster', cursive;
                                           font-size:20px;
                                           font-stretch: expanded;
                                           background: 	rgba(250, 70, 0, .85);}")),
                                         leafletOutput("plot")
                                         )
                                         ),
                                hr(),
                                verbatimTextOutput("weather_title"),
                                tags$head(tags$style(
                                  "#weather_title{color: #fffffa;
                                  font-family: 'Lobster', cursive;
                                  font-size:20px;
                                  font-stretch: expanded;
                                  background: rgba(250, 70, 0, .85);}")),
                                dataTableOutput("weather_table")

                                )
                                )
                                         )

                                         ))
