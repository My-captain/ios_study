//
//  HSCYAcceptOrRejectViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/10/20.
//  Copyright © 2017年 marinfo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

protocol AddFriendInfoProtocol {
    var info:String{
        get
    }
    
}
class HSCYAcceptOrRejectViewController: UIViewController {
    @IBOutlet weak var infoLB: UILabel!
    var delegate:AddFriendInfoProtocol!
    @IBAction func accept(_ sender: UIButton) {
        addPersonReplayRequest(agreeNum:"1")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func reject(_ sender: UIButton) {
        addPersonReplayRequest(agreeNum:"2")
        SVProgressHUD.showInfo(withStatus: "已拒绝")
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        infoLB.text = delegate?.info
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func addPersonReplayRequest(agreeNum:String) {
        let param=[
            "cyPhoneNum":UserDefaults.standard.string(forKey: "phoneNum")!,
            "friendsPhoneNum":getPhoneNum(),
            "agreeNum":agreeNum
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/addPersonReplayRequest", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let dic = JSON(response).dictionaryObject as Dictionary<String,AnyObject>? {
                    if let state = dic["state"] as? Bool{
                        if state{
                            SVProgressHUD.showInfo(withStatus: "已同意")
                        }else{
                            
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "请求错误")
                    }
                }
            }
        }
    }
    
    func getPhoneNum() -> String {
        let str=self.delegate.info
        let phoneNum = str.components(separatedBy: "(").last?.components(separatedBy: ")").first
        return phoneNum!
    }
}
