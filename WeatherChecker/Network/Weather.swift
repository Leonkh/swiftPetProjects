//
//  Weather.swift
//  WeatherChecker
//
//  Created by Леонид Хабибуллин on 20.11.2020.
//

import Foundation


struct Weather: Decodable {
    let nameOfCity: String // название города
    let longitude: String // долгота
    let latitude: String // ширина
    let clouds: String // облачность в процентах
    let weatherMain: String // общее описание погоды: Group of weather parameters (Rain, Snow, Extreme etc.)
    let weatherDescription: String // более подробное описание общего состояния
    let temp: String // температура в цельсиях
    let pressure: String // давление в hPa
    let humidity: String //влажность в процентах
    let windSpeed: String // скорость ветра в м/с
    
    enum CodingKeys: String, CodingKey {
        case nameOfCity = "name"
        case longitude = "coord.lon"
        case latitude = "coord.lat"
        case clouds = "clouds.all"
        case weatherMain = "weather.main"
        case weatherDescription = "weather.description"
        case temp = "main.temp"
        case pressure = "main.pressure"
        case humidity = "main.humidity"
        case windSpeed = "wind.speed"
      }
}


