//
//  CategoryTableViewCell.swift
//  500PxDemo
//
//  Created by MECHIN on 5/27/18.
//  Copyright © 2018 MECHIN. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureLayout(_ model: CategoryType) {
        categoryTitleLabel.text = model.categoryName
    }
}
