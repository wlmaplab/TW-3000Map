//
//  ViewController.swift
//  3000Map
//
//  Created by rlbot on 2020/7/1.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var myLocationButton : UIButton!
    @IBOutlet var messageView : UIView!
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var indicatorView : UIActivityIndicatorView!
    
    
    let locationManager = CLLocationManager()
    let siteCoordinate = CLLocationCoordinate2D(latitude: 22.996787, longitude: 120.2114242) //台南火車站前站
    
    var isMoveToUserLocation = true
    var lastUpdatedDate : Date?
    var checkTimer : Timer?
    
    var postAnnotationArray = Array<PostAnnotation>()
    var opendPostDetailsStoreCd : String = ""
    
    
    // MARK: - Object
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - viewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchData(showMessage: "正在下載資料...")
    }
    
    
    // MARK: - Setup
    
    func setup() {
        // setup VC title
        self.title = "三倍券郵局地圖"
        
        // setup UI
        setupRightButtonItem()
        setupIndicatorAndMessageView()
        setupMyLocationButton()
        
        // setup Location
        setupLocationManager()
        setupMyLocation()
        moveToSiteLocation()
        mapView.showsUserLocation = true
        
        // setup Notification
        setupNotificationCenter()
    }
    
    func setupRightButtonItem() {
        let button = UIButton(type: .infoLight)
        button.addTarget(self, action: #selector(pressedInfoButtonItem), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func setupIndicatorAndMessageView() {
        indicatorView.color = .white
        indicatorView.stopAnimating()
        
        messageView.backgroundColor = .systemBlue
        messageLabel.backgroundColor = .clear
        messageLabel.textColor = .white
        messageLabel.adjustsFontSizeToFitWidth = true
        
        messageView.alpha = 0
        messageLabel.text = ""
    }
    
    func setupMyLocationButton() {
        myLocationButton.titleLabel?.numberOfLines = 2
        myLocationButton.setTitle("定\n位", for: .normal)
        
        myLocationButton.layer.shadowColor = UIColor.lightGray.cgColor
        myLocationButton.layer.shadowOffset = CGSize(width: 1, height: 3)
        myLocationButton.layer.shadowOpacity = 1.0
        myLocationButton.layer.cornerRadius = 10
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupMyLocation() {
        // init myLocation
        AppVariables.setMyLocation(latitude: siteCoordinate.latitude,
                                   longitude: siteCoordinate.longitude)
    }
    
    
    // MARK: - Notification
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIScene.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIScene.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func didEnterBackground() {
        print("app: didEnterBackground")
        if let timer = checkTimer {
            timer.invalidate()
            checkTimer = nil
        }
    }
    
    @objc func willEnterForeground() {
        print("app: willEnterForeground")
        if checkTimer == nil {
            if isRefreshMapData() {
                print("Download and refresh MapData...")
                fetchData(showMessage: "刷新資料中...")
            }
            print("checkTimer is nil => StartUp Timer.")
            checkTimerStartUp()
        }
    }
    
    
    // MARK: - Timer
    
    func checkTimerStartUp() {
        weak var weakSelf = self
        checkTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            print("check time...")
            if weakSelf?.isRefreshMapData() ?? false {
                weakSelf?.fetchData(showMessage: "刷新資料中...")
            }
        }
    }
    
    func isRefreshMapData() -> Bool {
        if let lastDate = lastUpdatedDate {
            let timeInterval = Date().timeIntervalSince(lastDate)
            print("time interval : \(timeInterval)")
            if timeInterval >= updateIntervalSecond() {
                return true
            }
        } else {
            lastUpdatedDate = Date()
        }
        return false
    }
    
    func updateIntervalSecond() -> Double {
        let minute = SettingsHelper.currentUpdateIntervalMinute()
        return Double(minute * 60)
    }
    
    
    // MARK: - Fetch Data

    func fetchData(showMessage: String) {
        indicatorShow(message: showMessage)
        APIHelper.fetchData() { jsonArray in
            self.indicatorDismiss()
            self.lastUpdatedDate = Date()
            
            if let array = jsonArray {
                //print(array)
                print("\ndata count: \(array.count)")
                AppVariables.setItems(array)
                self.showMarkers()
                
                if self.opendPostDetailsStoreCd != "" {
                    self.refreshOpendPostDetailsPage()
                }
            }
            
            if self.checkTimer == nil {
                self.checkTimerStartUp()
            }
        }
    }
    
    
    // MARK: - Refresh PostDetails Page
    
    func refreshOpendPostDetailsPage() {
        if let info = searchPostInfoWith(storeCd: opendPostDetailsStoreCd) {
            NotificationCenter.default.post(name: Notification.Name("RefreshPostDetails"),
                                            object: nil, userInfo: ["postInfo": info])
        }
    }
    
    func searchPostInfoWith(storeCd: String) -> Dictionary<String,Any>? {
        if storeCd == "" {
            return nil
        }
        
        if let items = AppVariables.items() {
            for item in items {
                if let itemStoreCd = item["storeCd"] as? String, itemStoreCd == storeCd {
                    return item
                }
            }
        }
        return nil
    }
    
    
    // MARK: - Show Markers in MapView
    
    func postPinImageWith(totalString: String?) -> UIImage? {
        if let totalStr = totalString {
            let total = Int(totalStr) ?? 0
            let name = LevelsColor.postImageNameWith(total: total)
            return UIImage(named: name)
        }
        return UIImage(named: "post_pin")
    }
    
    func showMarkers() {
        if let items = AppVariables.items() {
            var tmpArray = Array<PostAnnotation>()
            
            for item in items {
                var latitude : Double = 0
                var longitude : Double = 0
                
                if let latStr = item["latitude"] as? String {
                    let lat = latStr.trimmingCharacters(in: .whitespacesAndNewlines)
                    latitude = Double(lat) ?? 0
                }
                if let lngStr = item["longitude"] as? String {
                    let lng = lngStr.trimmingCharacters(in: .whitespacesAndNewlines)
                    longitude = Double(lng) ?? 0
                }
                
                if latitude == 0 || longitude == 0 {
                    continue
                }
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let anno = PostAnnotation(coordinate: coordinate)
                
                anno.image = postPinImageWith(totalString: item["total"] as? String)
                
                anno.hsnCd      = (item["hsnCd"] as? String) ?? ""
                anno.townCd     = (item["townCd"] as? String) ?? ""
                anno.storeCd    = (item["storeCd"] as? String) ?? ""
                anno.hsnNm      = (item["hsnNm"] as? String) ?? ""
                anno.townNm     = (item["townNm"] as? String) ?? ""
                anno.storeNm    = (item["storeNm"] as? String) ?? ""
                anno.addr       = (item["addr"] as? String) ?? ""
                anno.zipCd      = (item["zipCd"] as? String) ?? ""
                anno.tel        = (item["tel"] as? String) ?? ""
                anno.busiTime   = (item["busiTime"] as? String) ?? ""
                anno.busiMemo   = (item["busiMemo"] as? String) ?? ""
                anno.total      = (item["total"] as? String) ?? ""
                anno.updateTime = (item["updateTime"] as? String) ?? ""
                
                tmpArray.append(anno)
            }
            
            // clear Annotations
            mapView.removeAnnotations(postAnnotationArray)
            postAnnotationArray.removeAll()
            
            // add Annotations
            postAnnotationArray.append(contentsOf: tmpArray)
            mapView.addAnnotations(postAnnotationArray)
        }
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print("lat：\(location.coordinate.latitude), lng：\(location.coordinate.longitude)")
    }
    
    
    // MARK: - Site Location
    
    func moveToSiteLocation() {
        let viewRegion = MKCoordinateRegion(center: siteCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000);
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
    }
    
    
    // MARK: - Show NearbyButtonItem (LeftButtonItem)
    
    func showNearbyButtonItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "附近...", style: .done, target: self, action: #selector(pressedNearbyButtonItem))
    }
    
    
    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location {
            AppVariables.setMyLocation(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude)
            
            print("緯度：\(AppVariables.myLocation().latitude), 經度：\(AppVariables.myLocation().longitude)")
            
            if isMoveToUserLocation == true {
                isMoveToUserLocation = false
                let viewRegion = MKCoordinateRegion(center: AppVariables.myLocation(),
                                                    latitudinalMeters: 1200,
                                                    longitudinalMeters: 1200)
                let adjustedRegion = mapView.regionThatFits(viewRegion)
                mapView.setRegion(adjustedRegion, animated: true)
                showNearbyButtonItem()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //...
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        if annotation.isMember(of: PostAnnotation.self) {
            var annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "postAnnotationView") as? PostAnnotationView
            
            if annoView == nil {
                annoView = PostAnnotationView(annotation: annotation, reuseIdentifier: "postAnnotationView")
            }
            
            let anno = annotation as! PostAnnotation
            
            annoView?.image = anno.image
            annoView?.coordinate = anno.coordinate
            annoView?.hsnCd      = anno.hsnCd
            annoView?.townCd     = anno.townCd
            annoView?.storeCd    = anno.storeCd
            annoView?.hsnNm      = anno.hsnNm
            annoView?.townNm     = anno.townNm
            annoView?.storeNm    = anno.storeNm
            annoView?.addr       = anno.addr
            annoView?.zipCd      = anno.zipCd
            annoView?.tel        = anno.tel
            annoView?.busiTime   = anno.busiTime
            annoView?.busiMemo   = anno.busiMemo
            annoView?.total      = anno.total
            annoView?.updateTime = anno.updateTime
            
            weak var weakSelf = self
            
            annoView?.selectedAction = { coordinate in
                weakSelf?.selectedPostAnnotation(anno, coordinate: coordinate)
            }
            
            annoView?.showMoreAction = { info, coordinate in
                weakSelf?.showMoreInfo(info, coordinate: coordinate)
            }
            
            return annoView
        }
        return nil
    }
    
    
    // MARK: - Selected Annotation
    
    func selectedPostAnnotation(_ annotation: PostAnnotation, coordinate: CLLocationCoordinate2D) {
        let moveToCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + 0.00025,
                                                      longitude: coordinate.longitude)
        
        let viewRegion = MKCoordinateRegion(center: moveToCoordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
    }
    
    func showMoreInfo(_ info: Dictionary<String,String>, coordinate: CLLocationCoordinate2D) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsViewController
        vc.postCoordinate = coordinate
        vc.info = info
        opendPostDetailsStoreCd = info["storeCd"] ?? ""
        
        weak var weakSelf = self
        vc.closeAction = {
            weakSelf?.opendPostDetailsStoreCd = ""
        }
        present(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - IBAction or Click Button Event
    
    @IBAction func pressedMyLocationButton() {
        let location = AppVariables.myLocation()
        if location.latitude != 0 && location.longitude != 0 {
            let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 1200, longitudinalMeters: 1200)
            let adjustedRegion = mapView.regionThatFits(viewRegion)
            mapView.setRegion(adjustedRegion, animated: true)
        }
    }
    
    @objc func pressedInfoButtonItem() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpViewController
        show(vc, sender: self)
    }
    
    @objc func pressedNearbyButtonItem() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NearbyPostsVC") as! NearbyPostsViewController
        show(vc, sender: self)
    }
    
    
    // MARK: - Indicator and MessageView
    
    func indicatorShow(message: String) {
        if !indicatorView.isAnimating {
            indicatorView.startAnimating()
        }
        messageViewShow(message: message)
    }
    
    func indicatorDismiss() {
        if indicatorView.isAnimating {
            indicatorView.stopAnimating()
        }
        messageViewDismiss()
    }
    
    func messageViewShow(message: String) {
        UIView.animate(withDuration: 0.15) {
            self.messageView.alpha = 0.8
            self.messageLabel.text = message
        }
    }
    
    func messageViewDismiss() {
        UIView.animate(withDuration: 0.3) {
            self.messageView.alpha = 0
            self.messageLabel.text = ""
        }
    }
    
}

