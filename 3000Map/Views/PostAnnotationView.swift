//
//  PostAnnotationView.swift
//  3000Map
//
//  Created by rlbot on 2020/7/4.
//  Copyright © 2020 WL. All rights reserved.
//

import Foundation
import MapKit

class PostAnnotationView: MKAnnotationView {
    var coordinate : CLLocationCoordinate2D  //座標
    var info : PostItem?
    
    var selectedAction : ((_ coordinate: CLLocationCoordinate2D) -> Void)?
    var showMoreAction : ((_ info: PostItem?, _ coordinate: CLLocationCoordinate2D) -> Void)?
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView != nil {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside = rect.contains(point)
        if !isInside {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        return isInside
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            let bgView = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 220))
            bgView.backgroundColor = UIColor.clear
            
            // imageView
            let imageView = UIImageView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: bgView.frame.size.width,
                                                      height: bgView.frame.size.height))
            imageView.image = UIImage(named: "post_info_win.png")
            imageView.contentMode = .scaleAspectFill
            bgView.addSubview(imageView)
            
            // textView
            let xOffset : CGFloat = 15
            let yOffset : CGFloat = 15
            let showMoreLabelHeight : CGFloat = 30
            let bottomHeight : CGFloat = 25
            
            let textView = UITextView(frame: CGRect(x: xOffset,
                                                    y: yOffset,
                                                    width: bgView.frame.size.width - (yOffset * 2),
                                                    height: bgView.frame.size.height - (xOffset * 2) - showMoreLabelHeight - bottomHeight))
            
            textView.isEditable = false
            textView.isSelectable = false
            textView.backgroundColor = .clear //.lightGray
            
            let totalText = "\(info?.total ?? "--") 份"
            let vouchers = "三倍券尚有: \(totalText)"
            let infoText = "\(vouchers)\n\(info?.storeNm ?? "")\n\(info?.addr ?? "")\n" as NSString
            let attrStr = NSMutableAttributedString(string: infoText as String)
            
            // infoText attribute
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 2
            
            attrStr.addAttribute(.paragraphStyle,
                                 value: style,
                                 range: NSRange(location: 0, length: infoText.length))
            attrStr.addAttribute(.font,
                                 value: UIFont.systemFont(ofSize: 15),
                                 range: NSRange(location: 0, length: infoText.length))
            
            
            // vouchers attribute
            let vouchersStyle = NSMutableParagraphStyle()
            vouchersStyle.lineSpacing = 3
            vouchersStyle.paragraphSpacing = 15
            
            attrStr.addAttribute(.paragraphStyle,
                                 value: vouchersStyle,
                                 range: infoText.range(of: vouchers))
            attrStr.addAttribute(.font,
                                 value: UIFont.boldSystemFont(ofSize: 23),
                                 range: infoText.range(of: vouchers))
            
            let totalFontColor = LevelsColor.fontColorWith(total: Int(info?.total ?? "") ?? 0)
            attrStr.addAttribute(.foregroundColor,
                                 value: totalFontColor,
                                 range: infoText.range(of: totalText))
            
            // 分局名稱 attribute
            if let storeNm = info?.storeNm {
                let storeNmStyle = NSMutableParagraphStyle()
                storeNmStyle.lineSpacing = 3
                storeNmStyle.paragraphSpacing = 10
            
                attrStr.addAttribute(.paragraphStyle,
                                     value: storeNmStyle,
                                     range: infoText.range(of: storeNm))
                attrStr.addAttribute(.font,
                                     value: UIFont.boldSystemFont(ofSize: 17),
                                     range: infoText.range(of: storeNm))
            }
            
            // 門市地址 attribute
            if let addr = info?.addr {
                attrStr.addAttribute(.foregroundColor,
                                     value: UIColor.darkGray,
                                     range: infoText.range(of: addr))
            }
            
            
            textView.attributedText = attrStr;
            bgView.addSubview(textView)
            
            let textViewTap = UITapGestureRecognizer(target: self, action: #selector(clickShowMore))
            textView.addGestureRecognizer(textViewTap)
            
            
            // showMoreLabel
            let showMoreLabel = UILabel(frame: CGRect(x: (xOffset + 6),
                                                      y: (textView.frame.size.height + yOffset),
                                                      width: (bgView.frame.size.width - ((xOffset + 6) * 2) ),
                                                      height: showMoreLabelHeight))
            showMoreLabel.text = "顯示更多資訊..."
            showMoreLabel.textColor = .systemBlue
            showMoreLabel.font = UIFont.boldSystemFont(ofSize: 17)
            showMoreLabel.isUserInteractionEnabled = true
            bgView.addSubview(showMoreLabel)
            
            let showMoreTap = UITapGestureRecognizer(target: self, action: #selector(clickShowMore))
            showMoreLabel.addGestureRecognizer(showMoreTap)
            
            bgView.center = CGPoint(x: (0.5 * self.frame.size.width), y: (-0.5 * bgView.frame.size.height))
            self.addSubview(bgView)
            
            if let action = selectedAction {
                action(coordinate)
            }
        } else {
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    @objc func clickShowMore() {
        if let action = showMoreAction {
            action(info, coordinate)
        }
    }
    
}
