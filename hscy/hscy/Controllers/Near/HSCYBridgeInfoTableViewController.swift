//
//  HSCYBridgeInfoTableViewController.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/4.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Alamofire
import SwiftyJSON
protocol BridgeCoordinateProperty {
   
    var bridgeName:String{get set}
}


class HSCYBridgeInfoTableViewController: UITableViewController {
     var delegate:BridgeCoordinateProperty!
    var bridgeInfoDic:Dictionary<String,String>!
    let nameOfBridgeInfo=["桥梁名称","桥梁地址","经度","纬度","桥梁类型","通航孔数","桥墩数量","最高通航水位","最低通航水位","净高","长度","建成时间","使用年限","使用状态","负责人姓名","所属单位","负责人电话","负责人手机","备注"]
    let keysOfBridgeInfo=["bridgeName","bridge_address","lng","lat","bridge_type","hole_count","pier_count","max_waterlevel","min_waterlevel","net_height","bridge_len","build_time","use_year","use_state","mgr_name","mgr_depart","mgr_phone","mgr_mobile","remark"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title="桥梁信息"
        // 设置代理
        self.tableView.delegate = self
        // 设置数据源
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
    
        self.tableView.register(UINib.init(nibName: "HSCYLeftRightTableCellView", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.tableView.tableFooterView=UIView()
//        self.delegate.bridgeName
        let param = [
            "bridgeName":self.delegate.bridgeName
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getBridgeInfo", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                var info=JSON(response).dictionaryObject! as Dictionary<String, AnyObject>
                if !info.isEmpty
                {
                    print("-----info\(info)")
                   let lng=info["lng"] as! Double
                info["lng"]=String(format:"%.6f",lng) as AnyObject
                   let lat=info["lat"] as! Double
                   info["lat"]=String(format:"%.6f",lat) as AnyObject

                    if let max_waterlevel=info["max_waterlevel"] as? Float{
                   info["max_waterlevel"]=String(format: "%.1f", max_waterlevel) as AnyObject
                    }
                    else if let max_waterlevel=info["max_waterlevel"] as? Int{
                        info["max_waterlevel"]=String(format: "%.1f", max_waterlevel) as AnyObject
                    }else{
                    info["max_waterlevel"]=nil
                    }
                    
                    if let min_waterlevel=info["min_waterlevel"]as?Float{
                   info["min_waterlevel"]=String(format: "%.1f", min_waterlevel) as AnyObject
                    }else{
                    info["min_waterlevel"]=nil
                    }
                    if let net_height=info["net_height"]as?Int{
                   info["net_height"]=String(net_height) as AnyObject
                    }else{
                        info["net_height"]=nil
                    }

                    if let bridge_len=info["bridge_len"]as?Float{
                        info["bridge_len"]=String(format: "%.2f",bridge_len) as AnyObject
                    }else{
                        info["bridge_len"]=nil
                    }

                    if let hole_count = info["hole_count"]as?Int{
                   info["hole_count"]=String(hole_count) as AnyObject
                    }else{
                        info["hole_count"]=nil
                    }
                    if let pier_count = info["pier_count"]as?Int{
                   info["pier_count"]=String(pier_count) as AnyObject
                    }else{
                        info["pier_count"]=nil
                    }

                    if let use_year = info["use_year"]as?Int{
                   info["use_year"]=String(use_year) as AnyObject
                    }else{
                        info["use_year"]=nil
                    }

                    
                   self.bridgeInfoDic=info as! Dictionary<String, String>
   
                   self.tableView.reloadData()
                
                }
            }
        }
    }
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bridgeInfoDic==nil {
            return 0
        }
        return nameOfBridgeInfo.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as!
        HSCYLeftRightTableCellView
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.leftLabel?.text=nameOfBridgeInfo[indexPath.row]
        let key=keysOfBridgeInfo[indexPath.row]
        if bridgeInfoDic[key] != nil&&bridgeInfoDic[key] != ""{
            cell.rightLabel?.text=bridgeInfoDic[key]!
        }else {
             cell.rightLabel?.text="暂无数据"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }







}


    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
