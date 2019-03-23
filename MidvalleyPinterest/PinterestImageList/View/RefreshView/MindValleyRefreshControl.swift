//
//  MindValleyRefreshControl.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/23/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

class MindValleyRefreshControl: UIRefreshControl {
    
    private var refreshView: RefreshView?
    
    override init() {
        super.init()
        addRefreshView()
        addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        removeTarget(self, action: #selector(self.refresh), for: .valueChanged)
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        refresh()
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        refreshView?.endAnimation()
    }
    
    private func addRefreshView() {
        if let refreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            refreshView.frame = bounds
            addSubview(refreshView)
            self.refreshView = refreshView
        }
    }
    
    @objc private func refresh() {
        refreshView?.beginAnimation()
    }
}
