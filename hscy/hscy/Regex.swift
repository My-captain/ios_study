//
//  Regex.swift
//  hscy
//
//  Created by 周子聪 on 2017/8/29.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
func validatePhonoNum(phono: String) -> Bool {
    //手机号以13,15,17,18开头，八个 \d 数字字符
    let phoneString = "^((13[0-9])|(15[^4])|(18[0-9])|(17[3,6,7,8])|(147))\\d{8}$"
    let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneString)
    return phonePredicate.evaluate(with: phono)
}
