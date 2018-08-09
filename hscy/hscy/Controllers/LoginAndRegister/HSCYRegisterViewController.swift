//
//  HSCYRegisterViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/8/24.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
import SwiftyJSON

class HSCYRegisterViewController: UIViewController {
    
    @IBOutlet weak var yzmBtnView: UIButton!
    @IBOutlet weak var registerBtnView: UIButton!
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var yzmTF: UITextField!
    @IBOutlet weak var sbhTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var idCardTF: UITextField!
    @IBOutlet weak var pwd1TF: UITextField!
    @IBOutlet weak var pwd2TF: UITextField!
    
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
    
    @IBAction func getYZM(_ sender: UIButton) {
        let phoneNum=phoneNumTF.text!
        if phoneNum==""{
            SVProgressHUD.showInfo(withStatus: "手机号不能为空")
        }else if !validatePhonoNum(phono: phoneNum){
            SVProgressHUD.showInfo(withStatus: "请输入正确的手机号")
        }else{
            
            self.isCounting=true
            
            let param=[
                "phoneNum":phoneNum
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
    @IBAction func registerCount(_ sender: UIButton) {
        switch "" {
        case phoneNumTF.text!:
            SVProgressHUD.showInfo(withStatus: "手机号不能为空")
        case yzmTF.text!:
            SVProgressHUD.showInfo(withStatus: "验证码不能为空")
        case sbhTF.text!:
            SVProgressHUD.showInfo(withStatus: "船舶识别号不能为空")
        case nameTF.text!:
            SVProgressHUD.showInfo(withStatus: "姓名不能为空")
        case idCardTF.text!:
            SVProgressHUD.showInfo(withStatus: "身份证号码不能为空")
        case pwd1TF.text!:
            SVProgressHUD.showInfo(withStatus: "密码不能为空")
        case pwd2TF.text!:
            SVProgressHUD.showInfo(withStatus: "请输入验证码")
        default:
            if pwd1TF.text! != pwd2TF.text!{
                SVProgressHUD.showInfo(withStatus: "两次输入的密码不一致")
            }else{
                let param=[
                    "cbsbh":sbhTF.text!,
                    "crewName":nameTF.text!,
                    "crewIDNum":idCardTF.text!,
                    "phoneNum":phoneNumTF.text!,
                    "pwd":pwd1TF.text!,
                    "verifyCode":yzmTF.text!
                ]
                Alamofire.request("http://218.94.74.231:9999/SeaProject/register", method: .post, parameters: param).responseJSON{
                    (returnResult) in
                    if let response=returnResult.result.value{
                        let dic=JSON(response).dictionaryObject! as Dictionary<String, AnyObject>
                        if let isOK=dic["state"] as? Bool{
                            
                            
                            if isOK{
                                SVProgressHUD.showInfo(withStatus:"注册成功")
                                //回到登陆界面
                                UserDefaults.standard.set(self.phoneNumTF.text!, forKey: "phoneNum")
                                UserDefaults.standard.set(self.nameTF.text!, forKey: "name")
                                self.dismiss(animated: true, completion: nil)
                            }else{
                                SVProgressHUD.showInfo(withStatus: dic["reason"] as? String)
                            }
                        }
                    }
                }
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        yzmBtnView.layer.cornerRadius=3.0
        registerBtnView.layer.cornerRadius=3.0
    }
    
    @objc private func updateTime() {
        counter -= 1
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        yzmBtnView.resignFirstResponder()
        registerBtnView.resignFirstResponder()
        phoneNumTF.resignFirstResponder()
        yzmTF.resignFirstResponder()
        sbhTF.resignFirstResponder()
        nameTF.resignFirstResponder()
        idCardTF.resignFirstResponder()
        pwd1TF.resignFirstResponder()
        pwd2TF.resignFirstResponder()
    }
    
    @IBAction func dismissVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
