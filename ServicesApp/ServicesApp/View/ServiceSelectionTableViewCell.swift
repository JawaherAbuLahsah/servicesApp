//
//  ServiceSelectionTableViewCell.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit

class ServiceSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!{
        didSet{
            checkButton.layer.borderWidth = 0.5
            checkButton.layer.borderColor = UIColor.systemBlue.cgColor
            checkButton.layer.cornerRadius = checkButton.frame.size.width / 2.0
            checkButton.backgroundColor = .systemBackground
        }
    }
    
    
    var isCheck = false
    
    
    @IBAction func didTapCheck(_ sender: Any) {
        if isCheck{
            checkButton.backgroundColor = .systemBackground
            isCheck = false
        }else{
            checkButton.backgroundColor = .systemBlue
            isCheck = true
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
