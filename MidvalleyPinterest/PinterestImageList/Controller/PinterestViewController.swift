//
//  PinterestViewController.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/21/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

class PinterestViewController: UIViewController {
    
    private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let collectionView = UICollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.register(UINib(nibName: "PinterestImageListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PinterestImageListCollectionViewCell")
        
        collectionView.dataSource = self
    }

}


// MARK: - UICollectionViewDataSource

extension PinterestViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinterestImageListCollectionViewCell", for: indexPath) as! PinterestImageListCollectionViewCell
        return cell
    }
    
}

