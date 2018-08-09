
//
//  PersonalView.swift
//  海事
//
//  Created by 丁建新 on 2017/7/12.
//  Copyright © 2017年 丁建新. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
class SettingViewController: UIViewController {
    
    @IBOutlet weak var headImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var exit_btn: UIButton!
    
    var tableViewController:HSCYSettingTableViewController!
    
    
    @IBAction func logOut(_ sender: Any) {
        //UserDefaults.standard.removeObject(forKey: "phoneNum")
        UserDefaults.standard.removeObject(forKey: "pwd")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HSCYLoginViewController") as! HSCYLoginViewController
        UIApplication.shared.delegate?.window??.rootViewController=vc
    }

    
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefresh()
        nameLabel.text=UserDefaults.standard.string(forKey: "name")
        let appVersion=Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        tableViewController.version.text="v"+appVersion

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="EmbedSegue" && segue.destination.isKind(of: HSCYSettingTableViewController.self) {
            self.tableViewController=segue.destination as! HSCYSettingTableViewController
        }
    }
    
    
    func requestAndRecieveData() {
        let param=[
            "phoneNum":UserDefaults.standard.string(forKey: "phoneNum")!
        ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/crewInfo", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response = returnResult.result.value{
                if let dic = JSON(response).dictionaryObject as Dictionary<String,AnyObject>?{
                    if let name=dic["name"] as? String
                    {
                        self.nameLabel.text=name
                    }
                }
            }
        }
    }
    func setupRefresh() {
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
        tableViewController.tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        self.refreshDrag(refreshControl: refreshControl)
    }
    
    func refreshDrag(refreshControl:UIRefreshControl) {
        refreshControl.endRefreshing()
        requestAndRecieveData()
    }
}
