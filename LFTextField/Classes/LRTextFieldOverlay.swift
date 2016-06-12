//
//  LRTextField.swift
//  LRTextField
//
//  Created by Roy Tang on 11/10/2015.
//  Copyright © 2015 lerryrowy. All rights reserved.
//

import Foundation
import UIKit

class LRTextFieldOverlay: UIView {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var titleIcon: UIImageView!
  
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var stateIcon: UIImageView!
  
  @IBOutlet weak var titleLabelWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint!
  
  let colorLightGray = UIColor(rgba: "#ddd")
  
  let colorGray = UIColor(rgba: "#444")
  
  var colorAlert = UIColor(rgba: "#fe6251")
  
  var colorOK = UIColor(rgba: "#40d47e")
  
  let borderWidth: CGFloat = 0.8
  
  let animationDuration = 0.2
  
  var borderLayer: CALayer!
  
  var cornerRadius: CGFloat! = 4.0 {
    didSet {
//      self.layer.cornerRadius = self.cornerRadius
      self.layoutSubviews()
    }
  }
  
  var displayTitleLabel: Bool = true {
    didSet {
      self.layoutIfNeeded()
    }
  }
  
  var title: String! {
    didSet {
      titleLabel?.text = title
    }
  }
  
  enum State {
    case Alert
    case OK
    case Normal
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    

    self.state = .Normal
    self.stateIcon.hidden = true
    
    self.titleLabel.textColor = self.colorGray
    self.titleLabel.clipsToBounds = true
    self.titleLabel.layer.masksToBounds = true
    
    // Title icon
    self.titleIcon.image = UIImage(named: "warning")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    self.titleIcon.tintColor = UIColor.redColor()
    // set kern values for placeholder
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
//    if (titleLabel == nil || textField == nil || stateIcon == nil) {
//      return
//    }
    
    // create border and rounded corner
    layer.cornerRadius = cornerRadius
    layer.borderWidth = borderWidth
    layer.borderColor = colorLightGray.CGColor
    
    
    // add Right Border to textField
    if self.borderLayer != nil {
      self.borderLayer.removeFromSuperlayer()
      self.borderLayer = nil
    }
    
    if self.borderLayer == nil {
      let textFieldFrame = titleLabel.layer.frame
      let borderFrame = CGRectMake(textFieldFrame.width, 0, borderWidth, self.frame.height)
      let borderLayer = CAShapeLayer()
      borderLayer.frame = borderFrame
      borderLayer.backgroundColor = colorLightGray.CGColor
      self.layer.addSublayer(borderLayer)
      
      self.borderLayer = borderLayer
    }
    
    // configure if title Label is need
    
    if !displayTitleLabel {
      self.titleLabelLeadingConstraint.constant = -titleLabel.bounds.width
      self.borderLayer?.hidden = true
    } else {
      self.borderLayer?.hidden = false
    }
  }
  
  var state: State = .Normal {
    didSet(oldState) {
      
      if oldState == self.state {
        return
      }
      
      var color = colorLightGray
      var icon: UIImage!
      
      switch (state) {
      case .Alert:
        color = colorAlert
        self.stateIcon.hidden = false
//        icon = UIImage(named: "warning")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        icon = UIImage(named: "warning", inBundle: getResourcesBundle(), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
        break
      case .Normal:
        color = colorLightGray
        self.stateIcon.hidden = true
        break
      case .OK:
        color = colorOK
        self.stateIcon.hidden = true
        break
      }
      
//      UIView.animateWithDuration(1) { () -> Void in
//        self.borderLayer?.backgroundColor = color.CGColor
//        self.layer.borderColor = color.CGColor
//        self.titleLabel.textColor = color
//        
//        if !self.stateIcon.hidden {
//          self.stateIcon.image = icon
//          self.stateIcon.tintColor = color
//        }
//      }
      UIView.transitionWithView(self.titleLabel, duration: animationDuration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
        self.titleLabel.textColor = self.state == .Normal ? self.colorGray : color
        self.stateIcon.image = icon
        self.stateIcon.tintColor = color
//        self.titleLabel.backgroundColor = self.state == .Normal ? UIColor.whiteColor() : color
        }, completion: nil)
      
      let anim = self.animationBackgroundColor(color)
      let borderAnim = self.animationBorderColor(color)
      
      self.borderLayer?.addAnimation(anim, forKey: NSUUID().UUIDString)
      self.layer.addAnimation(borderAnim, forKey: NSUUID().UUIDString)
    }
  }
  
  func animationBackgroundColor(color: UIColor) -> CABasicAnimation {
    let anim = CABasicAnimation(keyPath: "backgroundColor")
    anim.toValue = color.CGColor
    anim.duration = self.animationDuration
    anim.fillMode = kCAFillModeForwards
    anim.removedOnCompletion = false
    return anim
  }
  
  func animationBorderColor(color: UIColor) -> CABasicAnimation {
    let anim = CABasicAnimation(keyPath: "borderColor")
    anim.toValue = color.CGColor
    anim.duration = self.animationDuration
    anim.fillMode = kCAFillModeForwards
    anim.removedOnCompletion = false
    return anim
  }
  
  // MARK: IBDesignable
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    
  }
}