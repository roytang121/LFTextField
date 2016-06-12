//
//  PredicateInspector.swift
//  LRTextField
//
//  Created by Roy Tang on 13/10/2015.
//  Copyright © 2015 lerryrowy. All rights reserved.
//

import Foundation
import UIKit

struct Pattern {
  var name: String!
  var regex: String!
  
  init(name: String, regex: String) {
    self.name = name
    self.regex = regex
  }
}

protocol PredicateInspectorDelegate: class {
  func predicateInspectorMatchSuccess(inspector: PredicateInspector, pattern: Pattern)
  
  func predicateInspectorMatchFail(inspector: PredicateInspector, pattern: Pattern)
}

class PredicateInspector: NSObject, UITextFieldDelegate {
  
  static let kPatternEmail = Pattern(name: "email", regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
  
  var pattern: Pattern? {
    didSet {
      
      if pattern == nil {
        return
      }
      
      self.rx = NSRegularExpression.rx(pattern!.regex)
      
      if self.rx == nil {
        print("Invalid Regular Expression: \(pattern!.regex)")
      }
    }
  }
  
  var rx: NSRegularExpression?
  
  weak var delegate: PredicateInspectorDelegate?
  
  var lastMatchResult: Bool?
  
  override init() {

  }
  
  init(textField: UITextField?) {
    super.init()
    
    textField?.addTarget(self, action: Selector("textFieldValueDidChanged:"), forControlEvents: UIControlEvents.EditingChanged)
  }
  
  func textFieldValueDidChanged(sender: UITextField) {
    
    if self.pattern == nil {
      return
    }
    
    if let text = sender.text, rx = self.rx {
      
      let match = rx.isMatch(text)
      
      if match == lastMatchResult {
        return
      }
      
      if !match {
        self.delegate?.predicateInspectorMatchFail(self, pattern: pattern!)
      } else {
        self.delegate?.predicateInspectorMatchSuccess(self, pattern: pattern!)
      }
      
      lastMatchResult = match
    }
  }
}