//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by ANJANA KUMAR on 04/05/23.
//

import Foundation
import MapKit

class HomeViewModel {
    
    enum WeatherURL: String {
        case search_city_forecast = "https://api.openweathermap.org/data/2.5/weather"
        case weather_Image = "https://openweathermap.org/img/wn/"
    }
    var dataReciver: DataReceiver = NetworkManager()
    private let appID = "97abbcf594495acfa2eeb336c3694cf5"
    var selectedCoordinate: CLLocationCoordinate2D?
    var weatherData: WeatherData?
    let title = "Weather App"
    
    func fetchWeatherData(coordinate: CLLocationCoordinate2D, completionHandler: @escaping () -> Void) {
        self.selectedCoordinate = coordinate
        if let selectedCoordinate = selectedCoordinate {
            let queryItems = ["lat" : "\(selectedCoordinate.latitude)", "lon" : "\(selectedCoordinate.longitude)", "appid" : appID]
            let baseURl = WeatherURL.search_city_forecast.rawValue
            let request = Request(requestType: .get, queryParameters: queryItems, headers: ["Content-Type":"application/json"])
            if let request = request.createRequest(for: baseURl) {
                fetchdata(for: WeatherData.self, with: request) { weatherData in
                    print(weatherData)
                    self.weatherData = weatherData
                    completionHandler()
                }
            }
        }
    }
    
    func downloadImage(from icon: String, handler: @escaping(Data)-> Void)  {
        var urlStr = WeatherURL.weather_Image.rawValue
        urlStr += "\(icon)@2x.png"
        guard let url = URL(string: urlStr) else {
            return
        }
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            handler(data)
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    
    private func fetchdata<T: Decodable>(for type: T.Type, with request: URLRequest, completion: @escaping((T) -> Void)) {
        dataReciver.fetchData(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let loadedPeople = try data.object(using: T.self)
                    completion(loadedPeople)
                }catch(let error) {
                    print(error)
                }
            case .failure(_):
                break
            }
        }
    }
}

