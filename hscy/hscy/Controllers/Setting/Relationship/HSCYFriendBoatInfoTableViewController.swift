//
//  HSCYFriendBoatInfoTableViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/10/26.
//  Copyright © 2017年 marinfo. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol FriendShipProperty {
    var paramCBSBH:String{
        get
    }
}
class HSCYFriendBoatInfoTableViewController:UITableViewController{
    var delegate:FriendShipProperty!
    var boatInfoDic:Dictionary<String, String>!
    let namesOfBoatInfo=["船舶名称","船舶所有人","手机号码","MMSI","船舶宽度","船舶长度","总吨","净吨","总载净吨","船舶类型","船舶型深"]
    let keysOfBoatInfo=["cn_name","owner","telephone","mmsi","width","length","max_weight","dead_weight","holding_weight","ship_type","depth"]
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.navigationItem.title="好友船舶信息"
        //self.tableView=UITableView()
        // 设置代理
        self.tableView.delegate = self
        // 设置数据源
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.register(UINib.init(nibName: "HSCYLeftRightTableCellView", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.tableView.tableFooterView=UIView()
        
        requestAndRecieveData()
        setupRefresh()
    }
    
    func requestAndRecieveData() {
        let cbsbh=self.delegate.paramCBSBH
        let param = [
            "cbsbh": cbsbh.uppercased()//cn必须大写
        ]
        
        Alamofire.request("http://218.94.74.231:9999/SeaProject/boatInfo", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                self.boatInfoDic=JSON(response).dictionaryObject as? Dictionary<String, String>
                if self.boatInfoDic != nil
                {
                    let width=(self.boatInfoDic["width"]! as NSString).floatValue/100
                    let length=(self.boatInfoDic["length"]! as NSString).floatValue/100
                    self.boatInfoDic["width"] = String(format: "%.2f" , width) as String + " m"
                    self.boatInfoDic["length"] = String(format: "%.2f" , length) as String + " m"
                    self.boatInfoDic["depth"] = self.boatInfoDic["depth"]!+" m"
                    self.boatInfoDic["max_weight"] = self.boatInfoDic["max_weight"]!+" t"
                    self.boatInfoDic["dead_weight"] = self.boatInfoDic["dead_weight"]!+" t"
                    self.boatInfoDic["holding_weight"] = self.boatInfoDic["holding_weight"]!+" t"

                    self.tableView.reloadData()
                }
            }
        }
    }
    //MARK: 实现UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if boatInfoDic==nil {
            return 0
        }
        return namesOfBoatInfo.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYLeftRightTableCellView
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.leftLabel?.text=namesOfBoatInfo[indexPath.row]
        let key=keysOfBoatInfo[indexPath.row]
        cell.rightLabel?.text=boatInfoDic[key]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func setupRefresh() {
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl)
    }
    
    func refreshDrag(refreshControl:UIRefreshControl) {
        refreshControl.endRefreshing()
        
        requestAndRecieveData()
    }
    
}

