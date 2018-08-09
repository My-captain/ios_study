//
//  HSCYShareBoatViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/10/24.
//  Copyright © 2017年 marinfo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
protocol ShareBoatParamProperty {
    var shareParam:[String:String] {get set}
}

class HSCYShareBoatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var delegate:ShareBoatParamProperty!
    
    var tableView:UITableView!
    
    var friendsInfoArray:[Dictionary<String,String>]!=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        self.navigationItem.title = "船舶分享"
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 72, width: UIScreen.main.bounds.width, height: 24))
        //label.backgroundColor=UIColor.black
        //label.text = "请点击要分享的好友"
        let atrStr=NSMutableAttributedString.init(string: "请点击要分享的好友", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 19)])
        atrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGray, range: NSMakeRange(0, 9))
        label.attributedText=atrStr
        label.textAlignment=NSTextAlignment.center
        
        self.view.addSubview(label)
        
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 250))
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib.init(nibName: "HSCYFriendTableCellView", bundle: nil), forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)

        getFriendsMsg()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYFriendTableCellView
        
        cell.nameLB.text=friendsInfoArray[indexPath.row]["name"]
        cell.phoneNumLB.text=friendsInfoArray[indexPath.row]["phoneNum"]
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shareShipMessageToFriends(indexPath: indexPath)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getFriendsMsg() {
        let param=[
            "cyPhoneNum":UserDefaults.standard.string(forKey: "phoneNum")!
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getFriendsMsg", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response = returnResult.result.value{
                if let array = JSON(response).arrayObject as? [Dictionary<String,String>]{
                    self.friendsInfoArray = array
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func shareShipMessageToFriends(indexPath:IndexPath) {
        var param=self.delegate.shareParam
        param["sharePhoneNum"] = friendsInfoArray[indexPath.row]["phoneNum"]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/shareShipMessageToFriends", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response = returnResult.result.value{
                if let dic = JSON(response).dictionaryObject as Dictionary<String,AnyObject>?{
                    if let isOK = dic["state"] as? Bool{
                        if isOK{
                            SVProgressHUD.showInfo(withStatus: "分享成功")
                        }else{
                            SVProgressHUD.showInfo(withStatus: "您已经分享过该船只")
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "网络错误")
                    }
                }
            }
        }
    }

}
