//
//  HorizontalCollectionViewCell.swift
//  Viajerum
//
//  Created by Carlos Valdes on 17/03/23.
//

import UIKit

class HorizontalCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
            // cell rounded section
        placeImageView.layer.cornerRadius = 20.0
        
        //viewContainer.layer.masksToBounds = true
            
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        viewContainer.layer.shadowRadius = 6.0
        viewContainer.layer.shadowOpacity = 0.7

        }

}
