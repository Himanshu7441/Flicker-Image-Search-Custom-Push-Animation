//
//  ViewController.swift
//  Tsystem
//
//  Created by Himanshu Garg on 23/08/18.
//  Copyright © 2018 Himanshu Garg. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    private var searchBarController: UISearchController!
    private var numberOfRows: CGFloat = 2.0
    private var viewModel = HomeViewModel()
    private var isFirstTimeActive = true
    private var selectedFrame : CGRect?
    private var customInteractor : CustomInteractor?
    private var selectedImage:UIImage?
    
    @IBOutlet var collectionViewImages: UICollectionView!
    @IBOutlet weak var labelNoResultFound: UILabel!
    
    //Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        labelNoResultFound.isHidden = true
        if isFirstTimeActive {
            searchBarController.isActive = true
            isFirstTimeActive = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: @IBAction
    @IBAction func optionTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Images", message: "How many images to show in a row?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "2", style: .default , handler:{ (UIAlertAction)in
            self.numberOfRows = 2
            self.collectionViewImages.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "3", style: .default , handler:{ (UIAlertAction)in
            self.numberOfRows = 3
            self.collectionViewImages.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "4", style: .default , handler:{ (UIAlertAction)in
            self.numberOfRows = 4
            self.collectionViewImages.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion:nil)
    }
    
    private func loadNextPage() {
        viewModel.fetchNextPage { [weak self](status, message) in
            if status {
                self?.collectionViewImages.reloadData()
            }
        }
    }
    
    private func showAlert( title:String? , message:String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:NSLocalizedString("OK",comment: ""), style: UIAlertActionStyle.default) {(action) in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension HomeViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = self.selectedFrame else { return nil }
        guard let selectedImage = selectedImage else { return nil}
        
        switch operation {
        case .push:
            self.customInteractor = CustomInteractor(attachTo: toVC)
            return CustomAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: true, originFrame: frame, image: selectedImage)
        default:
            return CustomAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: false, originFrame: frame, image: selectedImage)
        }
    }
}

extension HomeViewController: UISearchControllerDelegate,UISearchBarDelegate {
    private func createSearchBar() {
        searchBarController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchBarController
        searchBarController.delegate = self
        searchBarController.searchBar.delegate = self
        searchBarController.dimsBackgroundDuringPresentation = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.count > 1 else {
            return
        }
        labelNoResultFound.isHidden = true
        collectionViewImages.reloadData()
        viewModel.searchText(text: text) {[weak self] (status, message) in
            if status {
                if (self?.viewModel.arrayPhotos.count ?? 0) > 0 {
                    self?.labelNoResultFound.isHidden = true
                } else {
                    self?.labelNoResultFound.isHidden = false
                }
                self?.collectionViewImages.reloadData()
            } else {
                self?.showAlert(title: "Tsystem", message: message)
            }
        }
        searchBarController.searchBar.resignFirstResponder()
    }
    
}

extension HomeViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoImage.image = nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCollectionViewCell else {
            return
        }
        let model = viewModel.arrayPhotos[indexPath.row]
        cell.model = model
        
        if indexPath.row == (viewModel.arrayPhotos.count - 1) {
            loadNextPage()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrayPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width)/numberOfRows, height: (collectionView.bounds.width)/numberOfRows)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theAttributes:UICollectionViewLayoutAttributes! = collectionView.layoutAttributesForItem(at: indexPath)
        selectedFrame = collectionView.convert(theAttributes.frame, to: collectionView.superview)
        self.searchBarController.isActive = false
        perform(#selector(pushDetailView), with: indexPath, afterDelay: 0.1)
    }
    
    @objc func pushDetailView(indexPath: IndexPath){
        guard let cell = collectionViewImages.cellForItem(at: indexPath) as? PhotoCollectionViewCell else {
            return
        }
        let model = viewModel.arrayPhotos[indexPath.row]
        let vc = DetailViewController.viewController(model: model)
        self.selectedImage = cell.photoImage.image
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
