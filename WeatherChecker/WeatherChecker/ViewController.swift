//
//  ViewController.swift
//  WeatherChecker
//
//  Created by Леонид Хабибуллин on 20.11.2020.
//
import Alamofire
import SwiftyJSON
import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    var cityName: String?
    var apiKey: String!
    var jsonData: JSON?
    var weatherParam = [String: String]()
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var searchBar: UISearchBar!
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
      var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
      return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        textView.delegate = self
        apiKey = "4a4e219d6b73a256ed2379f35ecbaeb9"
        
       
    }
    
    
    
    
    
    func getWeatherInfo(cityName: String) {
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&lang=ru&units=metric&appid=\(apiKey!)"
        AF.request(url, method: .get).validate().responseJSON { [weak self] (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self?.jsonData = json
                self?.textView.text = self?.jsonData?.description
                self?.weatherParam = [
                    "Название города": self!.jsonData!["name"].stringValue,
                    "Температура в цельсиях": self!.jsonData!["main"]["temp"].stringValue,
                    "Долгота": self!.jsonData!["coord"]["lat"].stringValue,
                    "Широта": self!.jsonData!["coord"]["lon"].stringValue,
                    "Описание состояния на улице": self!.jsonData!["weather"]["description"].stringValue,
                    "Скорость ветра в м/с": self!.jsonData!["wind"]["speed"].stringValue,
                    "Влажность в %": self!.jsonData!["main"]["humidity"].stringValue
                ]
                self?.textView.text = """
                    Название города:  \(self!.weatherParam["Название города"]!)
                    Температура: \(self!.weatherParam["Температура в цельсиях"]!) градусов цельсия
                    Долгота: \(self!.weatherParam["Долгота"]!)
                    Широта: \(self!.weatherParam["Широта"]!)
                    Сейчас на улице \(self!.weatherParam["Описание состояния на улице"]!)
                    Скорость ветра \(self!.weatherParam["Скорость ветра в м/с"]!) м/с
                    Влажность \(self!.weatherParam["Влажность в %"]!)%
                    """
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func dismissKeyboard() {
      searchBar.resignFirstResponder()
    }
    
    
    
}

extension ViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    dismissKeyboard()
    
    guard let searchText = searchBar.text, !searchText.isEmpty else {
      return
    }
    cityName = searchText
    guard let city = cityName else {return}
    getWeatherInfo(cityName: city)
  }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
      view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
      view.removeGestureRecognizer(tapRecognizer)
    }
}


