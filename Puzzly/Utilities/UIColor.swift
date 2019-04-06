//
//  UIColor.swift
//  Gridy
//
//  Created by Spencer Forrest on 19/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

extension UIColor {
  static let main = UIColor.createFromRGB(212, 152, 136)
  static let secondary = UIColor.createFromRGB(214, 207, 189)
  
  static let olsoGray = UIColor.createFromRGB(149, 152, 154)
  static let transparent = UIColor.white.withAlphaComponent(0.85)
  
  
  /// Facilitate the use of RGB
  ///
  /// - Parameters:
  ///   - red: a value from 0 to 255
  ///   - green: a value from 0 to 255
  ///   - blue: a value from 0 to 255
  ///   - alpha: a value from 0 to 1
  /// - Returns: A color
  static func createFromRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
    return UIColor.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
  }
}
