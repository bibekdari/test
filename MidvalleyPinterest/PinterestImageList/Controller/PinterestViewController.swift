//
//  PinterestViewController.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/21/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

class PinterestViewController: UIViewController {
    
    var requestHandler: RequestHandler?
    
    private weak var collectionView: UICollectionView!
    private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addRefreshControl()
        getData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.register(UINib(nibName: "PinterestImageListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PinterestImageListCollectionViewCell")
        
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        
        self.collectionView = collectionView
    }
    
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        posts = []
        getData()
    }
    
    private func getData() {
        do {
            try getPosts(success: { [weak self] (posts) in
                self?.posts = posts
                // reload view
                DispatchQueue.main.async {
                    if let refreshControl = self?.collectionView.refreshControl,
                        refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                    self?.collectionView.reloadData()
                }
            }) { [weak self] (error) in
                DispatchQueue.main.async {
                    if let refreshControl = self?.collectionView.refreshControl,
                        refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                    self?.showError(error)
                }
            }
        }catch {
            self.showError(error)
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

}


// MARK: - UICollectionViewDataSource

extension PinterestViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinterestImageListCollectionViewCell", for: indexPath) as! PinterestImageListCollectionViewCell
        return cell
    }
    
}

extension PinterestViewController: PostsAPI {
    
}
