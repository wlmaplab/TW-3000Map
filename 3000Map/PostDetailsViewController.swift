//
//  PostDetailsViewController.swift
//  3000Map
//
//  Created by rlbot on 2020/7/8.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit
import MapKit

class PostDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var closeButton : UIButton!
    @IBOutlet var tableView : UITableView!
    
    var isShowMap = false
    var postCoordinate = CLLocationCoordinate2D()    
    var info : Dictionary<String,Any>?
    var closeAction : (() -> Void)?
    
    private let titles    = [ "本日三倍券尚有", "分局名稱", "門市地址", "電話", "營業時間",  "營業備註",  "異動時間" ]
    private let itemKeys  = [ "total",       "storeNm", "addr",   "tel", "busiTime", "busiMemo", "updateTime" ]
    
    
    
    // MARK: - Object
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - viewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let action = closeAction {
            action()
        }
    }
    
    
    // MARK: - Setup
    
    func setup() {
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.tableView.estimatedRowHeight = 180
        self.tableView.rowHeight = UITableView.automaticDimension
        
        setupNotificationCenter()
    }
    
    
    // MARK: - Notification
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshInfo(notification:)),
                                               name: NSNotification.Name("RefreshPostDetails") ,
                                               object: nil)
    }
    
    @objc func refreshInfo(notification: NSNotification) {
        if let postInfo = notification.userInfo?["postInfo"] as? Dictionary<String,Any> {
            let postStoreCd = (postInfo["storeCd"] as? String) ?? ""
            let myStoreCd = (info?["storeCd"] as? String) ?? ""
            
            if postStoreCd != "" && postStoreCd == myStoreCd {
                self.info = postInfo
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - IBAction
    
    @IBAction func pressedCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - To AttributedString
    
    func totalStringToAttributedString(title: String, total: String) -> NSAttributedString {
        let textStr = "\(title) \(total) 份" as NSString
        let attrStr = NSMutableAttributedString(string: textStr as String)
        let totalFontColor = LevelsColor.fontColorWith(total: Int(total) ?? 0)
        
        attrStr.addAttribute(.font,
                             value: UIFont.boldSystemFont(ofSize: 24),
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.foregroundColor,
                             value: UIColor.black,
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.foregroundColor,
                             value: totalFontColor,
                             range: textStr.range(of: total))
        
        return attrStr
    }
    
    func itemStringToAttributedString(title: String, content: String) -> NSAttributedString {
        let textStr = "\(title)\(content)" as NSString
        let attrStr = NSMutableAttributedString(string: textStr as String)
        
        attrStr.addAttribute(.foregroundColor,
                             value: UIColor.black,
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.font,
                             value: UIFont.systemFont(ofSize: 17),
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.font,
                             value: UIFont.boldSystemFont(ofSize: 18),
                             range: textStr.range(of: title))
        
        return attrStr
    }
    
    func telephoneStringToAttributedString(title: String, tel: String) -> NSAttributedString {
        let textStr = "\(title)\(tel) 📞☎️" as NSString
        let attrStr = NSMutableAttributedString(string: textStr as String)
        
        attrStr.addAttribute(.foregroundColor,
                             value: UIColor.black,
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.font,
                             value: UIFont.systemFont(ofSize: 17),
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.font,
                             value: UIFont.boldSystemFont(ofSize: 18),
                             range: textStr.range(of: title))
        
        attrStr.addAttribute(.link, value: "tel://\(tel)", range: textStr.range(of: tel))
        
        return attrStr
    }
    
    func routeNavigationAttributedString() -> NSAttributedString {
        let appleMapStr = "Maps"
        let textStr = "使用 \(appleMapStr) 進行導航 🚴" as NSString
        let attrStr = NSMutableAttributedString(string: textStr as String)
        
        attrStr.addAttribute(.font,
                             value: UIFont.boldSystemFont(ofSize: 19),
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.foregroundColor,
                             value: UIColor(red: 1/255.0, green: 129/255.0, blue: 74/255.0, alpha: 1),
                             range: NSRange(location: 0, length: textStr.length))
        
        attrStr.addAttribute(.foregroundColor,
                             value: UIColor.darkGray,
                             range: textStr.range(of: appleMapStr))
        
        return attrStr
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isShowMap ? 1 : 0
        case 1:
            return titles.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //============= Map Cell =============//
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
            let storeNm = (info?["storeNm"] as? String) ?? "郵局"
            cell.moveToLocation(coordinate: postCoordinate, title: storeNm)
            cell.selectionStyle = .none
            return cell
        }
        
        
        //============= 一般的 Cell =============//
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = .left
    
        if indexPath.section == 1 {
            /*
            *  [0]  total       三倍券存量
            *  [1]  storeNm     分局名稱
            *  [2]  addr        門市地址
            *  [3]  tel         電話
            *  [4]  busiTime    營業時間
            *  [5]  busiMemo    營業備註
            *  [6]  updateTime  異動時間
            */
            
            let title   = titles[indexPath.row]
            let key     = itemKeys[indexPath.row]
            let content = (info?[key] as? String) ?? ""
            
            switch indexPath.row {
            case 0:
                //三倍券存量
                cell.textLabel?.attributedText = totalStringToAttributedString(title: title, total: content)
            case 1, 2, 6:
                //分局名稱、門市地址、異動時間
                cell.textLabel?.attributedText = itemStringToAttributedString(title: "\(title)：", content: content)
            case 3:
                //電話
                cell.textLabel?.attributedText = telephoneStringToAttributedString(title: "\(title)：", tel: content)
            case 4, 5:
                //營業時間、營業備註
                let contentText = content.replacingOccurrences(of: "<br>", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                cell.textLabel?.attributedText = itemStringToAttributedString(title: "\(title)：", content: contentText)
            default:
                cell.textLabel?.attributedText = nil
                cell.textLabel?.text = ""
            }
        } else if indexPath.section == 2 {
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.attributedText = routeNavigationAttributedString()
        } else {
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 3 {
                openPhone()
            }
        case 2:
            openAppleMaps()
        default:
            break
        }
    }
    
    func openPhone() {
        guard let tel = info?["tel"] else { return }
        let storeNm = (info?["storeNm"] as? String) ?? "郵局"
        
        let controller = UIAlertController(title: "要撥打電話到：\(storeNm) 嗎？", message: "電話號碼：\(tel)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "撥號", style: .destructive) { _ in
            if let url = URL(string: "tel://\(tel)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func openAppleMaps() {
        let userCoordinate = AppVariables.myLocation()
        if userCoordinate.latitude == 0 || userCoordinate.longitude == 0 {
            msgBox(title: "Error 訊息：", message: "無法確認當前位置，所以無法進行導航！")
            return
        }
        
        let userPlacemark = MKPlacemark(coordinate: userCoordinate)
        let postPlacemark = MKPlacemark(coordinate: postCoordinate)
        
        let userMapItem = MKMapItem(placemark: userPlacemark)
        let postMapItem = MKMapItem(placemark: postPlacemark)
        
        userMapItem.name = "現在位置"
        postMapItem.name = (info?["storeNm"] as? String) ?? "郵局"
        
        MKMapItem.openMaps(with: [userMapItem, postMapItem],
                           launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    
    // MARK: - Tools
    
    func msgBox(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
}
