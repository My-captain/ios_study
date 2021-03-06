//
//  HSCYAcceptOrRejectShareViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/10/26.
//  Copyright © 2017年 marinfo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

protocol ShareShipInfoProtocol {
    var shareInfo:String{
        get
    }
}

class HSCYAcceptOrRejectShareViewController: UIViewController {
    
    @IBOutlet weak var infoLB: UILabel!
    
    @IBAction func accept(_ sender: Any) {
        shareRequestResponse(agreeNum: "1")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func reject(_ sender: Any) {
        shareRequestResponse(agreeNum: "2")
        SVProgressHUD.showInfo(withStatus: "已拒绝")
        self.dismiss(animated: true, completion: nil)
    }
    var delegate:ShareShipInfoProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLB.text=self.delegate.shareInfo
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func shareRequestResponse(agreeNum:String) {
        let param=[
            "cyPhoneNum":UserDefaults.standard.string(forKey: "phoneNum")!,
            "friendsPhoneNum":getPhoneNum(),
            "agreeNum":agreeNum
            ]
        
        print("请求参数为：\(param)")
        
        Alamofire.request("http://218.94.74.231:9999/SeaProject/shareRequestResponse", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let dic = JSON(response).dictionaryObject as Dictionary<String,AnyObject>? {
                    if let state = dic["state"] as? Bool{
                        if state{
                            SVProgressHUD.showInfo(withStatus: "已同意")
                        }else {
                            //SVProgressHUD.showInfo(withStatus: "未能完成")
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "请求错误")
                    }
                }
            }
        }
    }
    
    func getPhoneNum() -> String {
        let str=self.delegate.shareInfo
        let phoneNum = str.components(separatedBy: "(").last?.components(separatedBy: ")").first
        return phoneNum!
    }

}
