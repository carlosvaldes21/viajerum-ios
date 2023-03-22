//
//  VerticalTableViewCell.swift
//  Viajerum
//
//  Created by Carlos Valdes on 17/03/23.
//

import UIKit

class VerticalTableViewCell: UITableViewCell {
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var costContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        placeImageView.layer.borderWidth = 1.0
        placeImageView.layer.masksToBounds = false
        placeImageView.layer.borderColor = UIColor.white.cgColor
        placeImageView.layer.cornerRadius = 20
        placeImageView.clipsToBounds = true
        costContainer.layer.cornerRadius = 15
        costContainer.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
            // cell rounded section
            containerView.layer.cornerRadius = 20.0
           
            

            
            // cell shadow section
        containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
            containerView.layer.shadowRadius = 4.0
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.masksToBounds = false
            
        }
    
}
