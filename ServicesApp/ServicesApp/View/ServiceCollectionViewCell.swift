//
//  ServiceCollectionViewCell.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit

class ServiceCollectionViewCell: UICollectionViewCell {
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
}
