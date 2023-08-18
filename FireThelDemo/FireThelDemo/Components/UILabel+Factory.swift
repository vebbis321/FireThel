//
//  UILabel+Factory.swift
//  FireEaseDemo
//
//  Created by Vebjørn Daniloff on 8/12/23.
//

import UIKit

extension UILabel {
    static func createLabel(
           text: String,
           color: UIColor = .label,
           font: UIFont,
           alignment: NSTextAlignment,
           numberOfLines: Int = 0
       ) -> UILabel {
           let label = UILabel(frame: .zero)
           label.text = text
           label.textColor = color
           label.font = font
           label.textAlignment = alignment
           label.numberOfLines = numberOfLines
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }
}
