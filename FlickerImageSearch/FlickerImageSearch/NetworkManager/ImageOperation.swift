//
//  ImageOperation.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

class ImageOperation: Operation {
    
    let url : String?
    var customCompletionBlock: ((_ image : UIImage?,_ url: String) -> Void)?
    
    init(url : String, completionBlock : @escaping ((_ image : UIImage?,_ url : String) -> Void)) {
        self.url = url
        self.customCompletionBlock = completionBlock
    }
    
    override func main() {
        if self.isCancelled { return }
        if let url = self.url{
            if self.isCancelled { return }
            APIManager.shared.downloadImage(urlString: url) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .Success(let image):
                        if self.isCancelled { return }
                        if let block = self.customCompletionBlock{
                            block(image, url)
                        }
                    default:
                        if self.isCancelled { return }
                        break
                    }
                }
            }
        }
    }
}
