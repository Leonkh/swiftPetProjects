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
        AF.request(url, method: .get).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.jsonData = json
                self.textView.text = self.jsonData?.description
                print("В замыкании: \(self.jsonData)")
                print("В замыкании: \(self.jsonData?.description)")
            case .failure(let error):
                print(error)
            }
        }
//        print("Вне замыкания: \(jsonData)")
        
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


