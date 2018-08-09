//
//  HSCYaddFriendInfoView.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/29.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import UIKit

class HSCYaddFriendInfoView:UIView{

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var phoneNumLabel: UILabel!
    
    @IBOutlet weak var addFriendBtn: UIButton!

//    @IBAction func addBtnAction(_ sender: Any) {
//          SVProgressHUD.showInfo(withStatus: "好友申请发送成功，请等待对方确认！")
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame=UIScreen.main.bounds
    }

    
}
