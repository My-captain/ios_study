//
//  HSCYAddFriendViewController.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/26.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SnapKit
import SVProgressHUD

protocol PhoneNumProperty {
    
    var myPhoneNum:String{get set}
}

class HSCYAddFriendViewController:UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource{
    var cancellButton:UIButton!
    var tableView:UITableView!
    var dataDics:[[String:AnyObject]] = []
    
    var delegate:PhoneNumProperty!
    var addFriendSearchBar:UISearchBar!
    var name: String=""
    var phoneNum: String=""
    var infoView:HSCYaddFriendInfoView!
    var  backgorundInfoView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor=UIColor.white
        
        initTableView()
        
        initBackgroundView()
        
        self.navigationItem.title="添加好友"
        
        addFriendSearchBar = UISearchBar(frame: CGRect(x:0, y:64, width:self.view.frame.width, height:44))
        addFriendSearchBar.layer.cornerRadius=10
        addFriendSearchBar.placeholder="输入好友姓名／完整手机号"
        addFriendSearchBar.searchBarStyle=UISearchBarStyle.minimal
        addFriendSearchBar.showsCancelButton=true
        self.view.addSubview(addFriendSearchBar)
        addFriendSearchBar.delegate=self
        let subViews:Array=addFriendSearchBar.subviews
        let subView:UIView=subViews.first!
        for view:UIView in subView.subviews
        {
            if(view .isKind(of: UIButton.self)){
                cancellButton=view as! UIButton
                cancellButton.setTitle("取消", for: UIControlState.normal)
                cancellButton.tintColor=UIColor.gray
                break
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        let btnTitle=cancellButton?.titleLabel?.text
        if(btnTitle=="取消"){
            addFriendSearchBar.resignFirstResponder()
            self.dataDics=[]
            tableView.reloadData()
            
        }
        else {
            
        }
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.hasPrefix(" "))!||(searchBar.text?.characters.count==0){
            cancellButton.isEnabled=true
            cancellButton.setTitle("取消", for:UIControlState.normal)
            self.dataDics=[]
            tableView.reloadData()
        }
        else {
            self.view.addSubview(tableView)
            cancellButton.setTitle("搜索", for: UIControlState.normal)
            let numText=UserDefaults.standard.string(forKey: "phoneNum")!
            let text=searchBar.text!
            let param = [
                "cyPhoneNum":numText,
                "textContent":text
            ]
            
            Alamofire.request("http://218.94.74.231:9999/SeaProject/getFriendsNameAndNum", method:.post, parameters: param ).responseJSON{
                
                (returnResult) in
                if let response=returnResult.result.value{
                    
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    self.tableView.reloadData()
                }
                
                
            }
            
            
            
        }
    }
    func initTableView(){
        tableView=UITableView.init(frame: CGRect(x:0,y:108,width:self.view.bounds.width,height:self.view.bounds.height), style: UITableViewStyle.plain)
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=UITableViewAutomaticDimension
        tableView.tableFooterView=UIView()
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataDics.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        if(cell == nil){
            cell = UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
        }
        cell?.textLabel?.text=dataDics[indexPath.row]["name"] as?String
        cell?.detailTextLabel?.text=dataDics[indexPath.row]["phoneNum"] as? String
        
        cell?.imageView?.image=#imageLiteral(resourceName: "friend_head")
        
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        infoView=Bundle.main.loadNibNamed("HSCYaddFriendInfoView", owner: self, options: nil)!.first as! HSCYaddFriendInfoView
        
 
        self.view.addSubview(backgorundInfoView)
        self.view.addSubview(infoView)
        
        infoView.nameLabel.text=dataDics[indexPath.row]["name"] as?String
        infoView.phoneNumLabel.text=dataDics[indexPath.row]["phoneNum"] as? String
        
        infoView.snp.makeConstraints{ (make) -> Void in
            make.center.equalToSuperview()
            make.size.equalTo(view).multipliedBy(0.75)
        }
        infoView.addFriendBtn.addTarget(self, action: #selector(addFriendBtnAction), for: UIControlEvents.touchUpInside)
        
        addFriendSearchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        addFriendSearchBar.resignFirstResponder()
    }
    
    
    //加好友响应事件
    func addFriendBtnAction(){
        SVProgressHUD.showInfo(withStatus: "好友申请发送成功，请等待对方确认！")
        self.navigationController?.popViewController(animated: true)
    }
    
    func  initBackgroundView(){
        backgorundInfoView=UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        backgorundInfoView.backgroundColor=UIColor.white
        backgorundInfoView.alpha=0.6
        //        设置view可以点击
        backgorundInfoView.isUserInteractionEnabled=true
        //        定义一个UITapGestureRecognizer
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(HSCYAddFriendViewController.tapClick))
        backgorundInfoView.addGestureRecognizer(tap)
        
        
    }
    
    func tapClick(){
        backgorundInfoView.removeFromSuperview()
        infoView.removeFromSuperview()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        addFriendSearchBar.resignFirstResponder()
    }
}
