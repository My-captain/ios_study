//
//  HSCYLoginViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/8/22.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class HSCYLoginViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var countNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginView: UIButton!
    
    @IBAction func login(_ sender: UIButton) {
        let phoneNum=countNameTF.text!
        let pwd=passwordTF.text!
        let param=["phoneNum":phoneNum,
                   "pwd":pwd]
        if phoneNum==""{
            SVProgressHUD.showInfo(withStatus: "手机号不能为空")
        }else if pwd==""{
            SVProgressHUD.showInfo(withStatus: "请输入密码")
        }
        else if !validatePhonoNum(phono: phoneNum){
            SVProgressHUD.showInfo(withStatus: "请输入正确的手机号")
        }else{
            Alamofire.request("http://218.94.74.231:9999/SeaProject/login", method: .post, parameters: param).responseJSON{
                (returnResult) in
                if let response=returnResult.result.value{
                    if let responseJSON=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?{
                        if  responseJSON["status"] == nil{
                            let shipID=responseJSON["ship_id"] as! String
                            let showName=responseJSON["show_name"] as! String
                            
                            if shipID=="false"{
                                SVProgressHUD.showInfo(withStatus: responseJSON["show_name"] as? String)
                            }else{
                                SVProgressHUD.showInfo(withStatus: "登陆成功")
                                
                                let cbsbh=responseJSON["cbsbh"] as! String
                                let cnName=responseJSON["cn_name"] as! String
                                let time=responseJSON["time"] as! String
                                
                                UserDefaults.standard.set(phoneNum, forKey: "phoneNum")
                                UserDefaults.standard.set(pwd, forKey: "pwd")
                                UserDefaults.standard.set(shipID, forKey: "shipID")
                                UserDefaults.standard.set(showName, forKey: "showName")
                                UserDefaults.standard.set(cbsbh, forKey: "cbsbh")
                                UserDefaults.standard.set(cnName, forKey: "cnName")
                                UserDefaults.standard.set(time, forKey: "time")
                                UserDefaults.standard.synchronize()
                                
                                let sb = UIStoryboard(name: "Main", bundle: nil)
                                let vc = sb.instantiateViewController(withIdentifier: "HSCYTabBarController") as! HSCYTabBarController
                                UIApplication.shared.delegate?.window??.rootViewController=vc
                            }

                        }else{
                            SVProgressHUD.showInfo(withStatus: "服务器正在维护")
                        }
                    }
                }
            }
        }
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        countNameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        loginView.layer.cornerRadius=CGFloat(3.14)
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")
        if phoneNum != nil {
            countNameTF.text=phoneNum
        }
    }
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
