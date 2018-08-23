//
//  PhotoModel.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

struct PhotoModel {
    let id : String
    let farm: Int
    let server: String
    let secret: String
    let title: String
    let image: String
    let largeSizeimage: String
    init(dict: [String:Any]) {
        id = dict.getStringKey("id")
        farm = dict["farm"] as? Int ?? 1
        server = dict.getStringKey("server")
        secret = dict.getStringKey("secret")
        title = dict.getStringKey("title")
        image = String(format: Constants.imageURL, farm,server,id,secret,Constants.thumbnail)
        largeSizeimage = String(format: Constants.imageURL, farm,server,id,secret,Constants.medium)
    }
}

extension Dictionary {
    func getStringKey(_ key: Key) -> String {
        if let y = self[key] as? String, !y.isEmpty {
            return y
        }
        return ""
    }
    
}
