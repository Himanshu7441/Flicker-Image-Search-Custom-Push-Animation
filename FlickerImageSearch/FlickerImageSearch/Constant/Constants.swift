//
//  Constants.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

class Constants: NSObject {
    static let searchURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Constants.apiKey)&format=json&text=%@&page=%ld"
    static let apiKey = "a4f28588b57387edc18282228da39744"
    
    static let imageURL = "https://farm%d.staticflickr.com/%@/%@_%@_%@.jpg"
    static let thumbnail = "t"
    static let medium = "c"
}
