//
//  mapSeachingView.swift
//  船员版
//
//  Created by dingjianxin on 2017/8/16.
//  Copyright © 2017年 丁建新. All rights reserved.
//

import  UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
struct Coordinator {
    var lng:Double
    var lat:Double
}

class   mapSeachingView:UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var nearbySeachBar: UISearchBar!
    
    var cancellButton:UIButton!
    var tableView:UITableView!
    var dataDics:[[String:AnyObject]] = []
    var coordinatorArr:[Coordinator]=[]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        initTableView()
        nearbySeachBar.delegate=self
        tableView.dataSource=self
        tableView.delegate=self
        tableView.rowHeight=UITableViewAutomaticDimension
        
        
        let subViews:Array=nearbySeachBar.subviews
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
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        let btnTitle=cancellButton?.titleLabel?.text
        if(btnTitle=="取消"){
            self.dataDics=[]
            tableView.removeFromSuperview()
            nearbySeachBar.resignFirstResponder()
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
            tableView.removeFromSuperview()
        }
        else {
            cancellButton.setTitle("搜索", for: UIControlState.normal)
            
            let text=searchBar.text!
            print("\(text)")
            let param = [
                "vagueName":text,
                "way":"10"
            ]
            
            Alamofire.request("http://218.94.74.231:9999/SeaProject/resourceQuery", method:.post, parameters: param ).responseJSON{
                
                (returnResult) in
                if let response=returnResult.result.value{
                    print("\(response)")
                    if !(JSON(response).arrayObject?.isEmpty)!{
                        self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                        var i=0
                        self.coordinatorArr.removeAll()
                        for elem in self.dataDics{
                            
                            let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                            self.coordinatorArr.append(coo)
                            i+=1
                            
                        }
                        self.view.addSubview(self.tableView)
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    
    
    
    
    func  searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func initTableView(){
        tableView=UITableView.init(frame: CGRect(x:0,y:108,width:self.view.bounds.width,height:500), style: UITableViewStyle.plain)
        tableView.alpha=0.9
    }
    //===================================
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("1");
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("2")
        //        if dataDics.count=0 {
        //            print("000000000000000000000000")
        //            return 0
        //        }
        //        print("1111111111111111")
        print("\(dataDics.count)")
        return dataDics.count
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //UserDefaults.standard.set(coordinatorArr[indexPath.row].lat, forKey: "lat")
        //UserDefaults.standard.set(coordinatorArr[indexPath.row].lng, forKey: "lng")
        //UserDefaults.standard.synchronize()
        let center = NotificationCenter.default//创建通知
        print("coordinatorArr\(coordinatorArr)")
        print("indexpath:\(coordinatorArr[indexPath.row])")
        let dic=[
            "lat":coordinatorArr[indexPath.row].lat,
            "lng":coordinatorArr[indexPath.row].lng
        ]
        
        center.post(name: NSNotification.Name(rawValue: "passValue"), object: nil, userInfo: dic)
        
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        if (cell == nil)
        {
            cell = UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text=dataDics[indexPath.row]["name"] as? String
        cell?.detailTextLabel?.text=dataDics[indexPath.row]["resType"] as? String
        let type=dataDics[indexPath.row]["type"] as? String
        print("type:\(type)")
        
        switch type {
        case "禁泊区"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "no_stop_area_item")
        case "桥梁"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "bridge_item")
        case "摄像头"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "camera_item")
        case "码头"? :
            cell?.imageView?.image=#imageLiteral(resourceName: "wharf_item")
        case "禁航区"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "no_stop_item")
        case "限速区"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "speed_limit_item")
        case "船舶"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "res_boat_item")
        case"底照度"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "camera_item")
        case"激光"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "camera_item")
        case"公路桥"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "bridge_item")
        case"人行桥"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "bridge_item")
        case"高架桥"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "bridge_item")
        case"危化、液货"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "wharf_item")
        case"危化、普货"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "wharf_item")
        case"油类、普货"?:
            cell?.imageView?.image=#imageLiteral(resourceName: "wharf_item")
       
        default: break
            
        }
        
        
        return cell!
    }
    func initSpeedLimit(){
        
        let param = [
            "lat1":"0",
            "lat2":"90",
            "lng1":"0",
            "lng2":"180",
            "way":"ten"
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/nearbySpeedLimitRange", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if let response=returnResult.result.value{
                print("\(response)")
                if !(JSON(response).arrayObject?.isEmpty)!{
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    print("-----------data")
                    print("\(self.dataDics)")
                    var i=0
                    self.coordinatorArr.removeAll()
                    for elem in self.dataDics{
                        
                        let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                        self.coordinatorArr.append(coo)
                        i+=1
                        
                    }
                    self.view.addSubview(self.tableView)
                    self.tableView.reloadData()
                    
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "暂无信息")
                }
                
            }
            
            
        }
        
        
        
    }
    func initbrige(){
        
        let param = [
            "lat1":"0",
            "lat2":"90",
            "lng1":"0",
            "lng2":"180",
            "way":"ten"
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/nearbyBridgeRes", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if let response=returnResult.result.value{
                print("\(response)")
                if !(JSON(response).arrayObject?.isEmpty)!{
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    print("-----------data")
                    print("\(self.dataDics)")
                    var i=0
                    self.coordinatorArr.removeAll()
                    for elem in self.dataDics{
                        
                        let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                        self.coordinatorArr.append(coo)
                        i+=1
                        
                    }
                    self.view.addSubview(self.tableView)
                    self.tableView.reloadData()
                    
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "暂无信息")
                }
                
                
            }
            
            
        }
        
        
        
        
    }
    func initWharf(){
        
        let param = [
            "lat1":"0",
            "lat2":"90",
            "lng1":"0",
            "lng2":"180",
            "way":"ten"
        ]
        
        Alamofire.request("http://218.94.74.231:9999/SeaProject/nearbyWharfRes", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if var response=returnResult.result.value{
                print("\(response)")
                if !(JSON(response).arrayObject?.isEmpty)!{
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    print("-----------data")
                    print("\(self.dataDics)")
                    var i=0
                    self.coordinatorArr.removeAll()
                    for var elem in self.dataDics{
                        
                        let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                        
//                        if !(((elem["type"]?="<null>" as AnyObject) != nil)){

                        self.coordinatorArr.append(coo)
//                        }
//                        else {
//
//                            self.dataDics.remove(at: i)
//                            print("i:\(i)")
//                            print("dataDics:\(self.dataDics)")
//                        }

                        i+=1
                        
                        
                    }
                    self.view.addSubview(self.tableView)
                    self.tableView.reloadData()
                    
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "暂无信息")
                }
                
            }
            
            
        }
        
        
        
        
        
    }
    func initCamera(){
        let param = [
            "lat1":"0",
            "lat2":"90",
            "lng1":"0",
            "lng2":"180",
            "way":"ten"
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/nearbyCameraRes", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if let response=returnResult.result.value{
                print("\(response)")
                if !(JSON(response).arrayObject?.isEmpty)!{
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    print("-----------data")
                    print("\(self.dataDics)")
                    var i=0
                    self.coordinatorArr.removeAll()
                    for elem in self.dataDics{
                        
                        let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                        self.coordinatorArr.append(coo)
                        i+=1
                        
                    }
                    self.view.addSubview(self.tableView)
                    self.tableView.reloadData()
                    
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "暂无信息")
                }
                
                
            }
            
            
        }
        
        
        
    }
    func initNoStop(){
        let param = [
            "lat1":"0",
            "lat2":"90",
            "lng1":"0",
            "lng2":"180",
            "way":"ten"
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/nearbyNavigateLimitRange", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if let response=returnResult.result.value{
                print("\(response)")
                if !(JSON(response).arrayObject?.isEmpty)!{
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    print("-----------data")
                    print("\(self.dataDics)")
                    var i=0
                    self.coordinatorArr.removeAll()
                    for elem in self.dataDics{
                        
                        let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                        self.coordinatorArr.append(coo)
                        i+=1
                        
                    }
                    self.view.addSubview(self.tableView)
                    self.tableView.reloadData()
                    
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "暂无信息")
                }
                
                
            }
            
            
        }
        
        
    }
    func initNoStopArea(){
        let param = [
            "lat1":"0",
            "lat2":"90",
            "lng1":"0",
            "lng2":"180",
            "way":"ten"
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/nearbyProhibitedAnchorRange", method:.post, parameters: param ).responseJSON{
            
            (returnResult) in
            if let response=returnResult.result.value{
                print("\(response)")
                if !(JSON(response).arrayObject?.isEmpty)!{
                    self.dataDics=JSON(response).arrayObject as! [[String : AnyObject]]
                    print("-----------data")
                    print("\(self.dataDics)")
                    var i=0
                    self.coordinatorArr.removeAll()
                    for elem in self.dataDics{
                        
                        let coo=Coordinator(lng:elem["lng"] as! Double,lat:elem["lat"] as! Double)
                        self.coordinatorArr.append(coo)
                        i+=1
                        
                    }
                    self.view.addSubview(self.tableView)
                    self.tableView.reloadData()
                    
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "暂无信息")
                }
                
                
            }
            
            
        }
        
        
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        nearbySeachBar.resignFirstResponder()
        //        SVProgressHUD.showInfo(withStatus: "zhanswushuk")
    }
    
    @IBAction func gasBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
        
    }
    
    
    @IBAction func serviceBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
    }
    @IBAction func fixBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
        
    }
    @IBAction func shipLockBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
        
    }
    @IBAction func complicatedAreaBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
        
    }
    @IBAction func manageAreaBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
        
    }
    @IBAction func importantWaterAreaBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
        
    }
    @IBAction func shoalBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
    }
    @IBAction func stopAreaBtn(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "暂无信息")
    }
    
    @IBAction func bridgeBtn(_ sender: Any) {
        initbrige()
    }
    @IBAction func wharfBtn(_ sender: Any) {
        
        initWharf()
        
        
    }
    @IBAction func cameraBtn(_sender:Any){
        initCamera()
    }
    
    @IBAction func noStopBtn(_sender:Any){
        
        initNoStop()
    }
    @IBAction func speedLimitBtn(_sender:Any){
        initSpeedLimit()
        
    }
    @IBAction func noStopAreaBtn(_sender:Any){
        
        initNoStopArea()
    }
    
    
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        nearbySeachBar.resignFirstResponder()
    }
    
    
}
