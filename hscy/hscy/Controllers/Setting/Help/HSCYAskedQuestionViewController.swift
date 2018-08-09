//
//  HSCYAskedQuestionViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/9/11.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HSCYAskedQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView0:UITableView!
    var tableView1:UITableView!
    
    var faqArray:[String]=[]//faq - Frequently Asked Question
    var taqArray:[String]=[]//taq - Totally Asked Question
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        initTableViews()
        requestAndRecieveAQs()
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
    func initTableViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView0=UITableView()
        tableView0.dataSource=self
        tableView0.delegate=self
        tableView0.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView0)
        self.view.sendSubview(toBack: tableView0)
        tableView0.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.segment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        tableView1=UITableView()
        tableView1.dataSource=self
        tableView1.delegate=self
        tableView1.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView1)
        tableView1.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.segment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        tableView0.tableFooterView=UIView()
        tableView1.tableFooterView=UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==tableView0 {
            return faqArray.count
        }else {
            return taqArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView==tableView0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell0") as UITableViewCell?
            if (cell == nil)
            {
                cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier: "cell0")
            }
            cell?.textLabel?.text=faqArray[indexPath.row]
            //右侧加小箭头
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell!
        }else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as UITableViewCell?
            if (cell == nil)
            {
                cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier: "cell1")
            }
            cell?.textLabel?.text=taqArray[indexPath.row]
            //右侧加小箭头
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIViewController()
        vc.navigationItem.title="帮助文档"
        
        let webView = UIWebView(frame: UIScreen.main.bounds)
        webView.scalesPageToFit=true
        vc.view.addSubview(webView)
        var str:String=""
        if tableView==tableView0 {
            str="http://218.94.74.231:9999/questions/all/\(faqArray[indexPath.row]).htm"
            
        }else {
            str="http://218.94.74.231:9999/questions/all/\(taqArray[indexPath.row]).htm"
        }
        let encodedStr = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedStr!)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        self.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated: true)
        //self.hidesBottomBarWhenPushed=false
    }
    
    func requestAndRecieveAQs() {
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getFAQs", method: .get).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).arrayObject as? [Dictionary<String, String>]{
                    for faqDic in info{
                        self.faqArray.append(faqDic["name"]!)
                        self.tableView0.reloadData()
                    }
                    
                }
            }
        }
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getQuestions", method: .get).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).arrayObject as? [Dictionary<String, String>]{
                    for taqDic in info{
                        self.taqArray.append(taqDic["name"]!)
                        self.tableView1.reloadData()
                    }
                    
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
            self.view.sendSubview(toBack: tableView1)
        }else{
            self.view.sendSubview(toBack: tableView0)
        }
    }
    
}
