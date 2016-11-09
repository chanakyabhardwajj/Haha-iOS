//
//  ErrorCell.swift
//  Haha
//
//  Created by Chanakya Bhardwaj on 08/11/2016.
//  Copyright © 2016 Chanakya Bhardwaj. All rights reserved.
//

import UIKit

protocol ErrorCellDelegate: class {
    func tryAgain()
}

class ErrorCell: UITableViewCell {
    weak var delegate: ErrorCellDelegate?
    
    @IBAction func tryAgain(_ sender: UIButton) {
        if let del = delegate {
            del.tryAgain()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
