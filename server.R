library(shiny)
library(shinythemes)
library(shinydashboard)
library(jsonlite)
library(shiny)
library(httr)
library(tidyverse)
library(leaflet)
library(DT)
library(shinydashboard)
library(anytime)
library(lubridate)
library(purrr)
library(datetime)
source("functions.R")

shinyServer (function(input, output, session) {

  # You can access the values of the widget (as a vector of Dates)
  # with input$dates, e.g.

  start_d <- eventReactive(input$goButton,{
    as.character(input$dates[1])
  })
  end_d <- eventReactive(input$goButton,{
    as.character(input$dates[2])
  })

  observeEvent(input$link_to_tabpanel, {
    newvalue <- "Your Next Vacation"
    updateTabItems(session, "panels", newvalue)
  })

  start <- eventReactive(input$goButton,{
    input$StartState
  })
  end <- eventReactive(input$goButton,{
    input$EndState
  })

  map_ <- eventReactive(input$goButton,{
    "Map"
  })
  dir_ <- eventReactive(input$goButton,{
    "Directions"
  })

  weather_ <- eventReactive(input$goButton,{
    "Weather Forecast"
  })

  output$startdate <- renderText({
    start_d()
  })
  output$enddate <- renderText({
    end_d()
  })

  output$map_title <- renderText({
    map_()
  })
  output$dir_title <- renderText({
    dir_()
  })

  output$weather_title <- renderText({
    weather_()
  })

  dir <- eventReactive(input$goButton,{
    start_addy <- start()
    end_addy <- end()
    query <- get_query(start_addy, end_addy)
    directions(query)
  })

  output$plot <- renderLeaflet({
    dir()[[2]]
  })

  output$directions_table <- renderDataTable({
    dir()[[1]] %>% select(-c(Latitude, Longitude)) %>% datatable()

  })

  output$weather_table <- renderDataTable({
    final_data <- dir()[1] %>% as.data.frame()
    final_dates <- date_input(input$dates[1], input$dates[2])
    fields <- list("precipitation", "temp", "feels_like", "wind_speed", "visibility", "humidity", "sunrise", "sunset")


    num <- final_data %>%
      nrow()
    lng_input <- final_data$Longitude[num]
    lat_input <- final_data$Latitude[num]

    big_query <- query_weather(fields, lat_input, lng_input, final_dates)

    num_days <- day(final_dates[2]) - day(final_dates[1]) + 1

    make_output(big_query, num_days) %>% datatable()
  })

})
