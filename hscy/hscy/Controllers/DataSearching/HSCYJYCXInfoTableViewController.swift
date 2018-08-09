//
//  HSCYJYCXInfoTableViewController.swift
//  hscy
//
//  Created by 周子聪 on 2017/9/14.
//  Copyright © 2017年 melodydubai. All rights reserved.
//

import Foundation

protocol JYCXDicArrProperty {
    var jycxDic:Dictionary<String,String>{get set}
}
class HSCYJYCXInfoTableViewController: UITableViewController {
    var delegate:JYCXDicArrProperty!
    var jycxInfoDic:Dictionary<String, String>!
    let namesOfInfo=["案由","当事人","船舶名称","违法事实描述","违法地点","处罚金额","处罚决议书案号","处罚依据","违反规定","当事人地址","复议单位","决定地点","其他处罚","船舶所有人","行政处罚措施","机构名称","起诉期限","缴纳罚款地点","减轻理由","决定机关","违法时间","经营人","是否从轻处罚"]
    let keysOfInfo=["Casedesc","Client","Shipname","Actiondesc","Illegaladdrid","Punishmoney","Executecodenum","Punishitem","Lawitem","Clientaddr","Rediscussunit","Punishaddr","Otherpunish","Owner","Excutivemeasure","Organname","Impleadlimit","Payfeeaddr","Releasereason","Dealman","Illegaltime","Runner","Islessen"]
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.navigationItem.title="违章信息"
        //self.tableView=UITableView()
        // 设置代理
        self.tableView.delegate = self
        // 设置数据源
        self.tableView.dataSource = self
       
        self.tableView.register(UINib.init(nibName: "HSCYTopBottomTableCellView", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight=300
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesOfInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell") as! HSCYTopBottomTableCellView
        
        cell.topLabel.text=namesOfInfo[indexPath.row]
        let key=keysOfInfo[indexPath.row]
        cell.bottomLabel.text=self.delegate.jycxDic[key]
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        return cell
    }
}
