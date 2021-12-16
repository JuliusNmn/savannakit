//
//  CodeIssuesPopoverViewController.swift
//  SavannaKit
//
//  Created by Julius Naeumann on 16.12.21.
//  Copyright © 2021 Silver Fox. All rights reserved.
//

import UIKit

class CodeIssuesPopoverViewController : UIViewController {
    let issues: [CodeIssue]
    
    init(issues: [CodeIssue]) {
        self.issues = issues
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        let insetFrame = self.view.frame.insetBy(dx: 10, dy: 20)
        let textView = UITextView(frame: CGRect(origin: CGPoint(x: 10, y: 10), size: insetFrame.size))
        textView.textAlignment = .left
        
        self.view.addSubview(textView)
        var issuesStr = NSMutableAttributedString()
        for i in issues {
            let line = NSMutableAttributedString(string: i.message + "\n")
            var color: UIColor = UIColor()
            switch i.type {
                case .Error:
                    color = UIColor(displayP3Red: 1.0, green: 0.2, blue: 0.2, alpha: 0.4)
                    break;
                case .Warning:
                    color = UIColor(displayP3Red: 1.0, green: 1.0, blue: 0.2, alpha: 0.4)
                    break
            }
            
            line.addAttributes([.backgroundColor:color, .foregroundColor:UIColor.white], range: NSRange(location: 0, length: line.length))
            
            issuesStr.append(line)
        }
        
        
        textView.attributedText = issuesStr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
