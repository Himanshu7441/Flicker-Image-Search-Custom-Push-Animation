//
//  DetailViewController.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    private var viewModel: DetailViewModel!
    
    class func viewController(model: PhotoModel) -> DetailViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.viewModel = DetailViewModel(model: model)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = viewModel.model.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.downloadImage(with: viewModel.model.largeSizeimage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
    }
    
}
