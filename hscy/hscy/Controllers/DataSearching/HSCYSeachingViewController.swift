//
//  HSCYSeachingViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/8/29.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SnapKit
import SVProgressHUD
class HSCYSeachingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, JYCXDicArrProperty{
//UIViewControllerAnimatedTransitioning
    
    
    
    
    var boatInfoDic:Dictionary<String, String>!=["state":"1"]
    let boatInfoTuples=[("船舶登记号","CBDJH1"),("船舶识别号","CBSHB1"),("中文船名","ZWCM1"),("英文船名","YWCM1"),("曾用名","YZWCM1"),("船检登记号","CJDJH1"),("原船舶登记号","YCBDJH1"),("初次登记号","CCDJH1"),("船籍港代码","CJGDM1"),("原船籍港","YCJG1"),("船舶价值","CBJZ1"),("建成日期","JCRQ1"),("改建日期","GJRQ1"),("造船厂","ZCC1"),("造船地点","GJDD1"),("船舶长度","CBCD1"),("船舶型宽","CBXK1"),("船舶型深","CBXS1"),("总吨","ZD1"),("净吨","JD1"),("总载重吨","ZZZD1"),("主机数量","ZJSL1"),("主机功率","ZJGL1"),("推进器种类代码","TJQZLDM1"),("推进器数量","TJQSL1"),("夏季满载吃水","XJMZCS1"),("核定抗风等级","HDKFDJ1"),("最小干舷","ZXGX1"),("箱位","XW1"),("车位","CW1"),("客位","KW1"),("备注","BZ1"),("MMSI","MMSI1"),("船舶所有人","CBSYR1"),("船舶管理人","CBGLR1"),("船舶经营人","CBJYR1"),("英文造船地点","YWZCDD1"),("英文改建地点","YWGJDD1"),("英文造船厂","YWZCC1"),("抵押期标记","DYQBZ1"),("光租标记","GZBZ1"),("变更标记","BGBZ1"),("换证标记","LZBZ1"),("FKBZ","FKBZ1"),("国籍证书有效期","GJZSYXQ1"),("最低配员有效期","ZDPYZSYXQ1"),("国籍申请有效期","GJZSQSYXQ1"),("IC卡号","ICKH1"),("注销日期","YZXRQ1")]
    var sailorInfoDic:Dictionary<String,String>!=["state":"1"]
    let sailorInfoTuples=[("流水号","lsh"),("身份证号码","sfzhm"),("服务簿号码","fwbhm"),("证书号码","zshm"),("征收印刷号","zsysh"),("适任证种类代码","srzzldm"),("适任证种类名称","srzlmc"),("适任专业","srzy"),("适任专业名称","srzymc"),("适任等级","srdj"),("适任等级名称","srdjmc"),("适任职务","srzw"),("适任职务名称","srzwmc"),("性别","xb"),("出生地点","csdd"),("出生地点名称","csddmc"),("出生日期","csrq"),("单位代码","dwdm"),("单位名称","dwmc"),("签发机构","qfjg"),("签发机构名称","unitname"),("签发官姓名","qfgyxm"),("签发日期","qfrq"),("打印日期","dyrq"),("截止日期","jzrq"),("最后签注日期","zhqzrq"),("证书状态","zszt"),("状态变更日期","ztbgrq"),("档案存放","dacf"),("备注","bz"),("更新标注","gxbz"),("更新时间","mrut"),("信息来源","xxly"),("基本信息印刷号","jbxxysh"),("在有效审验标志","zyxsybz"),("在有效审验日期","zyxsyrq"),("在有效截止日期","zyxjzrq"),("航线签注页标志","hxqzybz"),("适用范围","syfw"),("适任类别","srlb"),("适任类别名称","srlbmc"),("失效标志","sxbz"),("sfcjtk","sfcjtk")]
    var inspectionInfoDic:Dictionary<String,String>!=["state":"1"]
    let inspectionInfoTuples=[("机构名称","Inspcode"),("证书名称","Certname"),("船舶名称","Shipname"),("船检日期","Awarddate"),("过期日期","Usefuldate"),("发证单位","Certunit")]
    var summaryProcedureDic:[Dictionary<String,String>]!//不要被名字迷惑，其实是个字典数组
    let summaryProcedureTuples=[("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("","")]
    var administrativeProcedureDic:[Dictionary<String,String>]!
    let administrativeProcedureTuples=[("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("",""),("","")]
    
    var jycxDic: Dictionary<String, String> = [:]//协议的属性,将选中的jycx信息传给push出来的界面
    
    var tableView0:UITableView!
    var tableView1:UITableView!
    var tableView2:UITableView!
    var tableView3:UITableView!
    var tableView4:UITableView!
    
    //0表示pickdate不显示，1表示pickdate对tableview3的startdate进行选择，2表示对tableview3的enddate进行选择，3表示pickdate对tableview4的startdate进行选择，4表示对tableview4的enddate进行选择
    var stateCode:Int=0
    
    var startDate1:Date?
    var endDate1:Date!
    
    var startDate2:Date?
    var endDate2:Date!
    
    var pickerView:PickDateCallOutView!
    //var datePicker2:UIDatePicker!
    //
    var currentTableView:UITableView!
    
    @IBOutlet weak var seachSegment: UISegmentedControl!
    
    @IBAction func clickBtn(_ sender: Any) {
        seachSegment.selectedSegmentIndex=(sender as! UIButton).tag
        segmentChanged()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endDate1=Date()
        startDate1=nil
        endDate2=Date()
        startDate2=nil
        
        seachSegment.addTarget(self, action: #selector(segmentChanged), for: UIControlEvents.valueChanged)
        
        //addSwipeGesture()
        initTableViews()
        requestAndRecieveData()
        setupRefresh()
    }
    func addSwipeGesture() {
        let swipLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipLeft)
        
        let swipRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipRight)
        
    }
    
    func initTableViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView1=UITableView()
        tableView1.dataSource=self
        tableView1.delegate=self
        tableView1.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView1)
        self.view.sendSubview(toBack: tableView1)
        tableView1.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.seachSegment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        tableView2=UITableView()
        tableView2.dataSource=self
        tableView2.delegate=self
        tableView2.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView2)
        tableView2.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.seachSegment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        tableView3=UITableView()
        tableView3.dataSource=self
        tableView3.delegate=self
        tableView3.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView3)
        tableView3.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.seachSegment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        
        tableView4=UITableView()
        tableView4.dataSource=self
        tableView4.delegate=self
        tableView4.rowHeight=UITableViewAutomaticDimension

