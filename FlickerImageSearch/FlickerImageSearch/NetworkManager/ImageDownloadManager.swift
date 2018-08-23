//
//  ImageDownloadManager.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

typealias ImageClosure = (Result<UIImage>,_ url: String) -> Void
class ImageDownloadManager: NSObject {
    static let shared = ImageDownloadManager()
    private(set) var cache:NSCache<AnyObject, AnyObject> = NSCache()
    
    private var operationQueue = OperationQueue()
    private var dictionaryBlocks = [UIImageView: (String, ImageClosure, ImageOperation)]()
    
    private override init() {
        operationQueue.maxConcurrentOperationCount = 100
    }
    
    func addOperation(url: String, imageView: UIImageView,completion: @escaping ImageClosure) {
        if let image = getImageFromCache(key: url)  {
            completion(.Success(image),url)
            if let tupple = self.dictionaryBlocks.removeValue(forKey: imageView){
                tupple.2.cancel()
            }
        } else {
            if !checkOperationExists(with: url,completion: completion) {
                if let tupple = self.dictionaryBlocks.removeValue(forKey: imageView){
                    tupple.2.cancel()
                }
                let newOperation = ImageOperation(url: url) { (image,downloadedImageURL) in
                    if let tupple = self.dictionaryBlocks[imageView] {
                        if tupple.0 == downloadedImageURL {
                            if let image = image {
                                self.saveImageToCache(key: downloadedImageURL, image: image)
                                tupple.1(.Success(image),downloadedImageURL)
                                if let tupple = self.dictionaryBlocks.removeValue(forKey: imageView){
                                    tupple.2.cancel()
                                }
                            } else {
                                tupple.1(.Failure("Not fetched"), downloadedImageURL)
                            }
                            _ = self.dictionaryBlocks.removeValue(forKey: imageView)
                        }
                    }
                }
                dictionaryBlocks[imageView] = (url, completion, newOperation)
                operationQueue.addOperation(newOperation)
            }
        }
    }
    
    private func getImageFromCache(key : String) -> UIImage? {
        if (self.cache.object(forKey: key as AnyObject) != nil) {
            return self.cache.object(forKey: key as AnyObject) as? UIImage
        } else {
            return nil
        }
    }
    
    private func saveImageToCache(key : String, image : UIImage) {
        self.cache.setObject(image, forKey: key as AnyObject)
    }
    
    func checkOperationExists(with url: String,completion: @escaping (Result<UIImage>,_ url: String) -> Void) -> Bool {
        if let arrayOperation = operationQueue.operations as? [ImageOperation] {
            let opeartions = arrayOperation.filter{$0.url == url}
            return opeartions.count > 0 ? true : false
        }
        return false
    }
}

extension UIImageView {
    func downloadImage(with url: String){
        ImageDownloadManager.shared.addOperation(url: url,imageView: self) {  [weak self](result,downloadedImageURL)  in
            DispatchQueue.main.async {
                switch result {
                case .Success(let image):
                    self?.image = image
                case .Failure(_):
                    break
                case .Error(_):
                    break
                }
            }
        }
    }
}
