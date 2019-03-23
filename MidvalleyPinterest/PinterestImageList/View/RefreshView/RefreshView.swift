//
//  RefreshView.swift
//  MidvalleyPinterest
//
//  Created by bibek timalsina on 3/23/19.
//  Copyright © 2019 bibek timalsina. All rights reserved.
//

import UIKit

class RefreshView: UIView {

    @IBOutlet weak var logoView: UIImageView!
    
    private var gradientView: UIView?
    
    // MARK: - setup view
    private func addGradientView() {
        logoView.image = UIImage(named: "mv-logo-full-white")?.withRenderingMode(.alwaysTemplate)
        let gradientView = UIView(frame: CGRect(
            x: -25,
            y: 0,
            width: logoView.frame.width + 50,
            height: logoView.frame.height
        ))
        logoView.addSubview(gradientView)
        
        let gradient = gradientLayer(frame: gradientView.bounds, with: [
            UIColor.white.withAlphaComponent(0),
            UIColor.white.withAlphaComponent(0.8),
            UIColor.white.withAlphaComponent(0)
            ])
        
        gradientView.layer.insertSublayer(gradient, at: 0)
        gradientView.backgroundColor = .clear
        self.gradientView = gradientView
    }
    
    private func gradientLayer(frame: CGRect, with colors: [UIColor]) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 0, y: 0.5)
        layer.colors = colors.map({$0.cgColor})
        return layer
    }
    
    // MARK: - Animation
    func beginAnimation() {
        isHidden = false
        addGradientView()
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: [.autoreverse, .repeat],
            animations: {
                self.gradientView?.frame.origin.x = 100
        },
            completion: nil)
    }
    
    func endAnimation() {
        isHidden = true
        gradientView?.layer.removeAllAnimations()
        gradientView = nil
    }
}
