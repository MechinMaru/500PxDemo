//
//  PhotoCollectionViewCell.swift
//  500PxDemo
//
//  Created by MECHIN on 5/29/18.
//  Copyright © 2018 MECHIN. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureLayoutWithModel(_ model: Photo) {
        imageView.image = nil
        
        if let imageUrl = URL(string: model.imageUrl[0]),
            let title = model.name,
            let user = model.user,
            let fullname = user.fullname {
                authorLabel.text = fullname
                titleLabel.text = title
                imageView.af_setImage(withURL: imageUrl)
        
        }
    }
}
