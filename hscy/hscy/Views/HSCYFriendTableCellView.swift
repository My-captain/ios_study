//
//  HSCYFriendTableCellView.swift
//  hscy
//
//  Created by 周子聪 on 2017/10/26.
//  Copyright © 2017年 marinfo. All rights reserved.
//

import UIKit

class HSCYFriendTableCellView: UITableViewCell {

    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var phoneNumLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
