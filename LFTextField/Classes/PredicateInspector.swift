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

  enum InspectResult {
    case NoPattern
    case Error
    case SameAsPrevious
    case Pass
  }

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
  }

  func inspect(sender: UITextField) {

    switch coreInspect(sender) {
    case .NoPattern, .SameAsPrevious:
      return
    case .Pass:
      self.delegate?.predicateInspectorMatchSuccess(self, pattern: pattern!)
    case .Error:
      self.delegate?.predicateInspectorMatchFail(self, pattern: pattern!)
    }

  }

  func validate(textField: UITextField) -> Bool {

    switch coreInspect(textField) {
    case .NoPattern:
      return false
    case .SameAsPrevious, .Pass:
      return true
    case .Error:
      return false
    }

  }

  private func coreInspect(textField: UITextField) -> InspectResult {
    if self.pattern == nil {
      return InspectResult.NoPattern
    }

    if let text = textField.text, rx = self.rx {

      let match = rx.isMatch(text)

      if !match {
        return InspectResult.Error
      }

      if match == lastMatchResult {
        return InspectResult.SameAsPrevious
      }
      lastMatchResult = match
      return InspectResult.Pass
    }
    return InspectResult.Error
  }
}
