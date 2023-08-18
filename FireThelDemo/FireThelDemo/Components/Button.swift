//
//  Button.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import Foundation
import UIKit

final class Button: UIButton {
    
    // MARK: - Private components
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tintColor = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Private Properties
    private var title: String
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.76
        }
    }
    
    // MARK: - LifeCycle
    init(frame: CGRect = .zero, title: String) {
        self.title = title
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    func setup() {
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.white, for: .normal)
        setTitleColor(.black, for: .highlighted)
        contentHorizontalAlignment = .center
        backgroundColor = .blue
        
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 51).isActive = true
    }
    
    
    // MARK: - Internal methods
    func startLoading() {
        setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }
    
    func stopLoading(isSuccess: Bool) {
        let str = isSuccess ? "Success!" : "Error!"
        setTitle(str, for: .normal)
        activityIndicator.stopAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.setTitle(self.title, for: .normal)
        }
    }
}

