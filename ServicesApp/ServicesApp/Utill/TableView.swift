//
//  TableView.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 07/06/1443 AH.
//

import Foundation
import UIKit
extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        let image = UIImageView(image: UIImage(named: "u"))
        image.center = self.center
        image.alpha = 0.2
        self.backgroundView = messageLabel
        self.backgroundView?.addSubview(image)
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
