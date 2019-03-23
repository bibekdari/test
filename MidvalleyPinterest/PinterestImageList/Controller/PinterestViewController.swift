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
    private var posts: [Post] = []
    private var zoomingCell: PinterestImageListCollectionViewCell?
    private var zoominCellOldFrame: CGRect?
    private var loadingView: RefreshView?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addLoading()
        
        // just added delay because loading animation will appear.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.getData()
        }
    }
    
    
    @IBAction func closeImagePopup(_ sender: Any) {
        
        guard let cell = zoomingCell,
            let zoominCellOldFrame = zoominCellOldFrame
            else {return}
        
        UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            cell.frame = zoominCellOldFrame
            cell.imageView.contentMode = .scaleAspectFill
            self.collectionView.isScrollEnabled = true
            self.closeButton.isHidden = true
        }, completion: {_ in
            self.zoominCellOldFrame = nil
            self.zoomingCell = nil
        })
    }
    
    private func setupCollectionView() {
        // add cell
        collectionView.register(UINib(nibName: "PinterestImageListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PinterestImageListCollectionViewCell")
        
        // set delegate and datasource
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.alwaysBounceVertical = true
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
    
    private func addLoading() {
        if let refreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            refreshView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 100)
            refreshView.center = collectionView.center
            refreshView.backgroundColor = .clear
            view.addSubview(refreshView)
            refreshView.beginAnimation()
            loadingView = refreshView
        }
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
                    self?.loadingView?.endAnimation()
                    self?.collectionView.reloadData()
                }
            }) { [weak self] (error) in
                DispatchQueue.main.async {
                    if let refreshControl = self?.collectionView.refreshControl,
                        refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                    self?.loadingView?.endAnimation()
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
        cell.imageView.contentMode = .scaleAspectFill
        configureCellUI(cell)
        return cell
    }
    
    private func configureCellUI(_ cell: PinterestImageListCollectionViewCell) {
        cell.backgroundColor = .white
        
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

// MARK: - UICollectionViewDelegate

extension PinterestViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard zoomingCell == nil, let cell = collectionView.cellForItem(at: indexPath) as? PinterestImageListCollectionViewCell else {return}
        
        zoominCellOldFrame = cell.frame
        
        cell.superview?.bringSubviewToFront(cell)
        
        UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            cell.frame = collectionView.bounds
            collectionView.isScrollEnabled = false
            cell.imageView.contentMode = .scaleAspectFit
            self.closeButton.isHidden = false
        }, completion: nil)
        
        zoomingCell = cell
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
