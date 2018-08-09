//
//  NearView.swift
//  海事
//
//  Created by 丁建新 on 2017/7/12.
//  Copyright © 2017年 丁建新. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

@available(iOS 10.0, *)
class  NearView:UIViewController,MAMapViewDelegate,MAMultiPointOverlayRendererDelegate,CoordinateProperty,BridgeCoordinateProperty,CameraCoordinateProperty,WharfCoordinateProperty,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var FriendBoatBtn: UIButton!
    
    
    @IBOutlet weak var changeMap_btn: UIButton!
    
    
    @IBOutlet weak var changeMapName: UILabel!
    @IBOutlet weak var location_Btn: UIButton!
    @IBOutlet weak var zoomIn_btn: UIButton!
    @IBOutlet weak var zoomOut_btn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var seachBtn: UIButton!
    // let locationManager:CLLocationManager = CLLocationManager()
    var mapView: MAMapView!
    var annotations: Array<MAPointAnnotation>!
    var overlay: MAMultiPointOverlay!
    var boatAnnotationViews:Array<MAAnnotationView>!=[]
    var customUserLocationView: MAAnnotationView!
    var nearBySearch = true
    var canChange=false
    var canOpen=false
    var refresh=false
    var lat:Double=0
    var lng:Double=0
    var heading:Double=0
    var time:String=""
    var overlays: Array<MAOverlay>!
    var friendBoatListView:NearFriendListView!
    var boatBtnView:FriendBoatView!
    var lastL: Dictionary<String,Double>=["lat1":0,"lat2":0,"lng1":0,"lng2":0]
    var canRefresh:Bool=true
    var bridgeName:String=""
    var cameraName: String=""
    var wharfName: String=""
    let url="http://218.94.74.231:9999/SeaProject/allBoatPosition"
    let url2="http://218.94.74.231:9999/SeaProject/nearbyBoatPosition"
    let  firendship=[""]
    let screenh = UIScreen.main.bounds.size.height
    let screenw = UIScreen.main.bounds.size.width
    //下拉菊花
     let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
     var friendShipsArray:[Dictionary<String,AnyObject>]=[]
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendShips()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNot), name: NSNotification.Name(rawValue: "passValue") , object: nil)
        mapView=MAMapView(frame:view.bounds)
        mapView.delegate=self
        mapView.showsUserLocation=true
        mapView.userTrackingMode=MAUserTrackingMode.follow
        
        view.addSubview(mapView)
        initOverlay2()
        initArea()
       
        mapView.isRotateCameraEnabled=false
        
        //指南针设置
        mapView.showsCompass = true
        mapView.compassOrigin = CGPoint(x: 10, y: 121)
        
        //缩放按钮
        zoomIn_btn.addTarget(self, action: #selector(ZoomInAction), for: UIControlEvents.touchUpInside)
        zoomOut_btn.addTarget(self, action: #selector(ZoomOutAction), for: UIControlEvents.touchUpInside)
        
        
        zoomIn_btn.showsTouchWhenHighlighted = false
        zoomOut_btn.showsTouchWhenHighlighted = false
        location_Btn.addTarget(self, action: #selector(location), for: UIControlEvents.touchUpInside)
        zoomIn_btn.layer.cornerRadius=5
        zoomOut_btn.layer.cornerRadius=5
        zoomIn_btn.layer.borderWidth=1
        zoomOut_btn.layer.borderWidth=1
        zoomOut_btn.layer.borderColor=UIColor.lightGray.cgColor
        zoomIn_btn.layer.borderColor=UIColor.lightGray.cgColor
        zoomIn_btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        zoomOut_btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        
        view.bringSubview(toFront: location_Btn)
        view.bringSubview(toFront: zoomIn_btn)
        view.bringSubview(toFront: zoomOut_btn)
        view.bringSubview(toFront: SearchBar)
        view.bringSubview(toFront: seachBtn)
        view.bringSubview(toFront: changeMap_btn)
        view.bringSubview(toFront: changeMapName)
        view.bringSubview(toFront: FriendBoatBtn)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    
    
    //放大功能的实现
    func ZoomInAction(){
        mapView.setZoomLevel(mapView.zoomLevel+1, animated: true)
        
    }
    //缩小功能的实现
    func ZoomOutAction(){
        mapView.setZoomLevel(mapView.zoomLevel-1, animated: true)
        
    }
    //MARK:定位按钮的实现
    func location() {
        if refresh==true{
            analyticData(dic:screenLostation())
            self.mapView.setZoomLevel(14, animated: false)
            
        }
        else {
            SVProgressHUD.showInfo(withStatus: "正在加载")
        }
    }
    //MARK:获取屏幕四个角经纬度，从而获得标记点显示范围
    func  screenLostation() -> Dictionary<String,Any> {
        let centerLongitude=self.mapView.region.center.longitude
        let centerLatitude=self.mapView.region.center.latitude
        let  pointssLongitudeDelta=self.mapView.region.span.longitudeDelta
        let pointssLatitudeDelta=self.mapView.region.span.latitudeDelta
        //左上角
        let leftUpLong = centerLongitude - pointssLongitudeDelta/2.0
        let leftUpLati=centerLatitude+pointssLatitudeDelta/2.0
        //左下角
        let leftDownLati=centerLatitude-pointssLatitudeDelta/2.0
        //右下角
        let rightDownLong=centerLongitude + pointssLongitudeDelta/2.0
        
        
        
        
        let ship_id:String! = UserDefaults.standard.string(forKey: "shipID")
        
        let dic = ["lat1": leftDownLati, "lat2": leftUpLati, "lng1": leftUpLong, "lng2": rightDownLong,
                   "ship_id": ship_id] as [String : Any]
        
        return dic
        
    }
    
    
    
    
    //MARK:根据缩放级别来隐藏和显示海量点和markers
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        
        if mapView.zoomLevel<14{
            canRefresh=true
        }
        if mapView.zoomLevel>=14&&canRefresh{
            
            self.mapView.removeAnnotations(self.annotations)
            initBridge()
            initAnnotations3(dic: screenLostation())
            initCamera()
            initWharf()
            initAreaName()
            if (overlay.isKind(of: MAMultiPointOverlay.self)){
                self.mapView.remove(self.overlay)
            }
            
            
            
            canRefresh=false
            
            
        }
        else if mapView.zoomLevel<14{
            self.mapView.removeAnnotations(self.annotations)
            
            self.mapView.remove(self.overlay)
            self.mapView.add(self.overlay)
            
        }
        
    }
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        var currentDic=screenLostation()
        currentDic["ship_id"]=nil
        let currentL=currentDic as! Dictionary<String, Double>
        if shouldRefreshMap(oldCoor:lastL, newCoor:currentL){
            if mapView.zoomLevel>=14{
                self.mapView.removeAnnotations(self.annotations)
                initBridge()
                initWharf()
                initAnnotations3(dic: screenLostation())
                initCamera()
                initAreaName()
                self.mapView.remove(self.overlay)
                self.mapView.remove(self.overlay)
                
                self.mapView.remove(self.overlay)
                
                
                lastL=currentL
                
            }
                
            else if mapView.zoomLevel<14{
                self.mapView.removeAnnotations(self.annotations)
                self.mapView.remove(self.overlay)
                self.mapView.add(self.overlay)
            }
            
            
            
        }
    }
    //    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
    //        var currentDic=screenLostation()
    //        currentDic["ship_id"]=nil
    //        let currentL=currentDic as! Dictionary<String, Double>
    //        if shouldRefreshMap(oldCoor:lastL, newCoor:currentL){
    //            if mapView.zoomLevel>=14{
    //                self.mapView.removeAnnotations(self.annotations)
    //                initBridge()
    //                initWharf()
    //                initAnnotations3(dic: screenLostation())
    //                initCamera()
    //                initAreaName()
    //                self.mapView.remove(self.overlay)
    //                self.mapView.remove(self.overlay)
    //
    //                self.mapView.remove(self.overlay)
    //
    //
    //                lastL=currentL
    //
    //            }
    //
    //            else if mapView.zoomLevel<14{
    //                self.mapView.removeAnnotations(self.annotations)
    //                self.mapView.remove(self.overlay)
    //                self.mapView.add(self.overlay)
    //            }
    //
    //
    //
    //        }
    //    }
    //
    
    
    func shouldRefreshMap(oldCoor dic0:Dictionary<String,Double>,newCoor dic1:Dictionary<String, Double>) -> Bool{
        let maxLat0=dic0["lat2"]!
        let minLat0=dic0["lat1"]!
        let maxLng0=dic0["lng2"]!
        let minLng0=dic0["lng1"]!
        
        let maxLat1=dic1["lat2"]!
        let minLat1=dic1["lat1"]!
        let maxLng1=dic1["lng2"]!
        let minLng1=dic1["lng1"]!
        let newCenterLat=(maxLat1+minLat1)/2
        let newCenterLng=(maxLng1+minLng1)/2
        
        let dxlat=maxLat0-minLat0
        let dxlng=maxLng0-minLng0
        
        let maxLat=maxLat0+0.5*dxlat
        let minLat=minLat0-0.5*dxlat
        let maxLng=maxLng0+0.5*dxlng
        let minLng=minLng0-0.5*dxlng
        
        if (newCenterLat>maxLat)||(newCenterLat<minLat)||(newCenterLng>maxLng)||(newCenterLng<minLng){
            return true
        }
        return false
    }
    //    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
    //
    //        if (!updatingLocation){
    //            if (annotations != nil){
    //            for annotation in annotations{
    //            if(!updatingLocation && self.customUserLocationView != nil) {
    //                UIView.animate(withDuration: 0.1, animations: {
    //                    let degree = Double(self.mapView.rotationDegree)-Double(annotation.subtitle!)!
    //                    let radian = (degree * Double.pi) / 180.0
    //                    self.customUserLocationView.transform = CGAffineTransform.init(rotationAngle: CGFloat(radian))
    //                })
    //                }
    //                }
    //            }
    //            else {
    //             SVProgressHUD.showInfo(withStatus: "正在加载")
    //            }
    //        }
    //
    //    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool=false) {
        //print(annotations)
        if (!updatingLocation && boatAnnotationViews != nil){
            
            for boatAnnotationView in boatAnnotationViews{
                
                
                let dxRotation = -Double(self.mapView.rotationDegree)
                
                let radian = (dxRotation * Double.pi) / 180.0
                boatAnnotationView.transform=CGAffineTransform.init(rotationAngle: CGFloat(radian))
                
            }
        }
            
            
        else {
            //print(annotations)
        }
        
        
    }
    
    
    
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAUserLocation{
            return nil
        }
        if (annotation.isKind(of: MAPointAnnotation.self)){
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? CustomAnnotationView
            
            
            if annotationView == nil {
                annotationView = CustomAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = false
            annotationView!.isDraggable = true
            
            //在地图上显示船名
            let nameLabel:UILabel=UILabel()
            
            annotationView?.addSubview(nameLabel)
            //            nameLabel.text=annotation.title!
            nameLabel.font=UIFont.systemFont(ofSize: 12)
            nameLabel.textColor=UIColor.darkGray
            nameLabel.backgroundColor=UIColor.white
            nameLabel.layer.borderColor=UIColor.green.cgColor
            nameLabel.layer.borderWidth = 0.5
            //            nameLabel.adjustsFontSizeToFitWidth=true
            let contentText:NSString = annotation.title!  as NSString
            nameLabel.text=" "+(contentText as String) as String
            
            let constraint = CGSize(width: 0, height: 20)
            let attributes:NSDictionary = NSDictionary(object:UIFont.systemFont(ofSize: 12),forKey: NSFontAttributeName as NSCopying)
            let size = contentText.boundingRect(with: constraint,options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                attributes:attributes as? [String : AnyObject],context: nil)
            nameLabel.frame=CGRect.init(x: 30, y: 0, width:size.width+10
                , height: 20)
            
            
            annotationView?.isEnabled=false
            let lineLabel:UILabel=UILabel()
            
            lineLabel.frame=CGRect.init(x: 10, y: 0, width: 50, height: 20)
            annotationView?.addSubview(lineLabel)
            lineLabel.text="———"
            lineLabel.font=UIFont.systemFont(ofSize: 12)
            let areaNameLabel:UILabel=UILabel()
            areaNameLabel.frame=CGRect.init(x: 0, y: 0, width: 100, height: 20)
            areaNameLabel.textColor=UIColor.black
            areaNameLabel.text=annotation.title
            annotationView?.isEnabled=false
            if annotation.title==UserDefaults.standard.string(forKey: "showName")
            {
                annotationView?.delegate=self
                annotationView?.isEnabled=true
                annotationView?.image=#imageLiteral(resourceName: "my_boat2")
                annotationView?.canShowCallout=false
                let degree = Double(annotation.subtitle!)!-Double(self.mapView.rotationDegree)
                let radian = (degree * Double.pi) / 180.0
                annotationView?.imageView.transform = CGAffineTransform.init(rotationAngle:CGFloat(radian))
                self.boatAnnotationViews.append(annotationView!)
                self.customUserLocationView=annotationView
                
            }
            else if annotation.title=="桥"{
                annotationView?.image=#imageLiteral(resourceName: "bridge_resource")
                annotationView?.canShowCallout=false
                nameLabel.removeFromSuperview()
                lineLabel.removeFromSuperview()
                annotationView?.isUserInteractionEnabled = true
                let tapGesture = HSCYTapGestureRecognizer(target: self, action: #selector(bridgeBtnAction))
                tapGesture.bridgeViewName=annotation.subtitle!
                tapGesture.numberOfTapsRequired = 1
                annotationView?.addGestureRecognizer(tapGesture)
                
            }
            else if annotation.title=="摄像头"{
                
                annotationView?.image=#imageLiteral(resourceName: "camera_resources")
                annotationView?.canShowCallout=false
                nameLabel.removeFromSuperview()
                lineLabel.removeFromSuperview()
                annotationView?.isUserInteractionEnabled = true
                let tapGesture = HSCYTapGestureRecognizer(target: self, action: #selector(cameraBtnAction))
                tapGesture.cameraViewName=annotation.subtitle!
                tapGesture.numberOfTapsRequired = 1
                annotationView?.addGestureRecognizer(tapGesture)
            }
            else if annotation.title=="码头"{
                annotationView?.image=#imageLiteral(resourceName: "wharf_resources")
                annotationView?.canShowCallout=false
                nameLabel.removeFromSuperview()
                lineLabel.removeFromSuperview()
                annotationView?.isUserInteractionEnabled = true
                let tapGesture = HSCYTapGestureRecognizer(target: self, action: #selector(wharfBtnAction))
                tapGesture.wharfViewName=annotation.subtitle! as String
                tapGesture.numberOfTapsRequired = 1
                annotationView?.addGestureRecognizer(tapGesture)
                
            }
                
            else if annotation.title=="限速区"{
                annotationView?.addSubview(areaNameLabel)
                nameLabel.removeFromSuperview()
                lineLabel.removeFromSuperview()
                
            }
            else if annotation.title=="禁泊区"{
                annotationView?.addSubview(areaNameLabel)
                nameLabel.removeFromSuperview()
                lineLabel.removeFromSuperview()
                
            }
            else if annotation.title=="禁航区"{
                annotationView?.addSubview(areaNameLabel)
                nameLabel.removeFromSuperview()
                lineLabel.removeFromSuperview()
                
            }
                //            -Double(self.mapView.rotationDegree)
                
                
            else{
                annotationView?.image=#imageLiteral(resourceName: "green")
                annotationView?.canShowCallout=false
                let degree = Double(self.mapView.rotationDegree)-Double(annotation.subtitle!)!
                let radian = (degree * Double.pi) / 180.0
                annotationView?.imageView.transform = CGAffineTransform.init(rotationAngle:CGFloat(radian))
                self.customUserLocationView=annotationView
                self.boatAnnotationViews.append(annotationView!)
            }
            
            
            
            
            //            annotationView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            //设置namelabel边框
            //            nameLabel.layer.borderWidth=200
            //            nameLabel.layer.borderColor = UIColor.white.cgColor
            
            //将name图片带到线的前面
            annotationView?.bringSubview(toFront: (annotationView?.imageView)!)
            annotationView?.bringSubview(toFront: nameLabel)
            
            return annotationView!
            
            
        }
        
        
        return nil
    }
    
    
    
    
    
    
    
    
    //MARK:加载海量点图层
    func  initOverlay2(){
        var items=[MAMultiPointItem]()
        Alamofire.request("http://218.94.74.231:9999/SeaProject/allBoatPosition").responseJSON{
            response in debugPrint(response)
            if let value=response.result.value{
                let json = JSON(value).arrayObject
                for elem in json! {
                    let item = MAMultiPointItem()
                    let dic = elem as? [String: Any]
                    
                    if let coordinate = dic {
                        let lng:Double? = coordinate["lng"] as? Double
                        let lat:Double? = coordinate["lat"] as? Double
                        
                        item.coordinate=CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                        items.append(item)
                        
                        
                    }
                }
                self.overlay = MAMultiPointOverlay(multiPointItems: items)
                self.mapView.add(self.overlay)
                self.refresh=true
                
            }
        }
    }
    
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAMultiPointOverlay.self))
        {
            let renderer = MAMultiPointOverlayRenderer(multiPointOverlay: overlay as! MAMultiPointOverlay!)
            renderer!.delegate = self
            renderer!.icon = UIImage(named: "marker_blue")
            return renderer
        }
            //            &&(mapView.zoomLevel>=14&&mapView.zoomLevel<15||mapView.zoomLevel==17)
        else if overlay.isKind(of: MAPolygon.self){
            let renderer: MAPolygonRenderer = MAPolygonRenderer(overlay: overlay)
            renderer.lineWidth = 1
            renderer.strokeColor = UIColor.red
            renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
            
            return renderer
        }
        
        return nil
    }
    //MARK: - MAMultiPointOverlayRendererDelegate
    
    //MARK:搜素页面的跳转按钮的实现
    @IBAction func segueAction(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "seachSegue", sender: nil)
        
    }
    
    
    func  analyticData(dic:Dictionary<String,Any>){
        Alamofire.request(url2, method:.post,parameters:dic).responseJSON{
            
            response in debugPrint(response)
            if let value=response.result.value{
                // 遍历附近的船舶
                //加载自己船舶
                let  json3=JSON(value).dictionaryObject
                if (json3?["ship_id"] as? String)=="无法查找"{
                    SVProgressHUD.showInfo(withStatus: "无法查找")
                }else{
                    self.lat=(json3?["lat"]as?Double)!
                    self.lng=(json3?["lng"]as?Double)!
                    self.heading=(json3?["heading"]as?Double)!
                    self.time=(json3?["time"]as?String)!
                    UserDefaults.standard.set(json3?["speed"] as? Float, forKey: "speed")
                    let amapcoord2 = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng), AMapCoordinateType.GPS)
                    self.mapView.centerCoordinate=amapcoord2
                }
            }
            
        }
    }
    //MARK::加载船舶图层
    
    
    func initAnnotations3(dic:Dictionary<String,Any>){
        
        
        annotations = Array()
        Alamofire.request(url2, method:.post,parameters:dic).responseJSON{
            
            response in debugPrint(response)
            if let value=response.result.value{
                // 遍历附近的船舶
                let json = JSON(value)["otherBoat"].arrayObject
                
                for elem in json!{
                    let dict=elem as?[String:Any]
                    
                    if  let coordinate = dict {
                        
                        //加载自己船舶
                        let  json2=JSON(value).dictionaryObject
                        let myLat:Double?=json2?["lat"]as?Double
                        let myLng:Double?=json2?["lng"]as?Double
                        let myAngle:Double?=json2?["heading"]as?Double
                        let myBoatName:String=json2?["cn_name"]as!String
                        let myBoatNum:String=json2?["cbsbh"]as!String
                        UserDefaults.standard.set(json2?["speed"] as? Float, forKey: "speed")
                        let myAmapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: myLat!, longitude: myLng!), AMapCoordinateType.GPS)
                        let coor2=myAmapcoord
                        let myBoatAngle=CLLocationDirection(myAngle!)
                        let anno2=MAPointAnnotation()
                        anno2.title=myBoatName
                        anno2.coordinate=coor2
                        anno2.subtitle=String(myBoatAngle)
                        
                        // 加载附近船舶
                        
                        let lng:Double? = coordinate["lng"] as? Double
                        let lat:Double? = coordinate["lat"] as? Double
                        let angle:Double?=coordinate["heading"] as?Double
                        let boatName:String=coordinate["show_name"] as! String
                        
                        //高德地图转化天地图
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: lat!, longitude: lng!), AMapCoordinateType.GPS)
                        let coor=amapcoord
                        let BoatAngle=CLLocationDirection(angle!)
                        let anno=MAPointAnnotation()
                        anno.title = boatName
                        anno.coordinate=coor
                        anno.subtitle=String(BoatAngle)
                        self.annotations.append(anno)
                        self.annotations.append(anno2)
                        
                    }
                    
                }
                
                self.mapView.addAnnotations(self.annotations)
                
            }
            
        }
        
        
    }
    
    //MARK:加载桥梁
    func initBridge(){
        annotations = Array()
        Alamofire.request("http://218.94.74.231:9999/SeaProject/bridgeRes").responseJSON{
            response in debugPrint(response)
            if let value=response.result.value{
                let   bridgeJSON=JSON(value).arrayObject
                for elem in bridgeJSON!{
                    let dict=elem as?[String:Any]
                    
                    if  let coordinate = dict{
                        let briLat:Double? = coordinate["lat"] as? Double
                        let briLng:Double?=coordinate["lng"]as?Double
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: briLat!, longitude: briLng!), AMapCoordinateType.GPS)
                        
                        let anno3=MAPointAnnotation()
                        anno3.coordinate=amapcoord
                        let name:String="桥"
                        anno3.title=name
                        anno3.subtitle=coordinate["bridgeName"] as! String
                        self.annotations.append(anno3)
                        
                    }
                }
                self.mapView.addAnnotations(self.annotations)
            }
            
            
            
        }
    }
    
    //MARK:渲染监控点
    func initCamera(){
        annotations = Array()
        Alamofire.request("http://218.94.74.231:9999/SeaProject/cameraRes").responseJSON{
            response in debugPrint(response)
            if let value=response.result.value{
                let   cameraJSON=JSON(value).arrayObject
                for elem in cameraJSON!{
                    let dict=elem as?[String:Any]
                    
                    if  let coordinate = dict{
                        let camLat:Double? = coordinate["lat"] as? Double
                        let camLng:Double?=coordinate["lng"]as?Double
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: camLat!, longitude: camLng!), AMapCoordinateType.GPS)
                        let anno4=MAPointAnnotation()
                        anno4.coordinate=amapcoord
                        let name:String="摄像头"
                        anno4.title=name
                        anno4.subtitle=coordinate["cameraName"] as! String
                        self.annotations.append(anno4)
                    }
                }
                self.mapView.addAnnotations(self.annotations)
            }
            
            
            
        }
        
    }
    func  initWharf(){
        annotations = Array()
        Alamofire.request("http://218.94.74.231:9999/SeaProject/wharfRes").responseJSON{
            response in debugPrint(response)
            if let value=response.result.value{
                var   wharfJSON=JSON(value).arrayObject
                print("wharf\(wharfJSON)")
                //                wharfJSON?.remove(at: (wharfJSON?.count)!-5)
                for elem in wharfJSON!{
                    let dict=elem as?[String:AnyObject]
                    // 删除wharfName为null时处理
                    
                    if let wharfdict=dict?["wharfName"] as? NSNull{
                        continue
                    }
                    if  let coordinate = dict{
                        let whaLat:Double? = coordinate["lat"] as? Double
                        let whaLng:Double?=coordinate["lng"]as?Double
                        
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: whaLat!, longitude: whaLng!), AMapCoordinateType.GPS)
                        
                        let wharfAnno=MAPointAnnotation()
                        wharfAnno.coordinate=amapcoord
                        
                        let name:String="码头"
                        wharfAnno.title=name
                        
                        wharfAnno.subtitle=coordinate["wharfName"] as! String
                        
                        self.annotations.append(wharfAnno)
                        
                    }
                    
                }
                self.mapView.addAnnotations(self.annotations)
            }
            
            
            
        }
        
        
        
    }
    func initArea(){
        overlays=Array()
        
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getLimitRange").responseJSON{
            response in debugPrint(response)
            if let value=response.result.value{
                
                
                let json=JSON(value)[ "ELEC_NAVIGATION_LIMIT_RANGE"].arrayObject
                
                let json2=JSON(value)["ELEC_PROHIBITIED_ANCHOR_RANGE"].arrayObject
                let json3=JSON(value)["ELEC_SPEED_LIMIT_RANGE"].arrayObject
                if (json != nil){
                for elem in json!{
                    
                    let dic = elem as?[String:Any]
                    
                    if let coor=dic{
                        let  coorData:String=coor["RANGE_WKT"]as!String
                        
                        let arr=self.trimStupidString(str: coorData)
                        
                        
                        var cllArr:[CLLocationCoordinate2D]=[]
                        
                        for point in arr{
                            let cllC=AMapCoordinateConvert(CLLocationCoordinate2D(latitude: point.1, longitude: point.0), AMapCoordinateType.GPS)
                            
                            cllArr.append(cllC)
                            
                        }
                        
                        let polygon: MAPolygon = MAPolygon(coordinates: &cllArr, count: UInt(cllArr.count))
                        
                        self.overlays.append(polygon)
                        
                    }
                }
                }
                
                
                
                
                if (json2 != nil){
                for elem in json2!{
                    
                    let dic = elem as?[String:Any]
                    
                    if let coor=dic{
                        let  coorData:String=coor["RANGE_WKT"]as!String
                        let arr=self.trimStupidString(str: coorData)
                        
                        var cllArr:[CLLocationCoordinate2D]=[]
                        
                        
                        for point in arr{
                            let cllC=AMapCoordinateConvert(CLLocationCoordinate2D(latitude: point.1, longitude: point.0), AMapCoordinateType.GPS)
                            
                            cllArr.append(cllC)
                            
                            
                        }
                        let polygon: MAPolygon = MAPolygon(coordinates: &cllArr, count: UInt(cllArr.count))
                        
                        self.overlays.append(polygon)
                        
                    }
                }
                }
                if (json3 != nil){
                for elem in json3!{
                    
                    let dic = elem as?[String:Any]
                    
                    if let coor=dic{
                        let  coorData:String=coor["RANGE_WKT"]as!String
                        
                        let arr=self.trimStupidString(str: coorData)
                        
                        
                        var cllArr:[CLLocationCoordinate2D]=[]
                        
                        
                        for point in arr{
                            let cllC=AMapCoordinateConvert(CLLocationCoordinate2D(latitude: point.1, longitude: point.0), AMapCoordinateType.GPS)
                            
                            cllArr.append(cllC)
                            
                            
                            
                        }
                        
                        let polygon: MAPolygon = MAPolygon(coordinates: &cllArr, count: UInt(cllArr.count))
                        polygon.title="限速区"
                        
                        self.overlays.append(polygon)
                        
                        
                    }
                }
                
                self.mapView.addOverlays(self.overlays)
                
                
            }
        }
        }
        
    }
    func initAreaName(){
        
        annotations=Array()
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getLimitRange").responseJSON{
            response in debugPrint(response)
            if let value=response.result.value{
                let json=JSON(value)[ "ELEC_NAVIGATION_LIMIT_RANGE"].arrayObject
                let json2=JSON(value)["ELEC_PROHIBITIED_ANCHOR_RANGE"].arrayObject
                let json3=JSON(value)["ELEC_SPEED_LIMIT_RANGE"].arrayObject
                
                for elem in json!{
                    
                    let dic = elem as?[String:Any]
                    
                    if let coor=dic{
                        let  coorData:String=coor["RANGE_WKT"]as!String
                        
                        let arr=self.trimStupidString(str: coorData)
                        
                        
                        var latArr:[Double]=[]
                        var lngArr:[Double]=[]
                        
                        for point in arr{
                            
                            latArr.append(point.1)
                            lngArr.append(point.0)
                            
                        }
                        var latSum:Double=0
                        var lngSum:Double=0
                        for i in 0..<latArr.count {
                            latSum+=latArr[i]
                            
                        }
                        for i in 0..<lngArr.count {
                            lngSum+=lngArr[i]
                        }
                        
                        
                        let cenLat=latSum/Double(latArr.count)
                        let cenLng=lngSum/Double(lngArr.count)
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude:cenLat, longitude: cenLng), AMapCoordinateType.GPS)
                        let anno9=MAPointAnnotation()
                        anno9.coordinate=amapcoord
                        anno9.title="禁航区"
                        self.annotations.append(anno9)
                        
                        
                    }
                }
                
                
                
                
                
                for elem in json2!{
                    
                    let dic = elem as?[String:Any]
                    
                    if let coor=dic{
                        let  coorData:String=coor["RANGE_WKT"]as!String
                        let arr=self.trimStupidString(str: coorData)
                        
                        
                        var latArr:[Double]=[]
                        var lngArr:[Double]=[]
                        
                        for point in arr{
                            
                            latArr.append(point.1)
                            lngArr.append(point.0)
                            
                        }
                        var latSum:Double=0
                        var lngSum:Double=0
                        for i in 0..<latArr.count {
                            latSum+=latArr[i]
                            
                        }
                        for i in 0..<lngArr.count {
                            lngSum+=lngArr[i]
                        }
                        
                        
                        let cenLat=latSum/Double(latArr.count)
                        let cenLng=lngSum/Double(lngArr.count)
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude:cenLat, longitude: cenLng), AMapCoordinateType.GPS)
                        let anno6=MAPointAnnotation()
                        anno6.coordinate=amapcoord
                        anno6.title="禁泊区"
                        self.annotations.append(anno6)
                        
                        
                    }
                }
                for elem in json3!{
                    
                    let dic = elem as?[String:Any]
                    
                    if let coor=dic{
                        let  coorData:String=coor["RANGE_WKT"]as!String
                        
                        let arr=self.trimStupidString(str: coorData)
                        
                        
                        
                        var latArr:[Double]=[]
                        var lngArr:[Double]=[]
                        
                        for point in arr{
                            
                            
                            latArr.append(point.1)
                            lngArr.append(point.0)
                            
                            
                        }
                        var latSum:Double=0
                        var lngSum:Double=0
                        for i in 0..<latArr.count {
                            latSum+=latArr[i]
                            
                        }
                        for i in 0..<lngArr.count {
                            lngSum+=lngArr[i]
                        }
                        
                        
                        let cenLat=latSum/Double(latArr.count)
                        let cenLng=lngSum/Double(lngArr.count)
                        
                        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude:cenLat, longitude: cenLng), AMapCoordinateType.GPS)
                        let anno7=MAPointAnnotation()
                        anno7.coordinate=amapcoord
                        anno7.title="限速区"
                        
                        
                        self.annotations.append(anno7)
                        
                        
                    }
                }
                
                self.mapView.addAnnotations(self.annotations)
                
                
            }
        }
        
    }
    
    
    func bridgeBtnAction(gesture:HSCYTapGestureRecognizer){
        print("----------------已点击")
        
        let bridgeVC=HSCYBridgeInfoTableViewController()
        self.bridgeName=gesture.bridgeViewName
        bridgeVC.delegate=self
        self.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(bridgeVC, animated: true)
        self.hidesBottomBarWhenPushed=false
        
        
    }
    func cameraBtnAction(gesture:HSCYTapGestureRecognizer){
        
        print("----------------摄像头点击")
        let cameraVC=HSCYCameraInfoTableViewController()
        self.cameraName=gesture.cameraViewName
        cameraVC.delegate=self
        self.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(cameraVC, animated: true)
        self.hidesBottomBarWhenPushed=false
        
        
    }
    func wharfBtnAction(gesture:HSCYTapGestureRecognizer){
        
        print("----------------码头点击")
        let wharfVC=HSCYWharfInfoTableViewController()
        self.wharfName=gesture.wharfViewName
        wharfVC.delegate=self
        self.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(wharfVC, animated: true)
        self.hidesBottomBarWhenPushed=false
        
        
    }
    
    
    
    
    func btnAction(){
        
        let vc=HSCYBoatInfoTableViewController()
        vc.delegate=self
        self.hidesBottomBarWhenPushed=true
        self.navigationController?.pushViewController(vc, animated:true)
        self.hidesBottomBarWhenPushed=false
    }
    
    func  receiveNot(info:Notification){
        
        let dic=info.userInfo as! Dictionary<String, Double>
        let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: dic["lat"]!, longitude: dic["lng"]!), AMapCoordinateType.GPS)
        mapView.centerCoordinate=amapcoord
        mapView.setZoomLevel(17, animated: false)
        canRefresh=true
    }
    
    //传入一个参数字符串str:"POLYGON((120.82676694423361 32.02644379619999,120.82846210033102 32.024845199627116,120.82340538941108 32.02017214642913,120.82173169098579 32.02230718480499,120.82676694423361 32.02644379619999))"
    //返回一个(double,double)数组arr:[(120.82676694423361, 32.026443796199992), (120.82846210033102, 32.024845199627116), (120.82340538941108, 32.020172146429132), (120.82173169098579, 32.022307184804987), (120.82676694423361, 32.026443796199992)]
    /*  使用例子
     let arr=trimStupidString(str)
     arr[0].0即120.82676694423361
     arr[2].1即32.024845199627116
     */
    func trimStupidString(str:String) -> [(Double,Double)]{
        var tupleArray:[(Double,Double)]=[]
        let start = str.index(str.startIndex, offsetBy: 9)
        let end = str.index(str.endIndex, offsetBy: -2)
        let myRange = start..<end
        let str1=str.substring(with: myRange)
        
        let arr1 = str1.components(separatedBy: ",")
        for elem in arr1{
            let arr2=elem.components(separatedBy: " ")
            let tuple=((arr2[0] as NSString).doubleValue,(arr2[1] as NSString).doubleValue)
            tupleArray.append(tuple)
        }
        return tupleArray
    }
    
    @IBAction func changeMapVIewAction(_ sender: Any) {
        let segmentedControl=sender as!UISegmentedControl
        switch  segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
            
            
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
        
    }
    
    
    @IBAction func changeMapAction(_ sender: Any) {
        if canChange {
            mapView.mapType = .standard
            SearchBar.backgroundColor=UIColor.clear
            changeMapName.text="卫星"
            let anim = CABasicAnimation(keyPath: "transform.rotation")
            anim.toValue = 1 * Double.pi
            anim.duration = 1
            anim.repeatCount = MAXFLOAT
            anim.isRemovedOnCompletion = true
            changeMap_btn.imageView?.layer.add(anim, forKey: nil)
            changeMap_btn.imageView?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                self.changeMap_btn.imageView?.transform = (self.changeMap_btn.imageView?.transform.rotated(by: CGFloat(Double.pi)))!
            }
            
        }
        else{
            mapView.mapType = .satellite
            SearchBar.backgroundColor=UIColor.clear
            changeMapName.text="2D"
            let anim = CABasicAnimation(keyPath: "transform.rotation")
            anim.toValue = -1 * Double.pi
            anim.duration = 1
            anim.repeatCount = MAXFLOAT
            anim.isRemovedOnCompletion = true
            changeMap_btn.imageView?.layer.add(anim, forKey: nil)
            changeMap_btn.imageView?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                self.changeMap_btn.imageView?.transform = (self.changeMap_btn.imageView?.transform.rotated(by: CGFloat(Double.pi)))!
            }
            
        }
        canChange = !canChange
    }
   
    //好友船舶按钮实现方法
    @IBAction func FriendBoatBtnAction(_ sender: Any) {
        
        
        if !canOpen{
              getFriendShips()
            loadFriendView()
            setupRefresh()
            
            
                
          
            
            
        }
        else {
            friendBoatListView.removeFromSuperview()
            
        }
        canOpen = !canOpen
    }
    
    //好友船舶数据
    func getFriendShips() {
        let phoneNum=UserDefaults.standard.string(forKey: "phoneNum")
        let param=[
            "phoneNum":phoneNum!,
            ]
        Alamofire.request("http://218.94.74.231:9999/SeaProject/getShareShips", method: .post, parameters: param).responseJSON{
            (returnResult) in
            if let response=returnResult.result.value{
                
                if let dicArr=JSON(response).arrayObject as? [Dictionary<String, AnyObject>]{
                    self.friendShipsArray=dicArr
                    
                    print("好友列表船舶：\(dicArr.count)")
//                    self.friendBoatListView.collectionView.reloadData()
                }else{
                    SVProgressHUD.showInfo(withStatus: "服务器错误")
                }
            }
        }
        
    }
    
    //好友船舶点击定位方法实现
    func getFriendShipAction(sender:UIButton){
        let centerLongitude=self.mapView.region.center.longitude
        let centerLatitude=self.mapView.region.center.latitude
        let  pointssLongitudeDelta=self.mapView.region.span.longitudeDelta
        let pointssLatitudeDelta=self.mapView.region.span.latitudeDelta
        //左上角
        let leftUpLong = centerLongitude - pointssLongitudeDelta/2.0
        let leftUpLati=centerLatitude+pointssLatitudeDelta/2.0
        //左下角
        let leftDownLati=centerLatitude-pointssLatitudeDelta/2.0
        //右下角
        let rightDownLong=centerLongitude + pointssLongitudeDelta/2.0
        
        
        
        
        let friendShip=friendShipsArray[sender.tag]
        let shipID=friendShip["ship_id"] as! String
        
        let param = ["lat1": leftDownLati, "lat2": leftUpLati, "lng1": leftUpLong, "lng2": rightDownLong,
                   "ship_id": shipID] as [String : Any]
        Alamofire.request(url2, method:.post,parameters:param).responseJSON{
            
            response in debugPrint(response)
            if let value=response.result.value{
                // 遍历附近的船舶
                //加载自己船舶
                let  json=JSON(value).dictionaryObject
                if (json?["ship_id"] as? String)=="无法查找"{
                    SVProgressHUD.showInfo(withStatus: "无法查找")
                }else{
                    self.lat=(json?["lat"]as?Double)!
                    self.lng=(json?["lng"]as?Double)!
                    self.heading=(json?["heading"]as?Double)!
                    self.time=(json?["time"]as?String)!
                    let amapcoord = AMapCoordinateConvert(CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng), AMapCoordinateType.GPS)
                    self.mapView.centerCoordinate=amapcoord
                }
            }
            
        }
    
        
       
    }
    //好友船舶列表
    func loadFriendView() {
        
        friendBoatListView=Bundle.main.loadNibNamed("NearFriendListView", owner: self, options: nil)!.first as! NearFriendListView
       
        self.friendBoatListView.addSubview(self.friendBoatListView.collectionView)
        
        self.friendBoatListView.collectionView.dataSource = self
        self.friendBoatListView.collectionView.delegate = self
        self.friendBoatListView.collectionView.register(UINib.init(nibName: "FriendBoatView", bundle: nil), forCellWithReuseIdentifier: "cell")
        friendBoatListView.collectionView.backgroundColor=UIColor.white
        self.view.addSubview(friendBoatListView)
        
        friendBoatListView.frame=CGRect.init(x: 10, y:FriendBoatBtn.frame.maxY,width:UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height*0.35)

    }
   
    /*
     好友列表collectionView的协议方法
     **/
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("数组长度：\(friendShipsArray.count)")
       
        return friendShipsArray.count
    }
    //cellForItemAt indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!FriendBoatView
        cell.BoatNameLabel.text=friendShipsArray[indexPath.row]["ship_name"] as? String
     
       cell.BoatNameLabel.font=UIFont.systemFont(ofSize: 10)
       cell.backgroundColor=UIColor.white
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
         friendBoatListView.removeFromSuperview()
        canOpen = !canOpen
        getFriendShipAction(sender: FriendBoatBtn)
         self.mapView.setZoomLevel(17, animated: false)
        
    }
    func setupRefresh() {
        let refreshControl=UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDrag), for: UIControlEvents.valueChanged)
       
            
   
    self.friendBoatListView.collectionView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        
        self.refreshDrag(refreshControl: refreshControl)
        
    }
    func refreshDrag(refreshControl:UIRefreshControl) {
        refreshControl.endRefreshing()
        getFriendShips()
        
    }
}
 

