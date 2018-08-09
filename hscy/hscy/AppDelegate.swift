
//
//  AppDelegate.swift
//  海事
//
//  Created by 丁建新 on 2017/7/6.
//  Copyright © 2017年 丁建新. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
@UIApplicationMain
class AppDelegate: UIResponder,UIApplicationDelegate,JPUSHRegisterDelegate,AddFriendInfoProtocol, ShareShipInfoProtocol
{
    var info: String = ""
    var shareInfo: String = ""
    
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //JPUSHService.setBadge(0)
        
        window=UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        
        jPushConfig(launchOptions: launchOptions)
        
        AMapServices.shared().apiKey = "ac1ee1f7e9e6e506c3436774bd5dd52b"
        AMapServices.shared().enableHTTPS = true
        
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        //SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0,vertical: 100))//设置SVProgressHUD的偏移
        initLoginOrNearViewController()
        print("我是会执行的")
        // Override point for customization after application launch.
        return true
    }
    func initLoginOrNearViewController() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HSCYLoginViewController") as! HSCYLoginViewController
        window?.rootViewController=vc
        
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")
        let pwd=UserDefaults.standard.string(forKey: "pwd")
        
        if (pwd != nil){
            
            let param=[
                "phoneNum":phoneNum!,
                "pwd":pwd!
            ]
            
            Alamofire.request("http://218.94.74.231:9999/SeaProject/login", method: .post, parameters: param).responseJSON{
                (returnResult) in
                if let response=returnResult.result.value{
                    if let responseJSON=JSON(response).dictionaryObject as Dictionary<String, AnyObject>?{
                        if  responseJSON["status"] == nil{
                            let shipID=responseJSON["ship_id"] as! String
                            if shipID=="false"{
                                SVProgressHUD.showInfo(withStatus: "您的密码已被修改,请重新登陆")
                            }else{
                                //JPUSHAliasOperationCompletion.self
                                JPUSHService.setAlias(phoneNum, completion: {
                                    (iResCode, iAlias, seq) in
                                    if iResCode==0{
                                        print("JPush 设置别名成功")
                                    }
                                }, seq: 0)
                                
                                let showName=responseJSON["show_name"] as! String
                                let cbsbh=responseJSON["cbsbh"] as! String
                                let cnName=responseJSON["cn_name"] as! String
                                //SVProgressHUD.showInfo(withStatus: "登陆成功")
                                
                                UserDefaults.standard.set(phoneNum, forKey: "phoneNum")
                                UserDefaults.standard.set(pwd, forKey: "pwd")
                                UserDefaults.standard.set(shipID, forKey: "shipID")
                                UserDefaults.standard.set(showName, forKey: "showName")
                                UserDefaults.standard.set(cbsbh, forKey: "cbsbh")
                                UserDefaults.standard.set(cnName, forKey: "cnName")
                                UserDefaults.standard.synchronize()
                                let vc = sb.instantiateViewController(withIdentifier: "HSCYTabBarController") as! HSCYTabBarController
                                UIApplication.shared.delegate?.window??.rootViewController=vc
                                //self.window?.makeKeyAndVisible()
                            }
                        }else {
                            SVProgressHUD.showInfo(withStatus: "服务器正在维护")
                        }
                    }
                }
            }
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    
    //iOS 10 Support
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        print(">JPUSHRegisterDelegate jpushNotificationCenter willPresent");
        let userInfo = notification.request.content.userInfo
        let aps = userInfo["aps"] as! Dictionary<String, AnyObject>
        let alert = aps["alert"]! as! String
        
        
        
        if alert.contains("请求添加你为好友"){
            //初始化 Alert Controller
            let alertController = UIAlertController(title: "通知", message: alert, preferredStyle: .alert)
            
            //设置 Actions
            let yesAction = UIAlertAction(title: "查看", style: .default){
                (action) -> Void in
                
                self.info=alert
                
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "HSCYAcceptOrRejectViewController") as! HSCYAcceptOrRejectViewController
                vc.delegate=self
                self.window?.rootViewController?.present(vc, animated: true, completion: {
                    
                    let tabVC=self.window?.rootViewController as! UITabBarController
                    tabVC.selectedIndex = 3
                    let vc1 = sb.instantiateViewController(withIdentifier: "HSCYMyFriendViewController") as! HSCYMyFriendViewController
                    
                    (tabVC.selectedViewController as! UINavigationController).pushViewController(vc1, animated: true)
                })
            }
            let noAction = UIAlertAction(title: "忽略", style: .default){ (action) -> Void in
                SVProgressHUD.showInfo(withStatus: "已忽略")
            }
            
            //添加 Actions，添加的先后和显示的先后顺序是有关系的
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            //展示Alert Controller
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }else if alert.contains("分享"){
            //初始化 Alert Controller
            let alertController = UIAlertController(title: "通知", message: alert, preferredStyle: .alert)
            
            //设置 Actions
            let yesAction = UIAlertAction(title: "查看", style: .default){
                (action) -> Void in
                
                self.shareInfo=alert
                
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "HSCYAcceptOrRejectShareViewController") as! HSCYAcceptOrRejectShareViewController
                vc.delegate=self
                self.window?.rootViewController?.present(vc, animated: true, completion:{
                    let tabVC=self.window?.rootViewController as! UITabBarController
                    tabVC.selectedIndex = 3
                    let vc1 = sb.instantiateViewController(withIdentifier: "HSCYSAssociatedShipViewController") as! HSCYSAssociatedShipViewController
                    
                    (tabVC.selectedViewController as! UINavigationController).pushViewController(vc1, animated: true)
                    
//                    vc1.segmentedControl.selectedSegmentIndex=1
//                    vc1.segmentChanged()
                }
                )
            }
            let noAction = UIAlertAction(title: "忽略", style: .default){ (action) -> Void in
                SVProgressHUD.showInfo(withStatus: "已忽略")
            }
            
            //添加 Actions，添加的先后和显示的先后顺序是有关系的
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            //展示Alert Controller
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        
        

        

        
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        print(">JPUSHRegisterDelegate jpushNotificationCenter didReceive")
        let userInfo = response.notification.request.content.userInfo
        
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        let aps = userInfo["aps"] as! Dictionary<String, AnyObject>
        let content = aps["alert"] as! NSString
        let badge = (aps["badge"] as! NSNumber).intValue
    
        UIApplication.shared.applicationIconBadgeNumber = badge-1
        JPUSHService.setBadge(badge-1)
        
        if content.contains("请求添加你为好友") {
            
            self.info=content as String
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "HSCYAcceptOrRejectViewController") as! HSCYAcceptOrRejectViewController
            vc.delegate=self
            self.window?.rootViewController?.present(vc, animated: true, completion: {
                
                let tabVC=self.window?.rootViewController as! UITabBarController
                tabVC.selectedIndex = 3
                let vc1 = sb.instantiateViewController(withIdentifier: "HSCYMyFriendViewController") as! HSCYMyFriendViewController
                
                (tabVC.selectedViewController as! UINavigationController).pushViewController(vc1, animated: true)
            })

        }else if content.contains("分享"){
            self.shareInfo=content as String
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "HSCYAcceptOrRejectShareViewController") as! HSCYAcceptOrRejectShareViewController
            vc.delegate=self
            self.window?.rootViewController?.present(vc, animated: true, completion:{
                let tabVC=self.window?.rootViewController as! UITabBarController
                tabVC.selectedIndex = 3
                let vc1 = sb.instantiateViewController(withIdentifier: "HSCYSAssociatedShipViewController") as! HSCYSAssociatedShipViewController
                
                (tabVC.selectedViewController as! UINavigationController).pushViewController(vc1, animated: true)
                
//                vc1.segmentedControl.selectedSegmentIndex=1
//                vc1.segmentChanged()
            })
            
            
        }
        completionHandler()
        
    }

    
    
    func jPushConfig(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        
        //调试时启用
        //JPUSHService.setDebugMode()
        
        //发布时启用
        JPUSHService.setLogOFF()
        JPUSHService.setup(withOption: launchOptions,
                           appKey: "3c38c6982f40f8a5f2423f99",
                           channel: "App Store",
                           apsForProduction: false)

    }
    
}
