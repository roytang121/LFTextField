//
//  PredicateInspectable.swift
//  LRTextField
//
//  Created by Roy Tang on 13/10/2015.
//  Copyright © 2015 lerryrowy. All rights reserved.
//

import Foundation

protocol PredicateInspectable: class {
  func patternForInspection() -> NSPredicate!
}