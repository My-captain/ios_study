//
//  HSCYChangePwdViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/9/11.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import SVProgressHUD
import Alamofire
import SwiftyJSON

class HSCYChangePwdViewController:UIViewController{
    
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var yzmTF: UITextField!
    @IBOutlet weak var pwd1TF: UITextField!
    @IBOutlet weak var pwd2TF: UITextField!
    
    @IBOutlet weak var yzmBtnView: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
    
    //var yzm:String!
    
    var timer:Timer!
    private var counter: Int = 0 {
        willSet {
            yzmBtnView.setTitle("重新获取\(newValue)秒", for: .normal)
            if newValue <= 0 {
                yzmBtnView.setTitle("获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                counter = 60
                yzmBtnView.setTitleColor(UIColor.black, for: .normal)
            } else {
                timer?.invalidate()
                timer = nil
                yzmBtnView.setTitleColor(UIColor.black, for: .normal)
            }
            yzmBtnView.isEnabled = !newValue
        }
    }

    @IBAction func getYzm(_ sender: UIButton) {
        if phoneNumTF.text==""{
            SVProgressHUD.showInfo(withStatus: "手机号不能为空")
        }else if !validatePhonoNum(phono: phoneNumTF.text!){
            SVProgressHUD.showInfo(withStatus: "手机号不存在")
        }else{
            self.isCounting=true
            let param=[
                "phoneNum":phoneNumTF.text!
            ]
            Alamofire.request("http://218.94.74.231:9999/SeaProject/sendVerifyCode", method: .post, parameters: param).responseJSON{
                (returnResult) in
                if let response=returnResult.result.value{
                    if let responseJSON=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?
                    {
                        if let isOK=responseJSON["state"] as? Bool{
                            if isOK{
                                SVProgressHUD.showInfo(withStatus: "短信已发出，请注意查收")
                            }
                        }else{
                            SVProgressHUD.showInfo(withStatus: responseJSON["reason"] as? String)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func changePwd(_ sender: UIButton) {
        if phoneNumTF.text==""{
            SVProgressHUD.showInfo(withStatus: "手机号不能为空")
        }else if pwd1TF.text==""{
            SVProgressHUD.showInfo(withStatus: "请输入新密码")
        }else if pwd2TF.text==""{
            SVProgressHUD.showInfo(withStatus: "请再输入一次新密码")
        }else if pwd1TF.text! != pwd2TF.text!{
            SVProgressHUD.showInfo(withStatus: "您两次输入的密码不一致")
        }else if !validatePhonoNum(phono: phoneNumTF.text!){
            SVProgressHUD.showInfo(withStatus: "手机号不存在")
        }else if yzmTF.text==""{
            SVProgressHUD.showInfo(withStatus: "请输入验证码")
        }else{
            let param=[
                "phoneNum":phoneNumTF.text!,
                "newPwd":pwd1TF.text!,
                "verifyCode":yzmTF.text!
            ]
            
            Alamofire.request("http://218.94.74.231:9999/SeaProject/forgetPwd", method: .post, parameters: param).responseJSON{
                (returnResult) in
                if let response=returnResult.result.value{
                    let dic=JSON(response).dictionaryObject! as Dictionary<String, AnyObject>
                    if let isOK=dic["state"] as? Bool{
                        if isOK{
                            SVProgressHUD.showInfo(withStatus: dic["reason"] as? String)
                            //回到登陆界面
                            UserDefaults.standard.removeObject(forKey: "pwd")
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sb.instantiateViewController(withIdentifier: "HSCYLoginViewController") as! HSCYLoginViewController
                            UIApplication.shared.delegate?.window??.rootViewController=vc
                        }else{
                            SVProgressHUD.showInfo(withStatus: dic["reason"] as? String)
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yzmBtnView.layer.cornerRadius=CGFloat(3.14)
        changeBtn.layer.cornerRadius=CGFloat(3.14)
    }
    @objc private func updateTime() {
        counter -= 1
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pwd1TF.resignFirstResponder()
        pwd2TF.resignFirstResponder()
        phoneNumTF.resignFirstResponder()
        yzmTF.resignFirstResponder()
    }
}
