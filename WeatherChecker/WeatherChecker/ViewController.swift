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
    var cityNameRu: String?
    var apiKey: String!
    var jsonData: JSON?
    var weatherParam = [String: String]()
    var long: Double!
    var latt: Double!
    
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
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(goToMap))
       
    }
    
    
    
    
    
    func getWeatherInfo(cityName: String) {
        let string = cityName
        let replaced = (string as NSString).replacingOccurrences(of: " ", with: "+")
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(replaced)&lang=ru&units=metric&appid=\(apiKey!)"
        AF.request(url, method: .get).validate().responseJSON { [weak self] (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self?.jsonData = json
//                self?.textView.text = self?.jsonData?.description
                print(self?.jsonData)
                var hh = "" // достаем из данные из конструкции  "weather" : [
//                {
//                  "description" : "снег",
                if let howWeather = self!.jsonData!["weather"].array {
                for val in howWeather {
                    if let description = val["description"].string {
                        hh = description // получили снег
//                        print("hh = \(hh)")
                    }
                }
                }
//                print("Массив имеет: \(howWeather["description"])")
                self?.weatherParam = [
                    "Название города": self!.jsonData!["name"].stringValue,
                    "Температура в цельсиях": self!.jsonData!["main"]["temp"].stringValue,
                    "Долгота": self!.jsonData!["coord"]["lat"].stringValue,
                    "Широта": self!.jsonData!["coord"]["lon"].stringValue,
                    "Описание состояния на улице": hh,
                    "Скорость ветра в м/с": self!.jsonData!["wind"]["speed"].stringValue,
                    "Влажность в %": self!.jsonData!["main"]["humidity"].stringValue
                ]
//                print(self?.weatherParam)
                self?.textView.text = """
                    Название города:  \(self!.weatherParam["Название города"]!)
                    Температура: \(self!.weatherParam["Температура в цельсиях"]!) градусов цельсия
                    Долгота: \(self!.weatherParam["Долгота"]!)
                    Широта: \(self!.weatherParam["Широта"]!)
                    Сейчас на улице \(hh)
                    Скорость ветра \(self!.weatherParam["Скорость ветра в м/с"]!) м/с
                    Влажность \(self!.weatherParam["Влажность в %"]!)%
                    """
                
                self?.long = Double(self!.weatherParam["Долгота"]!)
                self?.latt = Double(self!.jsonData!["coord"]["lon"].stringValue)
                self?.cityNameRu = self!.weatherParam["Название города"]!
                
            case .failure(let error):
                print(error)

            }
        }
    }
    
    @objc func dismissKeyboard() {
      searchBar.resignFirstResponder()
    }
    
    @objc func goToMap() {
        guard let mvc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
        mvc.latt = latt
        print("MVC LATT : \(mvc.latt)")
        mvc.long = long
        print("MVC LONG : \(mvc.long)")
        mvc.name = cityNameRu
        
        navigationController?.pushViewController(mvc, animated: true)
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


