//
//  NearbyPostsViewController.swift
//  3000Map
//
//  Created by rlbot on 2020/7/19.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct NearbyPost {
        let distance : CLLocationDistance
        let coordinate : CLLocationCoordinate2D
        let info : Dictionary<String,Any>
    }
    
    @IBOutlet var tableView : UITableView!
    
    var myLocation : CLLocationCoordinate2D?
    
    let indicatorView = UIActivityIndicatorView(style: .medium)
    var nearbyItems = Array<NearbyPost>()
    
    
    // MARK: - items
     
    func items() -> Array<Dictionary<String,Any>>? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.postItems
    }
    
    
    // MARK: - viewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        searchNearbyItems()
    }
    
    
    // MARK: - Search Nearby Posts
    
    func searchNearbyItems() {
        guard let myLocation = self.myLocation else { return }
        guard let items = self.items() else { return }
        
        if myLocation.latitude == 0 || myLocation.longitude == 0 {
            return
        }
        
        indicatorView.startAnimating()
        self.title = "搜尋附近的郵局..."
        
        DispatchQueue.global().async {
            var postArray = Array<NearbyPost>()
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
                let distance = self.computeDistance(coordinate1: coordinate, coordinate2: myLocation)
                
                if distance <= 18000 {  //1000m * 18 = 18000m (18公里)
                    let post = NearbyPost(distance: distance, coordinate: coordinate, info: item)
                    postArray.append(post)
                }
            }
            
            // 排序 nearbyPostArray
            postArray.sort { $0.distance < $1.distance }
        
            DispatchQueue.main.async {
                self.nearbyItems.removeAll()
                self.nearbyItems.append(contentsOf: postArray)
                print("nearbyItems.count: \(self.nearbyItems.count)")
                
                self.title = "附近的郵局"
                self.indicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    func computeDistance(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        return location1.distance(from: location2)
    }
    
    
    // MARK: - Setup
    
    func setup() {
        setupLeftButtonItem()
        setupRightButtonItem()
        setupTableView()
    }
    
    func setupLeftButtonItem() {
        let button = UIButton(type: .system)
        button.setTitle("←", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27)
        button.addTarget(self, action: #selector(pressedBackButtonItem), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func pressedBackButtonItem() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupRightButtonItem() {
        indicatorView.color = .systemBlue
        indicatorView.stopAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
    }
    

    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let maxCount = 30
        if nearbyItems.count >= maxCount {
            return maxCount
        } else {
            return nearbyItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyItemCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = .boldSystemFont(ofSize: 18)
        cell.detailTextLabel?.font = .systemFont(ofSize: 16)
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let post = nearbyItems[indexPath.row]
        let info = post.info
        //let distance = Int(post.distance)
        
        let storeNm = (info["storeNm"] as? String) ?? ""  //分局名稱
        let addr    = (info["addr"] as? String) ?? ""     //門市地址
        let total   = (info["total"] as? String) ?? ""    //服務存量
        
        cell.textLabel?.text = storeNm
        cell.detailTextLabel?.text = "\(addr)"
        
        let totalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        totalLabel.font = .boldSystemFont(ofSize: 17)
        totalLabel.numberOfLines = 0
        totalLabel.text = "\(total)份"
        totalLabel.textColor = LevelsColor.fontColorWith(total: Int(total) ?? 0)
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.textAlignment = .right
        cell.accessoryView = totalLabel
        
        return cell
    }
    
    
    // MARK: - UITableView Delegate
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = nearbyItems[indexPath.row]
        let coordinate = post.coordinate
        
        var info = Dictionary<String,String>()
        for (key, value) in post.info {
            info[key] = (value as? String) ?? ""
        }
        showMoreInfo(info, coordinate: coordinate)
    }
    
    
    // MARK: - Show More Info
    
    func showMoreInfo(_ info: Dictionary<String,String>, coordinate: CLLocationCoordinate2D) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsViewController
        vc.postCoordinate = coordinate
        vc.userCoordinate = myLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        vc.info = info
        
//        opendPostDetailsStoreCd = info["storeCd"] ?? ""
//        weak var weakSelf = self
//        vc.closeAction = {
//            weakSelf?.opendPostDetailsStoreCd = ""
//        }
        
        present(vc, animated: true, completion: nil)
    }
    
}
