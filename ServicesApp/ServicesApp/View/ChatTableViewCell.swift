//
//  ChatTableViewCell.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 03/06/1443 AH.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatView: UIView!{
        didSet{
            chatView.layer.cornerRadius = 10
            chatView.layer.shadowRadius = 5
        }
    }
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
