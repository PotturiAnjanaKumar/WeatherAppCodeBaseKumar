//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by ANJANA KUMAR on 04/05/23.
//

import Foundation
import UIKit

struct Request {
    
    public enum HTTPMethod: String {
        case post = "POST"
        case put = "PUT"
        case get = "GET"
    }
    var requestType: HTTPMethod
    var queryParameters: [String: String]?
    var headers: [String: String]?
    
    func createRequest(for urlString: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: urlString) else {
            return nil
        }
        let queryItems = queryParameters?.map({ (key, value) in
            URLQueryItem(name: key, value: value)
        })
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        headers?.forEach({ (key, value) in
            request.setValue(key, forHTTPHeaderField: value)
        })
        return request
    }
}

struct NetworkManager: DataReceiver {
    
    private var session = URLSession.shared
    func fetchData(for request: URLRequest, completionHandler: @escaping (Result<Data,Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, error == nil {
                completionHandler(.success(data))
                return
            }
            completionHandler(.failure(error!))
        }.resume()
    }
}

protocol DataReceiver {
    func fetchData(for request: URLRequest, completionHandler: @escaping (Result<Data,Error>) -> Void)
}

class Observable<T> {
    typealias Listener = (T) -> Void
    var listerner: Listener?
    var value: T {
        didSet {
            listerner?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listner: Listener?) {
        self.listerner = listner
        listner?(value)
    }
}

extension Data {
    func object<T: Decodable>(using type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}

extension UIViewController {

    public func showAlert(title: String,
                          message: String,
                          alertStyle:UIAlertController.Style,
                          actionTitles:[String],
                          actionStyles:[UIAlertAction.Style],
                          actions: [((UIAlertAction) -> Void)]){

        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated() {
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
}
