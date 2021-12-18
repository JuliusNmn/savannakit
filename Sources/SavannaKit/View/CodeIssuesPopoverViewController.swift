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
        let insetFrame = self.view.safeAreaLayoutGuide.layoutFrame
        
        let textView = UITextView(frame: self.view.frame)
        textView.isEditable = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        self.view.addSubview(textView)
        
        textView.textAlignment = .left
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        textView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor).isActive = true
        
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
            
            line.addAttributes([.backgroundColor:color], range: NSRange(location: 0, length: line.length))
            
            issuesStr.append(line)
        }
        
        
        textView.attributedText = issuesStr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
