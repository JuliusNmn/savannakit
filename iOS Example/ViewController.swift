//
//  ViewController.swift
//  iOS Example
//
//  Created by Louis D'hauwe on 25/05/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import SavannaKit

class ViewController: UIViewController {

	@IBOutlet weak var syntaxTextView: SyntaxTextView!
	
	let lexer = MyLexer()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		syntaxTextView.delegate = self
		syntaxTextView.theme = MyTheme()
		
		syntaxTextView.text = """
							This is an example of SavannaKit.
							This example highlights words that are longer than 6 characters in red.
							"""
        
        let issue1 = CodeIssue(message: "Error description", line: 1, charStart: 4, charEnd: 8, type: .Error)
        let issue2 = CodeIssue(message: "Warning description with very long text. it needs to be long enough to cause a wrap in any case. lets goooo", line: 2, charStart: 4, charEnd: 8, type: .Warning)
                                                                      
        syntaxTextView.setCodeIssues([issue1 , issue2])
	}
}

extension ViewController: SyntaxTextViewDelegate {
	
    func didEditText(syntaxTextView: SyntaxTextView, range: NSRange, text: String) {
        print("insert \(range) \"\(text)\"")
    }
	
	func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
		
		
	}
	
	func lexerForSource(_ source: String) -> Lexer {
		return lexer
	}
    
    func getViewController() -> UIViewController? {
        return self
    }
	
}

class MyLexer: Lexer {
	
	init() {

	}
	
	func getSavannaTokens(input: String) -> [Token] {
	
		var tokens = [MyToken]()
		
		input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { (word, range, _, _) in
			
			if let word = word {
				
				let type: MyTokenType
				
				if word.count > 6 {
					type = .longWord
				} else {
					type = .shortWord
				}
				
				let token = MyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
				
				tokens.append(token)
				
			}
			
		}
		
		return tokens
	}
	
}

enum MyTokenType {
	case longWord
	case shortWord
}

struct MyToken: Token {
    
    var placeHolderBracketSize: Int = 3
    
	
	let type: MyTokenType
	
	let isEditorPlaceholder: Bool
	
	let isPlain: Bool
	
	let range: Range<String.Index>
	
}

class MyTheme: SyntaxColorTheme {
	
	private static var lineNumbersColor: Color {
		return Color(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
	}
	
	let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Font(name: "Menlo", size: 16)!, textColor: lineNumbersColor)
	let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0), minimumWidth: 32)

	let font = Font(name: "Menlo", size: 15)!
	
	let backgroundColor = Color(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
	
	func globalAttributes() -> [NSAttributedStringKey: Any] {
		
		var attributes = [NSAttributedStringKey: Any]()

		attributes[.font] = Font(name: "Menlo", size: 15)!
		attributes[.foregroundColor] = UIColor.white

		return attributes
	}
	
	func attributes(for token: Token) -> [NSAttributedStringKey: Any] {
		
		guard let myToken = token as? MyToken else {
			return [:]
		}
		
		var attributes = [NSAttributedStringKey: Any]()
		
		switch myToken.type {
		case .longWord:
			attributes[.foregroundColor] = UIColor.red
			
		case .shortWord:
			attributes[.foregroundColor] = UIColor.white

		}
		
		return attributes
	}
	
}
