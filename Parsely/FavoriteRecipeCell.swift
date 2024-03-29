//
//  FavoriteRecipeCell.swift
//  Parsely
//
//  Created by Gyandeep Reddy on 4/22/22.
//

import UIKit

class FavoriteRecipeCell: UITableViewCell {

    @IBOutlet weak var recipePhotoView: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
