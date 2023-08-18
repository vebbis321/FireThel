//
//  ToolbarPickerView.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/13/23.
//

import Foundation
import UIKit

protocol ToolbarDelegate: UIViewController {
    func nextPressed()
    func hidePressed()
}

extension ToolbarDelegate {
    func hidePressed() {
        view.endEditing(true)
    }
}

final class ToolbarPickerView: UIPickerView {
    
    // MARK: - Internal component
    lazy var pickerToolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: frame.width, height: 44))
        toolbar.sizeToFit()
        let flexiblespace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace , target: nil, action: nil)
        let btnNext = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextPressed))
        let btnHide = UIBarButtonItem(title: "Hide", style: .done, target: self, action: #selector(hidePressed))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.items = [flexiblespace, btnNext, btnHide]
        return toolbar
    }()
    
    weak var toolbarDelegate: ToolbarDelegate?
   
    // MARK: - Private actions
    @objc private func nextPressed() {
        toolbarDelegate?.nextPressed()
    }
    
    @objc private func hidePressed() {
        toolbarDelegate?.hidePressed()
    }
}
