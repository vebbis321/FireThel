//
//  TextField.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import UIKit

protocol TextFieldDelegate: AnyObject {
    func textFieldShouldReturn(_ textField: TextField) -> Bool
    func textFieldDidBeginEditing(_ textField: TextField)
}

extension TextFieldDelegate {
    func textFieldShouldReturn(_ textField: TextField) -> Bool { return true }
    func textFieldDidBeginEditing(_ textField: TextField) {}
}

final class TextField: UIView {
    // MARK: - Components
    lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .label
        textField.keyboardType = .default
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var textFieldBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black.withAlphaComponent(0.125)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    weak var delegate: TextFieldDelegate?
    private var placeholder: String
    
    // MARK: - LifeCycle
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    private func setup() {
        textField.placeholder = placeholder
        
        addSubview(textFieldBackgroundView)
        textFieldBackgroundView.addSubview(textField)
        
        textFieldBackgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        textFieldBackgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textFieldBackgroundView.topAnchor.constraint(equalTo: textField.topAnchor, constant: -9).isActive = true
        textFieldBackgroundView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9).isActive = true
        
        textField.leftAnchor.constraint(equalTo: textFieldBackgroundView.leftAnchor, constant: 6).isActive = true
        textField.rightAnchor.constraint(equalTo: textFieldBackgroundView.rightAnchor, constant: -6).isActive = true
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: textFieldBackgroundView.heightAnchor).isActive = true
    }
}

extension TextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn(self) ?? false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self)
    }
}
