//
//  MovieCollectionViewCell.swift
//  SimpleMP4
//
//  Created by 藤原 達郎 on 2016/01/04.
//  Copyright (c) 2016年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var filetypeLabel: UILabel!
    
    @IBOutlet var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
