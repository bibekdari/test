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
        // configure layout
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        // add constraints
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        
        // add cell
        collectionView.register(UINib(nibName: "PinterestImageListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PinterestImageListCollectionViewCell")
        
        // set delegate and datasource
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        self.collectionView = collectionView
    }
    
    private func addRefreshControl() {
        let refreshControl = MindValleyRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
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
        let post = posts[indexPath.row]
        let placeHolderImage = UIImage(named: "mv-logo-full-white")?.withRenderingMode(.alwaysTemplate)
        if let url = URL(string: post.urls.small) {
            cell.imageView.setImage(from: url, placeHolderImage: placeHolderImage)
        }else {
            cell.imageView.image = placeHolderImage
        }
        configureCell(cell)
        return cell
    }
    
    private func configureCell(_ cell: PinterestImageListCollectionViewCell) {
        cell.imageView.layer.cornerRadius = 20
        let contentView = cell.contentView
        
        // set shadow
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        contentView.layer.shadowRadius = 0.5
        contentView.layer.shadowOpacity = 0.24
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension PinterestViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }
    
}

extension PinterestViewController: PostsAPI {
    
}
