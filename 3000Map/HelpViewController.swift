//
//  HelpViewController.swift
//  3000Map
//
//  Created by rlbot on 2020/7/9.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit
import SafariServices

class HelpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    let sites    = ["行政院振興三倍券 - 官網",
                    "郵局振興三倍券存量 - 開放資料集",
                    "本 App 的程式原始碼"]
    
    let siteURLs = ["https://3000.gov.tw/",
                    "https://data.gov.tw/dataset/127751",
                    ""]
    
    
    // MARK: - viewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    // MARK: - Setup
    
    func setup() {
        // setup VC title
        self.title = "設定 & 關於"
        
        // setup BarButtonItem
        setupLeftButtonItem()
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
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "刷新頻率"
        case 1:
            return "關於"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return sites.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpItemCell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.section {
        case 0:
            let minute = SettingsHelper.currentUpdateIntervalMinute()
            cell.textLabel?.text = "每隔 \(minute) 分鐘刷新一次地圖"
        case 1:
            cell.textLabel?.text = sites[indexPath.row]
        default:
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            chooseUpdateInterval()
        case 1:
            showWebPageWith(urlString: siteURLs[indexPath.row])
        default:
            break
        }
    }
    
    
    // MARK: - Show Other ViewController
    
    func chooseUpdateInterval() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChooseUpdateIntervalVC") as! ChooseUpdateIntervalViewController
        weak var weakSelf = self
        vc.onChangeAction = {
            weakSelf?.tableView.reloadData()
        }
        show(vc, sender: self)
    }
    
    func showWebPageWith(urlString: String) {
        if let url = URL(string: urlString) {
            let sfvc = SFSafariViewController(url: url)
            present(sfvc, animated: true)
        }
    }

}
