//
//  PhotoCollectionViewCell.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImage: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.image = nil
    }
    var model: PhotoModel? {
        didSet {
            if let model = model {
                photoImage.image = UIImage(named: "placeholder")
                photoImage.downloadImage(with: model.image)
            }
        }
    }
}
