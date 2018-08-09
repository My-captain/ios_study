//
//  HSCYCameraInfoTableViewController.swift
//  hscy
//
//  Created by dingjianxin on 2017/9/6.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Alamofire
import SwiftyJSON
protocol CameraCoordinateProperty{

    var cameraName:String{get set}

}
class HSCYCameraInfoTableViewController:UITableViewController{

    var delegate:CameraCoordinateProperty!
    var cameraInfoDic:Dictionary<String,String>!
let   keysOfCameraInfo=["cameraName","lng","lat","camera_address","camera_type","pitch","tilt","build_factory","expire_date","remark","kmdata","ip_addr","northangle"]
let nameOfCameraInfo=["监控名称","经度","纬度","位置","监控类型","俯仰角","监控摆角","生产产家","使用期限","备注信息","公里数","IP地址","朝向偏北角"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title="监控信息"
        // 设置代理
        self.tableView.delegate = self
        // 设置数据源
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib.init(nibName: "HSCYLeftRightTableCellView", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView=UIView()
        //        self.delegate.bridgeName
        let param = [
            "cameraName":self.delegate.cameraName
        ]

        
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getCameraInfo", method: .post, parameters: param).responseJSON{
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
                    self.cameraInfoDic=info as! Dictionary<String, String>
                    
                    self.tableView.reloadData()

                }
            }
        }

        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cameraInfoDic==nil {
            return 0
        }
        return nameOfCameraInfo.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYLeftRightTableCellView
        
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        cell.leftLabel?.text=nameOfCameraInfo[indexPath.row]
        let key=keysOfCameraInfo[indexPath.row]
        if cameraInfoDic[key] != nil&&cameraInfoDic[key] != ""{
            cell.rightLabel?.text=cameraInfoDic[key]!
        }else {
            cell.rightLabel?.text="暂无数据"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
