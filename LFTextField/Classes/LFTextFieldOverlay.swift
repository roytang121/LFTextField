//
//  LFTextField.swift
//  LFTextField
//
//  Created by Roy Tang on 11/10/2015.
//  Copyright © 2015 lerryrowy. All rights reserved.
//

import Foundation
import UIKit

class LFTextFieldOverlay: UIView {

  var style: LFBorderStyle = .Rounded {
    didSet {
      self.setStyle(self.style)
    }
  }

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var titleIcon: UIImageView!

  /** - Remark: if set it should be referenced to mainBundle */
  var titleIconAssetName: String? {
    didSet {
      print("trigger")
      // Title icon
      if let _titleIconAssetName = self.titleIconAssetName {
        self.titleIcon.image = UIImage(named: _titleIconAssetName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
      } else {
        self.titleIcon.image = UIImage(named: "warning", inBundle: getResourcesBundle(), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
      }
    }
  }

  @IBOutlet weak var textField: UITextField!

  @IBOutlet weak var stateIcon: UIImageView!

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
  
  var displayBorder: Bool = true {
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

//    self.titleIcon.tintColor = UIColor.redColor()
    // set kern values for placeholder

  }

  override func layoutSubviews() {
    super.layoutSubviews()

//    if (titleLabel == nil || textField == nil || stateIcon == nil) {
//      return
//    }

    setStyle(self.style)

    // configure if title Label is need

    if !displayTitleLabel {
      self.titleLabelLeadingConstraint?.constant = -titleLabel.bounds.width
    }
    self.borderLayer?.hidden = !displayBorder
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

      if self.style == .Underline {
        let borderAnim = self.animationStrokeColor(color)
        self.borderLayer?.addAnimation(borderAnim, forKey: NSUUID().UUIDString)
      } else {
        let borderAnim = self.animationBorderColor(color)
        self.layer.addAnimation(borderAnim, forKey: NSUUID().UUIDString)
      }

      // let anim = self.animationBackgroundColor(color)

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

  func animationStrokeColor(color: UIColor) -> CABasicAnimation {
    let anim = CABasicAnimation(keyPath: "strokeColor")
    anim.toValue = color.CGColor
    anim.duration = self.animationDuration
    anim.fillMode = kCAFillModeForwards
    anim.removedOnCompletion = false
    return anim
  }

  public func setStyle(style: LFBorderStyle) {
    switch style {
    case .Rounded:
      self.roundedBorder()
      break
    case .Underline:
      self.underlineBorder()
      break
    }

    setNeedsLayout()
  }

  func roundedBorder() {
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
      let imageFrame = titleIcon.frame
      
      let borderFrame = CGRectMake(imageFrame.maxX + 4, 0, borderWidth, self.frame.height)
      let borderLayer = CAShapeLayer()
      borderLayer.frame = borderFrame
      borderLayer.backgroundColor = colorLightGray.CGColor
      self.layer.addSublayer(borderLayer)

      self.borderLayer = borderLayer
    }
  }

  func underlineBorder() {
    layer.borderWidth = 0
//    layer.borderColor = UIColor.clearColor().CGColor

    if self.borderLayer != nil {
      self.borderLayer.removeFromSuperlayer()
      self.borderLayer = nil
    }

    if self.borderLayer == nil {
      let layerFrame = self.layer.bounds
      let borderLayer = CAShapeLayer()
      borderLayer.frame = layerFrame

      // make a bucket shape line
      let line = UIBezierPath()

      let bottom = borderLayer.bounds.height - 6
      let top = bottom - 6

      line.moveToPoint(CGPoint(x: 0, y: top))
      line.addLineToPoint(CGPoint(x: 0, y: bottom))
      line.addLineToPoint(CGPoint(x: borderLayer.bounds.width, y: bottom))
      line.moveToPoint(CGPoint(x: borderLayer.bounds.width, y: top))
      line.addLineToPoint(CGPoint(x: borderLayer.bounds.width, y: bottom))
      borderLayer.path = line.CGPath
      borderLayer.fillColor = nil
      borderLayer.opacity = 1
      borderLayer.lineWidth = 1.0
      borderLayer.lineCap = kCALineCapRound
      borderLayer.strokeColor = UIColor.lightGrayColor().CGColor
      self.layer.addSublayer(borderLayer)

      self.borderLayer = borderLayer
    }
  }

  // MARK: IBDesignable
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()


  }
}