        self.view.addSubview(tableView4)
        tableView4.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.seachSegment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        tableView0=UITableView()
        tableView0.dataSource=self
        tableView0.delegate=self
        tableView0.rowHeight=UITableViewAutomaticDimension
        self.view.addSubview(tableView0)
        tableView0.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.seachSegment.snp.bottom).offset(5)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let headview3=Bundle.main.loadNibNamed("PickTableHeadView", owner: self, options: nil)!.last as! PickTableHeadView
        headview3.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        headview3.startDateBtn.setTitle("--", for: UIControlState.normal)
        headview3.startDateBtn.addTarget(self, action: #selector(callOutDatePicker(sender:)), for: UIControlEvents.touchUpInside)
        headview3.startDateBtn.tag=1
        
        headview3.endDateBtn.setTitle(dateFormatter.string(from: endDate1), for: UIControlState.normal)
        headview3.endDateBtn.addTarget(self, action: #selector(callOutDatePicker(sender:)), for: UIControlEvents.touchUpInside)
        headview3.endDateBtn.tag=2
        
        tableView3.tableHeaderView=headview3

       
        
        
        let headview4=Bundle.main.loadNibNamed("PickTableHeadView", owner: self, options: nil)!.last as! PickTableHeadView
        headview4.frame=CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        
        headview4.startDateBtn.setTitle("--", for: UIControlState.normal)
        headview4.startDateBtn.addTarget(self, action: #selector(callOutDatePicker(sender:)), for: UIControlEvents.touchUpInside)
        headview4.startDateBtn.tag=3

        headview4.endDateBtn.setTitle(dateFormatter.string(from: endDate2), for: UIControlState.normal)
        headview4.endDateBtn.addTarget(self, action: #selector(callOutDatePicker(sender:)), for: UIControlEvents.touchUpInside)
        headview4.endDateBtn.tag=4
   
        
        tableView4.tableHeaderView=headview4
        
        tableView0.tableFooterView=UIView()
        tableView1.tableFooterView=UIView()
        tableView2.tableFooterView=UIView()
        tableView3.tableFooterView=UIView()
        tableView4.tableFooterView=UIView()
        
        self.tableView0.register(UINib.init(nibName: "HSCYLeftRightTableCellView", bundle: nil), forCellReuseIdentifier: "cell0")
        self.tableView1.register(UINib.init(nibName: "HSCYLeftRightTableCellView", bundle: nil), forCellReuseIdentifier: "cell1")
       
        
        currentTableView=tableView0
    }
    
    
    func requestAndRecieveData() {
        boatInfoRequestAndRecieveData()
        sailorInfoRequestAndRecieveData()
        shipSurveyRequestAndRecieveData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView==tableView0{
            return boatInfoTuples.count
        }else if tableView==tableView1{
            return sailorInfoTuples.count
        }else if tableView==tableView2{
            return inspectionInfoTuples.count
        }else if tableView==tableView3{
            if summaryProcedureDic==nil{
                return 0
            }
            return summaryProcedureDic.count
        }else{
            if administrativeProcedureDic==nil{
                return 0
            }
            return administrativeProcedureDic.count
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView==tableView0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell0") as! HSCYLeftRightTableCellView
            
            cell.selectionStyle=UITableViewCellSelectionStyle.none
            let text=boatInfoTuples[indexPath.row].0
            cell.leftLabel?.text=text
            let key=boatInfoTuples[indexPath.row].1
            if boatInfoDic["state"]=="1"{
                cell.rightLabel?.text="数据正在加载..."
            }else if boatInfoDic["state"]=="0"{
                cell.rightLabel?.text="数据获取失败"
            }
            else{
                cell.rightLabel?.text=boatInfoDic[key]
            }
            return cell
        }else if tableView==tableView1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! HSCYLeftRightTableCellView
            cell.selectionStyle=UITableViewCellSelectionStyle.none;
            cell.leftLabel?.text=sailorInfoTuples[indexPath.row].0
            let key=sailorInfoTuples[indexPath.row].1
            if sailorInfoDic["state"]=="1"{
                cell.rightLabel?.text="数据正在加载..."
            }else if sailorInfoDic["state"]=="0"{
                cell.rightLabel?.text="数据获取失败"
            }
            else{
                cell.rightLabel?.text=sailorInfoDic[key]
            }
            return cell
        }else if tableView==tableView2{
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as UITableViewCell?
            if (cell == nil)
            {
                cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier: "cell2")
            }
            cell?.selectionStyle=UITableViewCellSelectionStyle.none;
            cell?.textLabel?.text=inspectionInfoTuples[indexPath.row].0
            let key=inspectionInfoTuples[indexPath.row].1
            if inspectionInfoDic["state"]=="1"{
                cell?.detailTextLabel?.text="数据正在加载..."
            }else if inspectionInfoDic["state"]=="0"{
                cell?.detailTextLabel?.text="数据获取失败"
            }else{
                cell?.detailTextLabel?.text=inspectionInfoDic[key]
                if key=="Usefuldate" {
                    cell?.detailTextLabel?.textColor=#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                }
            }
            return cell!
        }else if tableView==tableView3{
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as UITableViewCell?
            if (cell == nil)
            {
                cell = UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier: "cell3")
            }
            let dateTime=summaryProcedureDic[indexPath.row]["Illegaltime"]!
            let place=summaryProcedureDic[indexPath.row]["Illegaladdrid"]!
            cell?.textLabel?.text="时间："+dateTime
            cell?.detailTextLabel?.text="地点："+place
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell4") as UITableViewCell?
            if (cell == nil)
            {
                cell = UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier: "cell4")
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView==tableView3{
            jycxDic=summaryProcedureDic[indexPath.row]
            let vc=HSCYJYCXInfoTableViewController()
            vc.delegate=self
            self.hidesBottomBarWhenPushed=true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed=false
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView==tableView3 {
            return 60
        }
        return 44
    }
    
    
    
    //
    //        public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    //
    //        // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    //        public func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    
    //滑动手势
    func swipeGesture(swip:UISwipeGestureRecognizer) {
        if swip.direction == UISwipeGestureRecognizerDirection.left {
            if self.seachSegment.selectedSegmentIndex<=3{
                self.seachSegment.selectedSegmentIndex+=1
            }
        }else if swip.direction == UISwipeGestureRecognizerDirection.right {
            if self.seachSegment.selectedSegmentIndex>=1{
                self.seachSegment.selectedSegmentIndex-=1
            }
        }
        segmentChanged()
    }
    
    
    
    func segmentChanged(){
        if seachSegment.selectedSegmentIndex==0{
            //            UIView.transition(from: currentTableView, to: tableView0, duration: 1, options: UIViewAnimationOptions.curveEaseInOut, completion: nil)
            self.view.sendSubview(toBack: tableView1)
            self.view.sendSubview(toBack: tableView2)
            self.view.sendSubview(toBack: tableView3)
            self.view.sendSubview(toBack: tableView4)
        }else if seachSegment.selectedSegmentIndex==1{
            //            UIView.transition(from: currentTableView, to: tableView1, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight){
            //                completed in
            //                self.currentTableView=self.tableView1
            //            }
            self.view.sendSubview(toBack: tableView0)
            self.view.sendSubview(toBack: tableView2)
            self.view.sendSubview(toBack: tableView3)
            self.view.sendSubview(toBack: tableView4)
        }else if seachSegment.selectedSegmentIndex==2{
            //            UIView.transition(from: currentTableView, to: tableView2, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight){
            //                completed in
            //                self.currentTableView=self.tableView2
            //            }
            self.view.sendSubview(toBack: tableView0)
            self.view.sendSubview(toBack: tableView1)
            self.view.sendSubview(toBack: tableView3)
            self.view.sendSubview(toBack: tableView4)
        }else if seachSegment.selectedSegmentIndex==3{
            //            UIView.transition(from: currentTableView, to: tableView3, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight){
            //                completed in
            //                self.currentTableView=self.tableView3
            //            }
            self.view.sendSubview(toBack: tableView0)
            self.view.sendSubview(toBack: tableView1)
            self.view.sendSubview(toBack: tableView2)
            self.view.sendSubview(toBack: tableView4)
        }else if seachSegment.selectedSegmentIndex==4{
            //            UIView.transition(from: currentTableView, to: tableView4, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight){
            //                completed in
            //                self.currentTableView=self.tableView4
            //            }
            self.view.sendSubview(toBack: tableView0)
            self.view.sendSubview(toBack: tableView1)
            self.view.sendSubview(toBack: tableView2)
            self.view.sendSubview(toBack: tableView3)
        }
    }
    
    //两个日期button的点击事件
    func callOutDatePicker(sender:UIButton) {
        
        stateCode=sender.tag
    pickerView=Bundle.main.loadNibNamed("PickDateCallOutView", owner: self, options: nil)!.last as! PickDateCallOutView
        switch sender.tag {
        case 1:
            if startDate1==nil{
                pickerView.datePicker.date = endDate1
            }else{
                pickerView.datePicker.date = startDate1!
            }
        case 2:
            pickerView.datePicker.date=endDate1
        case 3:
            if startDate2==nil{
                pickerView.datePicker.date = endDate2
            }else{
                pickerView.datePicker.date = startDate2!
            }
            pickerView.datePicker.date=endDate2
        case 4:
            pickerView.datePicker.date=endDate2
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
            startDate1=pickerView.datePicker.date
            
            let date1=dateFormatter.string(from: startDate1!)
            (tableView3.tableHeaderView as! PickTableHeadView).startDateBtn.setTitle(date1, for: UIControlState.normal)
            SVProgressHUD.show()
            summaryProcedureRequestAndRecieveData()

        case 2:
            endDate1=pickerView.datePicker.date
            let date2=dateFormatter.string(from: endDate1)
            (tableView3.tableHeaderView as! PickTableHeadView).endDateBtn.setTitle(date2, for: UIControlState.normal)
            if startDate1==nil{
                SVProgressHUD.showInfo(withStatus: "请设置开始日期!")
                break
            }
            SVProgressHUD.show()
            summaryProcedureRequestAndRecieveData()

        case 3:
            startDate2=pickerView.datePicker.date
            
            let date3=dateFormatter.string(from: startDate2!)
            (tableView4.tableHeaderView as! PickTableHeadView).startDateBtn.setTitle(date3, for: UIControlState.normal)
            SVProgressHUD.show()
            administrativeProcedureRequestAndRecieveData()
            
        case 4:
            endDate2=pickerView.datePicker.date
            
            let date4=dateFormatter.string(from: endDate2)
            (tableView4.tableHeaderView as! PickTableHeadView).endDateBtn.setTitle(date4, for: UIControlState.normal)
            if startDate2==nil{
                SVProgressHUD.showInfo(withStatus: "请设置开始日期!")
                break
            }
            SVProgressHUD.show()
            administrativeProcedureRequestAndRecieveData()
            
        default:
            break
        }
        
        
        stateCode=0
        pickerView.removeFromSuperview()
    }

    
    func boatInfoRequestAndRecieveData(){
        let cbsbh = UserDefaults.standard.string(forKey: "cbsbh")
        let param0 = ["cbsbh":cbsbh!]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/queryBoatInfo", method: .post, parameters: param0).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).dictionaryObject as? Dictionary<String, String>{
                    self.boatInfoDic=info
                    
                    self.boatInfoDic["CBCD1"]=NSString(format: "%.02f m", Float(self.boatInfoDic["CBCD1"]!)!/100) as String
                    self.boatInfoDic["CBXK1"]=NSString(format: "%.02f m", Float(self.boatInfoDic["CBXK1"]!)!/100) as String
                    self.boatInfoDic["CBXS1"]=NSString(format: "%.02f m", Float(self.boatInfoDic["CBXS1"]!)!/100) as String
                    self.boatInfoDic["ZD1"]=self.boatInfoDic["ZD1"]!+" t"
                    self.boatInfoDic["JD1"]=self.boatInfoDic["JD1"]!+" t"
                    self.boatInfoDic["ZZZD1"]=self.boatInfoDic["ZZZD1"]!+" t"
                    self.tableView0.reloadData()
                }
                else{
                    self.boatInfoDic["state"]="0"
                    self.tableView0.reloadData()
                }
            }
        }

    }
    func sailorInfoRequestAndRecieveData(){
        let phoneNum = UserDefaults.standard.string(forKey: "phoneNum")
        let param1 = ["phoneNum":phoneNum!]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/crewInfo", method: .post, parameters: param1).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                var info=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?
                if info != nil && (info!["status"] == nil){
                    info?["openRLT"]=nil
                    info?["receivePushMsg"]=nil
                    self.sailorInfoDic=info as! Dictionary<String,String>
                    self.tableView1.reloadData()
                } else{
                    self.sailorInfoDic["state"]="0"
                    self.tableView1.reloadData()
                }
            }
        }
    }
    func shipSurveyRequestAndRecieveData(){
        let cnName = UserDefaults.standard.string(forKey: "cnName")
        let param2 = ["shipName":cnName!]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/jyzsMsg", method: .post, parameters: param2).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                if let info=JSON(response).dictionaryObject as? Dictionary<String, String>{
                    self.inspectionInfoDic=info
                    self.tableView2.reloadData()
                }else{
                    self.inspectionInfoDic["state"]="0"
                    self.tableView2.reloadData()
                }
            }
        }
    }
    func summaryProcedureRequestAndRecieveData(){
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let beginTime=dateFormatter.string(from: startDate1!)
        let endTime=dateFormatter.string(from: endDate1)
        let shipName=UserDefaults.standard.string(forKey: "cnName")!
        let param=[
            "beginTime":beginTime,
            "endTime":endTime,
            "shipName":shipName
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/jycfMsg", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                
                SVProgressHUD.dismiss()
                
                if let info=(JSON(response).dictionaryObject?["ShipJYCFMsgModel"] as? [Dictionary<String, String>]){
                    self.summaryProcedureDic=info
                    self.tableView3.reloadData()
                }else{
                    SVProgressHUD.showInfo(withStatus: "请求超时")
                }
            }
        }
    }
    
    func administrativeProcedureRequestAndRecieveData(){
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let beginTime=dateFormatter.string(from: startDate2!)
        let endTime=dateFormatter.string(from: endDate2)
        let shipName=UserDefaults.standard.string(forKey: "cnName")!
        let param=[
            "beginTime":beginTime,
            "endTime":endTime,
            "shipName":shipName
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/xzcfMsg", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{

                SVProgressHUD.dismiss()

                //确保收到正常的返回数据
                if let info=(JSON(response).dictionaryObject?["ShipXZCFMsgModel"] as? [Dictionary<String, String>]){
                    self.administrativeProcedureDic=info
                    self.tableView4.reloadData()
                }else{
                    SVProgressHUD.showInfo(withStatus: "请求超时")
                }
            }
        }
    }
    func setupRefresh() {
        let refreshControl0=UIRefreshControl()
        refreshControl0.tag=0
        refreshControl0.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        self.tableView0.addSubview(refreshControl0)
        refreshControl0.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl0)
        
        let refreshControl1=UIRefreshControl()
        refreshControl1.tag=1
        refreshControl1.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        self.tableView1.addSubview(refreshControl1)
        refreshControl1.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl1)
        
        let refreshControl2=UIRefreshControl()
        refreshControl2.tag=2
        refreshControl2.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        self.tableView2.addSubview(refreshControl2)
        refreshControl2.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl2)
    }
    
    func refreshDrag(refreshControl:UIRefreshControl) {
        refreshControl.endRefreshing()
        switch refreshControl.tag {
        case 0:
            boatInfoRequestAndRecieveData()
        case 1:
            sailorInfoRequestAndRecieveData()
        case 2:
            shipSurveyRequestAndRecieveData()
        default:
            break
        }
    }
}
