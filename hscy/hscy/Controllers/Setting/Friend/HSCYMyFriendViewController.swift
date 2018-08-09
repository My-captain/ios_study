//
//  HSCYMyFriendViewController.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/26.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
class HSCYMyFriendViewController:UIViewController,UITableViewDelegate,UITableViewDataSource {
    var deleteBtn:UIButton!
    var tableView:UITableView!
     var dataDics:[[String:String]] = []
    override func viewDidLoad() {
         super.viewDidLoad()
        initTableView()
        
        setupRefresh()
        
        let rightItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addBtnAction))
        
        self.navigationItem.rightBarButtonItem = rightItem
        
        getFriendsMsg()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func addBtnAction(){
     let vc=HSCYAddFriendViewController()
     self.navigationController?.pushViewController(vc, animated: true)
    
        
    }
    
    func getFriendsMsg(){
        let param=[
            "cyPhoneNum":UserDefaults.standard.string(forKey: "phoneNum")!
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getFriendsMsg", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response = returnResult.result.value{
                if let array = JSON(response).arrayObject as? [Dictionary<String,String>]{
                    self.dataDics = array
                    self.tableView.reloadData()
                }
            }
        }

    }
    func initTableView(){
        tableView=UITableView.init(frame: CGRect(x:0,y:64,width:self.view.bounds.width,height:self.view.bounds.height-108), style: UITableViewStyle.plain)
        tableView.register(UINib.init(nibName: "HSCYMyFriendCellView", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=60
        tableView.separatorColor=UIColor.clear
        tableView.tableFooterView=UIView()
        
        self.automaticallyAdjustsScrollViewInsets=false
        self.view.addSubview(tableView)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataDics.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYMyFriendCellView
        cell.nameLabel.text=dataDics[indexPath.row]["name"]
        cell.phoneLabel.text=dataDics[indexPath.row]["phoneNum"]
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.deleteBtn.tag=indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnAction(sender:)), for: UIControlEvents.touchUpInside)
        
         return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    //删除好友响应事件
    func deleteBtnAction(sender:UIButton){
        let cyPhoneNum=UserDefaults.standard.string(forKey: "phoneNum")!
        let friendPhoneNum=dataDics[sender.tag]["phoneNum"]!
        let param=["cyPhoneNum":cyPhoneNum,"friendsPhoneNum":friendPhoneNum]
        
        Alamofire.request("http://218.94.74.231:9999/SeaProject/deleteFriendsMsg", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if let response=returnResult.result.value{
                if let dic = JSON(response).dictionaryObject as [String:AnyObject]?{
                    if let isOK=dic["state"] as? Bool{
                        if isOK{
                            SVProgressHUD.showInfo(withStatus: "删除好友成功")
                            self.getFriendsMsg()
                        }else{
                            SVProgressHUD.showInfo(withStatus: "删除好友失败")
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "服务器错误")
                    }
                    
                    
                    
                }
            }
            
            
        }

    
    }
   
    func setupRefresh() {
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        refreshControl.tintColor = UIColor.gray
        refreshControl.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl)
    }
    
    func refreshDrag(refreshControl:UIRefreshControl) {
        refreshControl.endRefreshing()
        getFriendsMsg()
    }
}
