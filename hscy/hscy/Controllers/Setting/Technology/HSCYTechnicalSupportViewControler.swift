//
//  HSCYTechnicalSupportViewControler.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/14.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import UIKit

class HSCYTechnicalSupportViewControler:UIViewController{

        
    @IBOutlet var joinGroupBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        joinGroupBtn.addTarget(self, action: #selector(btnAction), for: UIControlEvents.touchUpInside)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    
    func  btnAction(){
        let  qqUrl="https://qm.qq.com/cgi-bin/qm/qr?k=DSOr2adcOaQKOBYDpKWn4QhyUxD0Y72o"
        if let url = URL(string: qqUrl) {
            //根据iOS系统版本，分别处理
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

    








