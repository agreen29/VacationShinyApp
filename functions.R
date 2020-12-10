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
get_query <- function(from, to){
  query <- GET("http://www.mapquestapi.com/directions/v2/route",
               query = list(
                 key = "K4wn45o6Nklb6jsL8aRS8G4Fx6DqQ3DZ",
                 from= from,
                 to = to
               ))
  return (query)
}
directions <- function(query){
  api_data <- fromJSON(rawToChar(query$content))
  start_long_pt <- api_data$route$locations$displayLatLng[1,1]
  start_lat_pt <- api_data$route$locations$displayLatLng[1,2]

  data_directions <- api_data$route$legs$maneuvers %>% as.data.frame()
  start_lat_long <- data_directions$startPoint
  final_data <- data_directions %>% select(distance, narrative) %>% cbind(start_lat_long)
  colnames(final_data) <- c("Distance in Miles", "Directions", "Longitude", "Latitude")
  # leaflet map
  map <- leaflet(final_data) %>% addTiles() %>%
    setView( start_long_pt, start_lat_pt ,15) %>%
    addMarkers(~Longitude, ~Latitude, popup = final_data$Directions) %>%
    addPolylines(
      lat = final_data$Latitude, lng = final_data$Longitude,
      color = "red"
    )
  return (list(final_data, map))

}

date_input <- function(day_leaving, day_returning){

  start_time <- anydate(day_leaving)
  end_time <- anydate(day_returning)

  return(c(start_time, end_time))
}


query_weather <- function(fields, lat_input, lng_input, dates) {
  weather <- pmap(list(x = fields),
                  .f = function(x) {
                    data.frame(fromJSON(rawToChar(
                      GET(url = "https://api.climacell.co/v3/weather/forecast/daily",
                          query= list(
                            lat = lat_input,
                            lon = lng_input,
                            unit_system = "us",
                            fields = x,
                            start_time = dates[1],
                            end_time = dates[2],
                            apikey = "Sb9vXfDnuOb1qRqhdU0wgi7L9FeMB2D5"))$content)))
                  })
  return (weather)
}

make_output <- function(big_query, num_days) {

  # temp out
  d_temp <- big_query[[2]]
  #names for all
  names <- d_temp$observation_time[[1]]
  names <- names %>% as.Date()
  names <- format(names,"%a %b %d")

  temp_data <- as.data.frame(pmap(list(x = 1:num_days),
                                  .f = function(x) {
                                    `Min Temp (F)` <- d_temp$temp[[x]]$min$value[1]
                                    `Max Temp (F)` <- d_temp$temp[[x]]$max$value[2]
                                    return(rbind(`Min Temp (F)`, `Max Temp (F)`))
                                  }), stringsAsFactors=FALSE)

  colnames(temp_data) <- names

  # precip out
  d_precip <- big_query[[1]]
  precip_data <- as.data.frame(t(unlist(pmap(list(x = 1:num_days),
                                             .f = function(x) {
                                               precip <- d_precip$precipitation[[x]]$max$value
                                               return(rbind(precip))
                                             }))), stringsAsFactors = FALSE)

  row.names(precip_data) <- "Max Precipitation"
  colnames(precip_data) <- names

  #feels like out
  d_feels <- big_query[[3]]

  feels_data <- as.data.frame(pmap(list(x = 1:num_days),
                                   .f = function(x) {
                                     `Min Feels-Like (F)` <- d_feels$feels_like[[x]]$min$value[1]
                                     `Max Feels-Like (F)` <- d_feels$feels_like[[x]]$max$value[2]
                                     return(rbind(`Min Feels-Like (F)`, `Max Feels-Like (F)`))
                                   }), stringsAsFactors=FALSE)

  colnames(feels_data) <- names

  # wind out
  d_wind <- big_query[[4]]
  wind_data <- as.data.frame(pmap(list(x = 1:num_days),
                                  .f = function(x) {
                                    `Min Wind Speed (mph)` <- d_wind$wind_speed[[x]]$min$value[1]
                                    `Max Wind Speed (mph)` <- d_wind$wind_speed[[x]]$max$value[2]
                                    return(rbind(`Min Wind Speed (mph)`, `Max Wind Speed (mph)`))
                                  }), stringsAsFactors=FALSE)
  colnames(wind_data) <- names

  # visibility out
  d_visibility <- big_query[[5]]
  vis_data <- as.data.frame(pmap(list(x = 1:num_days),
                                 .f = function(x) {
                                   `Min Visibility (miles)` <- d_visibility$visibility[[x]]$min$value[1]
                                   `Max Visibility (miles)` <- d_visibility$visibility[[x]]$max$value[2]
                                   return(rbind(`Min Visibility (miles)`, `Max Visibility (miles)`))
                                 }), stringsAsFactors=FALSE)

  colnames(vis_data) <- names

  # humidity out
  d_humidity <- big_query[[6]]

  hum_data <- as.data.frame(pmap(list(x = 1:num_days),
                                 .f = function(x) {
                                   `Min Humidity` <- d_humidity$humidity[[x]]$min$value[1]
                                   `Max Humidity` <- d_humidity$humidity[[x]]$max$value[2]
                                   return(rbind(`Min Humidity`, `Max Humidity`))
                                 }), stringsAsFactors=FALSE)

  colnames(hum_data) <- names

  # sunrise
  d_sunrise <- big_query[[7]]

  sunrise_data <- as.data.frame(pmap(list(x = 1:num_days),
                                     .f = function(x) {
                                       sunrise <- d_sunrise$sunrise$value[[x]]
                                       time <- as.time(as.datetime(sunrise) - 7*60*60)
                                       sunrise <- as.character(time)
                                       # sunrise <- as.datetime(as.POSIXct(sunrise, tz = "America/Los_Angeles"))
                                       # sunrise <- as.time(sunrise)
                                       return(sunrise)
                                     }), stringsAsFactors = FALSE)

  row.names(sunrise_data) <- "Sunrise"
  colnames(sunrise_data) <- names

  # sunset
  d_sunset <- big_query[[8]]
  sunset_data <- as.data.frame(pmap(list(x = 1:num_days),
                                    .f = function(x) {
                                      sunset <- d_sunset$sunset$value[[x]]
                                      time <- as.time(as.datetime(sunset) - 7*60*60)
                                      sunset <- as.character(time)
                                      return(sunset)
                                    }), stringsAsFactors = FALSE)


  row.names(sunset_data) <- "Sunset"
  colnames(sunset_data) <- names

  weather <- rbind(temp_data, feels_data, precip_data, wind_data, vis_data, hum_data,  sunrise_data, sunset_data)
  return(weather)
}
