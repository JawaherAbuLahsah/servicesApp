//
//  ServiceCollectionViewCell.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import LottieCore
class ServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var servicesView: UIView!{
        didSet{
            servicesView.layer.cornerRadius = 20
            servicesView.layer.shadowColor = UIColor.gray.cgColor
            servicesView.layer.shadowOpacity = 1
            servicesView.layer.shadowOffset = CGSize.zero
            servicesView.layer.shadowRadius = 5
        }
    }
    
    
    func setup(_ sleid:Information){
        let animation = AnimationView(name: sleid.animationView)
        animation.frame = animationView.bounds
        animation.center = animationView.center
        animation.loopMode = .loop
        if animationView.subviews.isEmpty{
        animationView.addSubview(animation)
        }
        animation.play()
        infoLabel.text = sleid.info
    }
}
