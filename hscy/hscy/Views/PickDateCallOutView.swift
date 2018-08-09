//
//  PickDateCallOutView.swift
//  hscy
//
//  Created by 周子聪 on 2017/9/6.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
class PickDateCallOutView: UIView {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    @IBAction func cancelPick(_ sender: UIBarButtonItem) {
        self.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame=UIScreen.main.bounds
    }
}
