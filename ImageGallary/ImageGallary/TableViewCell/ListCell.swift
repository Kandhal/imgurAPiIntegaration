//
//  ListCell.swift
//  ImageGallary
//
//  Created by Kindness on 03/01/24.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var additionalImagesLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
