//
//  ChooseUpdateIntervalViewController.swift
//  3000Map
//
//  Created by rlbot on 2020/7/12.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit

class ChooseUpdateIntervalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    let minuteList = SettingsHelper.minuteList
    var onChangeAction : (() -> Void)?
    
    
    // MARK: - viewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        // setup VC title
        self.title = "選擇刷新頻率"
        
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
    
    
    // MARK: - Get Current Row
    
    func currentRow() -> Int {
        let currentMinute = SettingsHelper.currentUpdateIntervalMinute()
        var row = 0
        for minute in minuteList {
            if minute == currentMinute {
                return row
            }
            row += 1
        }
        _ = SettingsHelper.saveUpdateIntervalMinute(minuteList.first!)
        return 0
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return minuteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "minuteItemCell", for: indexPath)
        cell.selectionStyle = .none
        
        let minute = minuteList[indexPath.row]
        cell.textLabel?.text = "\(minute) 分鐘"
        
        if indexPath.row == currentRow() {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let minute = minuteList[indexPath.row]
        if SettingsHelper.saveUpdateIntervalMinute(minute) {
            tableView.reloadData()
            if let action = onChangeAction {
                action()
            }
        } else {
            msgBox(title: "Error:", message: "儲存設定時發生問題！")
        }
    }
    
    
    // MARK: - Tools
    
    func msgBox(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
}
