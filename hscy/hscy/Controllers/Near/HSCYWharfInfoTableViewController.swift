//
//  HSCYWharfInfoTableViewController.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/6.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Alamofire
import SwiftyJSON
protocol WharfCoordinateProperty {
    
    var wharfName:String{get set}
}

class HSCYWharfInfoTableViewController:UITableViewController{
    var delegate:WharfCoordinateProperty!
    var wharfInfoDic:Dictionary<String,String>!
     let nameOfBridgeInfo=["码头名称","经度","纬度","码头地址","归属区域","负责人姓名","负责人职位","负责人电话","负责人手机号","备注","货物类型","装卸泊位","泊位吨数","起吊能力"]
    let keysOfWharfInfo=["wharfName","lng","lat","wharf_address","region","mgr_name","mgr_duty","mgr_phone","mgr_mobile","remark","cargo_type","berth_count","berth_ton","elevating_capacity"]
   
override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title="码头信息"
    // 设置代理
    self.tableView.delegate = self
    // 设置数据源
    self.tableView.dataSource = self
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.register(UINib.init(nibName: "HSCYLeftRightTableCellView", bundle: nil), forCellReuseIdentifier: "cell")
    self.tableView.tableFooterView=UIView()
    //        self.delegate.bridgeName
    let param = [
        "wharfName":self.delegate.wharfName
]
    Alamofire.request("http://218.94.74.231:9999/SeaProject/getWharfInfo", method: .post, parameters: param).responseJSON{
        (returnResult) in
        if let response=returnResult.result.value{
            var info=JSON(response).dictionaryObject! as Dictionary<String, AnyObject>
            if !info.isEmpty
            {
                let lng=info["lng"] as! Double
                info["lng"]=String(format:"%.6f",lng) as AnyObject
                let lat=info["lat"] as! Double
                info["lat"]=String(format:"%.6f",lat) as AnyObject
                if let berth_count=info["berth_count"]as?Int{
                    info["berth_count"]=String(berth_count) as AnyObject
                }else{
                    info["berth_count"]=nil
                }
                if let berth_ton=info["berth_ton"]as?Int{
                    info["berth_ton"]=String(berth_ton) as AnyObject
                }else{
                    info["berth_ton"]=nil
                }
                if let elevating_capacity=info["elevating_capacity"]as?Int{
                    info["elevating_capacity"]=String(elevating_capacity) as AnyObject
                }else{
                    info["elevating_capacity"]=nil
                }

               
                
                self.wharfInfoDic=info as! Dictionary<String, String>
                
                self.tableView.reloadData()
        }
        }
        }

        }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if wharfInfoDic==nil {
            return 0
        }
        return nameOfBridgeInfo.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYLeftRightTableCellView
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.leftLabel?.text=nameOfBridgeInfo[indexPath.row]
        let key=keysOfWharfInfo[indexPath.row]
        if wharfInfoDic[key] != nil&&wharfInfoDic[key] != ""{
            cell.rightLabel?.text=wharfInfoDic[key]!
        }else {
            cell.rightLabel?.text="暂无数据"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
    








}
