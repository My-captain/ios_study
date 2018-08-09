//
//  HSCYAssistanceViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/8/29.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class HSCYAssistanceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var segment: UISegmentedControl!

    var tableView1:UITableView!
    var tableView2:UITableView!
    
    var pickerView:PickDateCallOutView!
    
    var lawArray:[String] = []
    var pushArray:[String] = []
    
    var startDate:Date!
    var endDate:Date!
    
    //用来表示当前datePicker是属于谁的：1表示startDate，2表示endCode
    var stateCode:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSwipeGesture()
        
        endDate=Date()
        startDate=Calendar.current.date(byAdding: .month, value: -1, to: Date())
        initTableView()
    
        requestAndRecieveLaws()

        let swipLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipLeft)
        
        let swipRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipRight)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSwipeGesture() {
        let swipLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipLeft)
        
        let swipRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipRight)
        
        segment.addTarget(self, action: #selector(segmentChanged), for: UIControlEvents.valueChanged)
    }

    func initTableView() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView1=UITableView()
        tableView1.dataSource=self
        tableView1.delegate=self
        tableView1.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView1)
        //self.view.sendSubview(toBack: tableView1)
        tableView1.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.segment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        tableView2=UITableView()
        tableView2.dataSource=self
        tableView2.delegate=self
        tableView2.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView2)
        self.view.sendSubview(toBack: tableView2)
        tableView2.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.segment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        let headview=Bundle.main.loadNibNamed("PickTableHeadView", owner: self, options: nil)!.last as! PickTableHeadView
        headview.frame=CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        headview.startDateBtn.setTitle(dateFormatter.string(from: startDate), for: UIControlState.normal)
        headview.startDateBtn.addTarget(self, action: #selector(callOutDatePicker(sender:)), for: UIControlEvents.touchUpInside)
        headview.startDateBtn.tag=1
        
        headview.endDateBtn.setTitle(dateFormatter.string(from: endDate), for: UIControlState.normal)
        headview.endDateBtn.addTarget(self, action: #selector(callOutDatePicker(sender:)), for: UIControlEvents.touchUpInside)
        headview.endDateBtn.tag=2
        
        tableView2.tableHeaderView=headview
        
        tableView1.tableFooterView=UIView()
        tableView2.tableFooterView=UIView()
    }
    
    //MARK:实现tableview的代理协议
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==tableView1 {
            return lawArray.count
        }else{
            return pushArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as UITableViewCell?
        if (cell == nil)
        {
            cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier: "cell1")
        }
        if tableView==tableView1 {
            //右侧加小箭头
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell?.textLabel?.text=lawArray[indexPath.row]
            return cell!
        }else{
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIViewController()
        vc.navigationItem.title="海事法规"
        
        let webView = UIWebView(frame: UIScreen.main.bounds)
        vc.view.addSubview(webView)
        let str="http://218.94.74.231:9999/laws/\(lawArray[indexPath.row]).htm"
        let encodedStr = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedStr!)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        self.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed=false
    }

    
    
    func requestAndRecieveLaws() {
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getLaws", method: .get).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).arrayObject as? [Dictionary<String, String>]{
                    for lawDic in info{
                        self.lawArray.append(lawDic["lawName"]!)
                        self.tableView1.reloadData()
                    }
                }
            }
        }
    }
    
    func requestAndRecievePushs() {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let shipID=UserDefaults.standard.string(forKey: "shipID")!
        let startDateStr=dateFormatter.string(from: startDate)
        let endDateStr=dateFormatter.string(from: endDate)
        
        let param=[
            "shipId":shipID,
            "beginTime":startDateStr,
            "endTime":endDateStr
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getPushMsg", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).arrayObject as? [Dictionary<String, String>]{
                    for pushDic in info{
                        //FIXME: 未实现，之后记得修改
                        self.pushArray.append(pushDic["buzhidaozheshishenmegui"]!)
                        self.tableView2.reloadData()
                    }
                }else{
                    SVProgressHUD.showInfo(withStatus: "暂无数据")
                }
            }
        }
    }
    
    //滑动手势
    func swipeGesture(swip:UISwipeGestureRecognizer) {
        if swip.direction == UISwipeGestureRecognizerDirection.left {
            if self.segment.selectedSegmentIndex==0{
                self.segment.selectedSegmentIndex=1
            }
        }else if swip.direction == UISwipeGestureRecognizerDirection.right {
            if self.segment.selectedSegmentIndex==1{
                self.segment.selectedSegmentIndex=0
            }
        }
        segmentChanged()
    }
    
    func segmentChanged() {
        if segment.selectedSegmentIndex==0{
            self.view.sendSubview(toBack: tableView2)
        }else{
            self.view.sendSubview(toBack: tableView1)
        }
    }
    
    func callOutDatePicker(sender:UIButton) {
        
        stateCode=sender.tag
        pickerView=Bundle.main.loadNibNamed("PickDateCallOutView", owner: self, options: nil)!.last as! PickDateCallOutView
        switch sender.tag {
        case 1:
            pickerView.datePicker.date=startDate
        case 2:
            pickerView.datePicker.date=endDate
        default:
            break
        }
        pickerView.doneBtn.action=#selector(picked)
        self.view.addSubview(pickerView)
    }
    func picked() {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
   
        switch stateCode {
        case 1:
            startDate=pickerView.datePicker.date
            
            let date1=dateFormatter.string(from: startDate)
            (tableView2.tableHeaderView as! PickTableHeadView).startDateBtn.setTitle(date1, for: UIControlState.normal)
            
            requestAndRecievePushs()
            
        case 2:
            endDate=pickerView.datePicker.date
            
            let date2=dateFormatter.string(from: endDate)
            (tableView2.tableHeaderView as! PickTableHeadView).endDateBtn.setTitle(date2, for: UIControlState.normal)
            
            requestAndRecievePushs()
            
        default:
            break
        }

        stateCode=0
        pickerView.removeFromSuperview()
    }

}
