

import Foundation
import UIKit

class SentMemesTableViewCell: UITableViewCell {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var bottomTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memeImageView.contentMode = .scaleAspectFill
        memeImageView.clipsToBounds = true

       // accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if self.isEditing{
//            self.contentView.frame.origin.x += 16.0
//        }
        
    }
    
}
