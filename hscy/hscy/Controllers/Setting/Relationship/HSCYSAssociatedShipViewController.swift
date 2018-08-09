//
//  HSCYSAssociatedShipViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/9/11.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD


class HSCYSAssociatedShipViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ShareBoatParamProperty, FriendShipProperty {
    

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cbsbhTF: UITextField!
    
    var paramCBSBH: String=""
    
    var rightBtn:UIBarButtonItem!
    
    var shareParam: [String : String]=[:]
    
    var subView:UIView!
    var tableView1:UITableView!
    
    var relationShipsArray:[Dictionary<String, AnyObject>]=[]
    var friendShipsArray:[Dictionary<String,AnyObject>]=[]
    
    var selectedRow:Int = -1
    var usingShipIndex:Int!
    
    @IBAction func addCBSBH(_ sender: UIButton) {
        addRelationShip()
    }
    
    @IBAction func changeCBSBH(_ sender: UIButton) {
        changeRelationShip()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        rightBtn=UIBarButtonItem.init(image: UIImage.init(named: "boat_share"), style: UIBarButtonItemStyle.done, target: self, action: #selector(setShareParam))
        rightBtn.imageInsets=UIEdgeInsetsMake(5, 5, 5, 0)
        rightBtn.tintColor=UIColor.white
        self.navigationItem.rightBarButtonItem=rightBtn
        
        tableView.delegate=self
        tableView.dataSource=self
        tableView.tableFooterView=UIView()
        
        tableView1=UITableView.init(frame: CGRect.init(x: 40, y: 0, width: UIScreen.main.bounds.width-80, height: UIScreen.main.bounds.height-64-60-40))
        tableView1.delegate=self
        tableView1.dataSource=self
        tableView1.tableFooterView=UIView()
        tableView1.backgroundColor=UIColor.clear
        
        self.tableView.register(UINib.init(nibName: "HSCYSAssociatedShipCellView", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.tableView1.register(UINib.init(nibName: "HSCYSAssociatedShipCellView", bundle: nil), forCellReuseIdentifier: "cell")
        
        
        setupRefresh()
        
        getRelationShips()
        getFriendShips()
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: UIControlEvents.valueChanged)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableView==tableView{
            return relationShipsArray.count
        }else if self.tableView1==tableView{
            return friendShipsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYSAssociatedShipCellView
        if self.tableView==tableView{
            if indexPath.row==selectedRow{
                cell.boatSelectBtn.isSelected=true
                //print("selected")
            }else{
                cell.boatSelectBtn.isSelected=false
            }
            
            cell.shipNameLabel.text=relationShipsArray[indexPath.row]["ship_name"] as? String
            cell.deleteBtn.tag=indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deleteRelationShip(sender:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle=UITableViewCellSelectionStyle.none
            cell.backgroundColor=UIColor.init(red: 84/255, green: 188/255, blue: 212/255, alpha: 1.0)
            return cell
        }else{
            cell.boatSelectBtn.isSelected=true
            cell.shipNameLabel.text=friendShipsArray[indexPath.row]["ship_name"] as! String
            cell.deleteBtn.tag=indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deleteFriendShip(sender:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle=UITableViewCellSelectionStyle.none
            cell.backgroundColor=UIColor.init(red: 84/255, green: 188/255, blue: 212/255, alpha: 1.0)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView==self.tableView{
            selectedRow=indexPath.row
            tableView.reloadData()
        }else if tableView==self.tableView1{
            
            paramCBSBH = friendShipsArray[indexPath.row]["cbsbh"] as! String
            print("CBSBH:\(paramCBSBH)")
            let vc=HSCYFriendBoatInfoTableViewController()
            vc.delegate=self
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func getRelationShips() {
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")
        let param=[
            "phoneNum":phoneNum!,
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getRelationShips", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let dicArr=JSON(response).arrayObject as? [Dictionary<String, AnyObject>]{
                    if dicArr.count != 0 {
                        self.relationShipsArray=dicArr
                        for i in 0 ..< self.relationShipsArray.count{
                            if (self.relationShipsArray[i]["isselect"] as? Int)==1 {
                                self.selectedRow=i
                                self.usingShipIndex=i
                            }
                        }
                        self.tableView.reloadData()
                    }
                }else{
                    SVProgressHUD.showInfo(withStatus: "服务器错误")
                }
            }
        }

    }
  
    func addRelationShip() {
        if cbsbhTF.text=="" {
            SVProgressHUD.showInfo(withStatus: "请输入船舶识别号")
        }else{
            let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")
            let param=[
                "phoneNum":phoneNum!,
                "cbsbh":cbsbhTF.text!
            ]
            Alamofire.request("http://218.94.74.231:9999/SeaProject/addRelationShip", method: .post, parameters: param).responseJSON{
                (returnResult) in
                if let response=returnResult.result.value{
                    if let info=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?{
                        if info["state"] != nil{
                            if info["state"] as! Bool{
                                SVProgressHUD.showInfo(withStatus: "添加成功")
                                self.getRelationShips()
                            }else{
                                SVProgressHUD.showInfo(withStatus: "添加失败")
                            }
                            
                        }
                    }
                }
            }

        }
    }
    
    

    func changeRelationShip() {
        if relationShipsArray.isEmpty {
            SVProgressHUD.showInfo(withStatus: "正在获取数据,请稍后再试")
            return
        }
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")!
        let shipID=relationShipsArray[selectedRow]["ship_id"] as! String
        let param=[
            "phoneNum":phoneNum,
            "shipid":shipID
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/changeRelationShip", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?{
                    if info["state"] != nil{
                        if info["state"] as! Bool{
                            SVProgressHUD.showInfo(withStatus: "修改成功,请重新登录")
                            self.getRelationShips()
                        }else{
                            SVProgressHUD.showInfo(withStatus: "修改失败")
                        }
                    }
                }else{
                    SVProgressHUD.showInfo(withStatus: "服务器错误")
                }
            }
        }
    }
    
    
    
    func deleteRelationShip(sender:UIButton) {
        if sender.tag==usingShipIndex {
            SVProgressHUD.showInfo(withStatus: "不能删除当前正在使用的船舶!")
            return
        }
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")!
        let relationShip=relationShipsArray[sender.tag]
        let shipID=relationShip["ship_id"] as! String
        
        let param=[
            "phoneNum":phoneNum,
            "shipid":shipID
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/delRelationShip", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?{
                    if info["state"] != nil{
                        if info["state"] as! Bool{
                            SVProgressHUD.showInfo(withStatus: "删除成功")
                            self.getRelationShips()
                        }else{
                            SVProgressHUD.showInfo(withStatus: "删除失败")
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "请求错误")
                    }
                }
            }
        }
    }
    
    
    func getFriendShips() {
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")
        let param=[
            "phoneNum":phoneNum!,
            ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/phoneNum", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                
                if let dicArr=JSON(response).arrayObject as? [Dictionary<String, AnyObject>]{
                        self.friendShipsArray=dicArr
                    print("好友列表船舶：\(dicArr)")
                        self.tableView1.reloadData()
                }else{
                    SVProgressHUD.showInfo(withStatus: "服务器错误")
                }
            }
        }
        
    }
    
    
    func deleteFriendShip(sender:UIButton) {
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")!
        let friendShip=friendShipsArray[sender.tag]
        let shipID=friendShip["ship_id"] as! String

        let param=[
            "phoneNum":phoneNum,
            "shipid":shipID
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/delRelationShip", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?{
                    if info["state"] != nil{
                        if info["state"] as! Bool{
                            SVProgressHUD.showInfo(withStatus: "删除成功")
                            self.getFriendShips()
                        }else{
                            SVProgressHUD.showInfo(withStatus: "删除失败")
                        }
                    }else{
                        SVProgressHUD.showInfo(withStatus: "请求错误")
                    }
                }
            }
        }
    }

    func segmentChanged() {
        if segmentedControl.selectedSegmentIndex==1 {
            subView = UIView.init(frame: CGRect.init(x: 0, y: 124, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-64-60-40))
            self.view.addSubview(subView)
            subView.backgroundColor = UIColor.init(red: 84/255, green: 188/255, blue: 212/255, alpha: 1.0)
            
            subView.addSubview(tableView1)
            self.navigationItem.rightBarButtonItem=nil
        }else{
           self.navigationItem.rightBarButtonItem=rightBtn
            self.subView.removeFromSuperview()
        }
    }
    
    func setShareParam() {
        if selectedRow == -1 {
            SVProgressHUD.showInfo(withStatus: "请稍后再试...")
            return
        }
        let  relationShipDic = relationShipsArray[selectedRow]
        shareParam = [
            "cyPhoneNum":relationShipDic["crewphonenum"] as! String,
            "shipId":relationShipDic["ship_id"] as! String,
            "shipName":relationShipDic["ship_name"] as! String,
            "cbsbh":relationShipDic["cbsbh"] as! String
        ]
        let vc = HSCYShareBoatViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cbsbhTF.resignFirstResponder()
    }
    
    
    func setupRefresh() {
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        self.tableView1.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl)
    }
    
    func refreshDrag(refreshControl:UIRefreshControl) {
        refreshControl.endRefreshing()
        getFriendShips()
    }
}
