//
//  APIManager.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit
enum Result <T>{
    case Success(T)
    case Failure(String)
    case Error(String)
}

enum RequestMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
}

class APIManager: NSObject {
    static let errorMessage = "Something went wrong, Please try again later"
    static let noInternetConnection = "Please check your Internet connection and try again."
    static let shared = APIManager()
    private override init() {
    }
    
    func downloadImage(urlString: String,completion: @escaping (Result<UIImage>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        guard let url =  URL.init(string: urlString) else {
            return completion(.Failure(APIManager.errorMessage))
        }
        
        guard (Reachability()?.currentReachabilityStatus != .notReachable) else {
            return completion(.Failure(APIManager.noInternetConnection))
        }
        
        session.downloadTask(with: url) { (url, reponse, error) in
            do {
                guard let url = url else {
                    return completion(.Failure(APIManager.errorMessage))
                }
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    return completion(.Success(image))
                } else {
                    return completion(.Failure(APIManager.errorMessage))
                }
            } catch {
                return completion(.Error(APIManager.errorMessage))
            }
        }.resume()
        
    }
    
    func executeRequest(request: Request,completion: @escaping (Result<[String: Any]>) -> Void) {
        guard (Reachability()?.currentReachabilityStatus != .notReachable) else {
            return completion(.Failure(APIManager.noInternetConnection))
        }
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else{
                return completion(.Error(error!.localizedDescription))
            }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? APIManager.errorMessage))
            }
            do {
                guard let stringResponse = String(data: data, encoding: String.Encoding.utf8) else {
                    return completion(.Error(error?.localizedDescription ?? APIManager.errorMessage))
                }
                var dataReponnse = stringResponse.replacingOccurrences(of: "jsonFlickrApi(", with: "")
                dataReponnse = String(dataReponnse.dropLast())
                if let jsonDict = try JSONSerialization.jsonObject(with: dataReponnse.data(using: String.Encoding.utf8)!) as? [String: Any] {
                    if let stat = jsonDict["stat"] as? String{
                        if stat.uppercased().contains("OK") {
                            return completion(.Success(jsonDict))
                        }
                        else{
                            return completion(.Failure(APIManager.errorMessage))
                        }
                    } else{
                        return completion(.Failure(APIManager.errorMessage))
                    }
                }
                else{
                    return  completion(.Error(APIManager.errorMessage))
                }
            } catch {
                return completion(.Error(APIManager.errorMessage))
            }
        }.resume()
    }
}


class Request : NSMutableURLRequest{
    
    convenience init?(requestMethod:RequestMethod,urlString: String,
                      bodyParams: [String: Any]? = nil) {
        guard let url =  URL.init(string: urlString) else {
            return nil
        }
        self.init(url: url)
        do{
            if let bodyParams = bodyParams{
                let data = try JSONSerialization.data(withJSONObject: bodyParams, options: .prettyPrinted)
                self.httpBody = data
            }
        }catch{}
        self.httpMethod = requestMethod.rawValue
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
}

