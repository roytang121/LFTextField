//
//  LFTextField.swift
//  LFTextField
//
//  Created by Roy Tang on 11/10/2015.
//  Copyright © 2015 lerryrowy. All rights reserved.
//

import Foundation
import UIKit

public protocol LFTextFieldDelegate: class {
  func textFieldValueDidChange(sender: AnyObject?)
}

public enum LFBorderStyle {
  case Rounded
  case Underline
}

func getResourcesBundle() -> NSBundle? {
  let podBundle = NSBundle(forClass: LFTextField.self)
  if let bundleURL = podBundle.URLForResource("LFTextField", withExtension: "bundle") {
    let urls = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(bundleURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
    // print bundle source
//    urls?.forEach({ (url) in
//      print(url.path!)
//    })
    return NSBundle(URL: bundleURL)
  } else {
    return nil
  }
}

@IBDesignable
public class LFTextField: UIView, PredicateInspectorDelegate {


  private var overlay: LFTextFieldOverlay! {
    didSet {
      self.inputTextField = self.overlay?.textField
    }
  }

  private var isIB: Bool = false

  private var inspector: PredicateInspector!

  static let kFieldTypeNormal = "normal"
  static let kFieldTypeEmail = "email"
//  static let kFieldTypePassword = "password"

  // MARK: public properties
  public weak var inputTextField: UITextField!

  public weak var delegate: LFTextFieldDelegate? {
    didSet {
      self.inputTextField?.delegate = delegate as? UITextFieldDelegate
    }
  }

  public var enableAutoCheck: Bool = true {
    didSet {
      self.inspector?.shouldAutoCheckTextView = enableAutoCheck
    }
  }

  var state: LFTextFieldOverlay.State = .Normal {
    didSet {

      if self.state == .OK {
        self.overlay?.state = self.showSuccessState ? .OK : .Normal;
      } else {
        self.overlay?.state = self.state
      }
    }
  }

  @IBInspectable var placeholder: String! {
    didSet {
      overlay?.textField.placeholder = self.placeholder
    }
  }

  @IBInspectable var title: String! {
    didSet {
      overlay?.titleLabel?.text = title
    }
  }

  @IBInspectable var titleIcon: String? {
    didSet {
      overlay?.titleIconAssetName = titleIcon
    }
  }

  @IBInspectable var alertColor: UIColor! {
    didSet {
      overlay?.colorAlert = alertColor
    }
  }

  @IBInspectable var fieldType: String? {
    didSet {

      if customRegex != nil {
        print("Field Type could not be set together with Custom Regex")
        return
      }

      if fieldType == nil {
        return
      }

      switch fieldType! {
      case LFTextField.kFieldTypeEmail:
        self.inspector?.pattern = PredicateInspector.kPatternEmail
        break
      default:
        break
      }
    }
  }

  @IBInspectable var customRegex: String? {
    didSet {

      if fieldType != nil {
        print("Field Type could not be set together with Custom Regex")
        return
      }

      if let regex = self.customRegex?.stringByReplacingOccurrencesOfString("\\\\", withString: "\\") {
        self.inspector?.pattern = Pattern(name: "custom", regex: regex)
      }
    }
  }

  @IBInspectable var displayTitleLabel: Bool = true {
    didSet {
      overlay?.displayTitleLabel = self.displayTitleLabel
    }
  }

  @IBInspectable var showSuccessState: Bool = true {
    didSet {

    }
  }

  public var style: LFBorderStyle = .Rounded {
    didSet {
      self.overlay.style = self.style
    }
  }

  // MARK: Popup Message Properties

  var popup: UILabel!

  var popUpFontSize: CGFloat = 11.0

  var popUpleftPadding: CGFloat = 8.0 {
    didSet {
      self.popup?.frame.origin = CGPointMake(popUpleftPadding, self.overlay.bounds.height + popUpTopPadding)
    }
  }

  var popUpTopPadding: CGFloat = 3.0

  @IBInspectable public var popupTitle: String! {
    didSet {
      self.popup?.text = self.popupTitle
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setup()

  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.setup()
  }

  func setup() {
    self.overlay = NSBundle(forClass: self.dynamicType).loadNibNamed("LFTextFieldOverlay", owner: self, options: nil)[0] as? LFTextFieldOverlay

    self.addSubview(self.overlay)

    self.overlay.textField.delegate = self
    self.overlay.textField.addTarget(self, action: Selector("textFieldValueDidChange:"), forControlEvents: .EditingChanged)

    self.inspector = PredicateInspector(textField: self.overlay.textField)
    self.inspector.delegate = self

    self.inspector.pattern = PredicateInspector.kPatternEmail
  }

  override public func resignFirstResponder() -> Bool {
    return self.inputTextField?.resignFirstResponder() ?? super.resignFirstResponder()
  }

  override public func becomeFirstResponder() -> Bool {
    return self.inputTextField?.becomeFirstResponder() ?? super.becomeFirstResponder()
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    self.overlay?.frame = CGRectMake(0, 0, bounds.width, bounds.height - popUpFontSize - popUpTopPadding)

    addPopupMessage(self.popupTitle)
  }

  // MARK: @IBDesignable
  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()

    self.isIB = true

    addPopupMessage(self.popupTitle)

//    self.layer.borderColor = UIColor(rgba: "#ddd").CGColor
//
//    self.layer.borderWidth = 0.8
//
//    self.layer.cornerRadius = 4.0
//    self.hidePopup()
  }

  private func addPopupMessage(message: String!) {
    if self.popup == nil || isIB {
      let popup = UILabel()
      popup.text = message
      popup.font = UIFont.systemFontOfSize(self.popUpFontSize)
      popup.textColor = self.overlay.colorAlert
      popup.sizeToFit()
      popup.frame.origin = CGPointMake(popUpleftPadding, self.overlay.bounds.height + popUpTopPadding)
      popup.alpha = 0.6

      self.addSubview(popup)

      self.popup = popup
    }

    if !isIB {
      self.hidePopupAnimated(false)
    }
  }

  public func showPopupWithTitle(message _message: String?) {
    if let message = _message {
      self.popup.text = message
      self.popup.sizeToFit()
    }

    if let popup = self.popup {
      popup.frame.offsetInPlace(dx: 0, dy: -popup.bounds.height)

      popup.alpha = 0.0

      UIView.animateWithDuration(0.85, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in

        popup.frame.offsetInPlace(dx: 0, dy: popup.bounds.height)
        popup.alpha = 1.0

        }, completion: nil)
    }
  }

  func hidePopupAnimated(animated: Bool = true) {
    if !animated {

        self.popup?.alpha = 0.0
    } else {
      UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in

        // dismiss animated
        self.popup?.alpha = 0.0

        }, completion: nil)
    }
  }

  public func isValid() -> Bool {
    self.inspector.inspect(self.inputTextField)
    return self.inspector.lastMatchResult ?? false
  }


  // MARK: Predicate Inspector Protocol
  func predicateInspectorMatchSuccess(inspector: PredicateInspector, pattern: Pattern) {
    self.state = .OK

    self.hidePopupAnimated(true)
  }

  func predicateInspectorMatchFail(inspector: PredicateInspector, pattern: Pattern) {
    self.state = .Alert
    self.showPopupWithTitle(message: self.popupTitle)
  }

  deinit {
    self.overlay = nil
    self.inspector = nil
    self.inputTextField = nil
  }

}

extension LFTextField: UITextFieldDelegate {

  // textfield target selector
  func textFieldValueDidChange(sender: AnyObject?) {
    self.delegate?.textFieldValueDidChange(sender)
  }
}
