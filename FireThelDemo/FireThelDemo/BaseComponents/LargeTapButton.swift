//
//  LargeTapButton.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/13/23.
//

import UIKit

class LargeTapButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -15, dy: -15).contains(point)
    }
}

