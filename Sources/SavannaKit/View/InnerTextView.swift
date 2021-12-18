//
//  InnerTextView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

protocol InnerTextViewDelegate: class {
	func didUpdateCursorFloatingState()
}


class InnerTextView: TextView, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        let r = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        r.delegate = self
        addGestureRecognizer(r)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // we need access to the view controller to display the cde issue popover
    // this is in innertextview instead of syntaxtextview because innertextview keeps track of line numbers/paragraphs
    var viewControllerProvider: ViewControllerProvider?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        return location.x < gutterWidth
    }
    
    @objc
    func handleTap(from recognizer: UITapGestureRecognizer) {
        
        // find out which line number was tapped.
        // if an issue exists, show a popul
        let location = recognizer.location(in: self)
        
        if location.x < gutterWidth {
            guard let paragraphs = cachedParagraphs else { return }
            for p in paragraphs {
                if location.y < p.rect.maxY && location.y > p.rect.minY {
                    if !p.issues.isEmpty {
                        displayIssuesPopover(for: p)
                    }
                    break
                }
            }
        }
    }
    
    var issues: [CodeIssue] = []
    
    func setCodeIssues(_ issues: [CodeIssue]) {
        self.issues = issues
        
        cachedParagraphs = generateParagraphs(for: self, flipRects: false, issues: issues)
        
        setNeedsDisplay()
    }
    
    func displayIssuesPopover(for paragraph: Paragraph) {
        
        let popoverContentController = CodeIssuesPopoverViewController(issues: paragraph.issues)
        
        popoverContentController.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self
            popoverPresentationController.sourceRect = CGRect(origin: paragraph.rect.origin, size: CGSize(width: gutterWidth, height: paragraph.rect.height))
            popoverPresentationController.delegate = self
            viewControllerProvider?.getViewController()?.present(popoverContentController, animated: true, completion: nil)
            
        }
    }
    
	weak var innerDelegate: InnerTextViewDelegate?
	
	var theme: SyntaxColorTheme?
	
	var cachedParagraphs: [Paragraph]?
	
	func invalidateCachedParagraphs() {
		cachedParagraphs = nil
	}
	
	func hideGutter() {
		gutterWidth = theme?.gutterStyle.minimumWidth ?? 0.0
	}
	
	func updateGutterWidth(for numberOfCharacters: Int) {
		
		let leftInset: CGFloat = 4.0
		let rightInset: CGFloat = 4.0
		
		let charWidth: CGFloat = 10.0
		
		gutterWidth = max(theme?.gutterStyle.minimumWidth ?? 0.0, CGFloat(numberOfCharacters) * charWidth + leftInset + rightInset)
		
	}
	
	#if os(iOS)
	
	var isCursorFloating = false
	
	override func beginFloatingCursor(at point: CGPoint) {
		super.beginFloatingCursor(at: point)
		
		isCursorFloating = true
		innerDelegate?.didUpdateCursorFloatingState()

	}
	
	override func endFloatingCursor() {
		super.endFloatingCursor()
		
		isCursorFloating = false
		innerDelegate?.didUpdateCursorFloatingState()

	}
	
	override public func draw(_ rect: CGRect) {
		
		guard let theme = theme else {
			super.draw(rect)
			hideGutter()
			return
		}
		
		let textView = self

		if theme.lineNumbersStyle == nil  {

			hideGutter()

			let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
			let path = BezierPath(rect: gutterRect)
			path.fill()
			
		} else {
			
			let components = textView.text.components(separatedBy: .newlines)
			
			let count = components.count
			
			let maxNumberOfDigits = "\(count)".count
			
			textView.updateGutterWidth(for: maxNumberOfDigits)
            
            var paragraphs: [Paragraph]
            
            if let cached = textView.cachedParagraphs {
                
                paragraphs = cached
                
            } else {
                
                paragraphs = generateParagraphs(for: textView, flipRects: false, issues: issues)
                textView.cachedParagraphs = paragraphs
                
            }
			
			theme.gutterStyle.backgroundColor.setFill()
			
			let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
			let path = BezierPath(rect: gutterRect)
			path.fill()
			
			drawLineNumbers(paragraphs, in: rect, for: self)
			
            
		}
		
        
        
		super.draw(rect)
	}
	#endif
	
	var gutterWidth: CGFloat {
		set {
			
			#if os(macOS)
				textContainerInset = NSSize(width: newValue, height: 0)
			#else
				textContainerInset = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: 0)
			#endif
			
		}
		get {
			
			#if os(macOS)
				return textContainerInset.width
			#else
				return textContainerInset.left
			#endif
			
		}
	}
//	var gutterWidth: CGFloat = 0.0 {
//		didSet {
//
//			textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: gutterWidth, height: .greatestFiniteMagnitude))]
//
//		}
//
//	}
	
	#if os(iOS)
	
	override func caretRect(for position: UITextPosition) -> CGRect {
		
		var superRect = super.caretRect(for: position)
		
		guard let theme = theme else {
			return superRect
		}
		
		let font = theme.font
		
		// "descender" is expressed as a negative value,
		// so to add its height you must subtract its value
		superRect.size.height = font.pointSize - font.descender
		
		return superRect
	}
	
    
    
	#endif
	
}
