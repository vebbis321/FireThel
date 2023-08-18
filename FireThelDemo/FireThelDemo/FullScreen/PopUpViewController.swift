//
//  PopUpViewController.swift
//  FireEaseDemo
//
//  Created by Vebjørn Daniloff on 8/11/23.
//

import UIKit
import FirebaseFirestore
import FireThelFirestore

final class PopUpViewController: UIViewController {
    
    // MARK: - Private components
    private lazy var popUpContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var xmarkButton: UIButton = {
        let button = LargeTapButton(frame: .zero)
        let image = UIImage(named: "custom-xmark")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapBtn), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tintColor = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Private properties
    private let db = Firestore.firestore()
    private var restaurant: Restaurant
    
    // MARK: - LifeCycle
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // just for the nice "spinner to view" animation effect
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMenu(for: restaurant)
    }
    
    // MARK: - setup
    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .black.withAlphaComponent(0.75)
        view.addSubview(popUpContainerView)
        
        popUpContainerView.addSubview(xmarkButton)
        popUpContainerView.addSubview(stackView)
        
        stackView.addArrangedSubview(spinner)
        
        popUpContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120).isActive = true
        popUpContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        popUpContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        xmarkButton.topAnchor.constraint(equalTo: popUpContainerView.topAnchor, constant: 10).isActive = true
        xmarkButton.rightAnchor.constraint(equalTo: popUpContainerView.rightAnchor, constant: -10).isActive = true
        xmarkButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        xmarkButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        stackView.topAnchor.constraint(equalTo: xmarkButton.topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: popUpContainerView.bottomAnchor, constant: -10).isActive = true
        stackView.leftAnchor.constraint(equalTo: popUpContainerView.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: popUpContainerView.rightAnchor, constant: -10).isActive = true
    }
    
    // MARK: - Private actions
    @objc private func didTapBtn() {
        dismiss(animated: true)
    }
    
    @objc func didTapBackgroundView(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if let view = self.view.hitTest(location, with: nil), let guester = view.gestureRecognizers {
            if guester.contains(sender) {
                dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Private methods
    private func getMenu(for restaurant: Restaurant) {
        Task {
            do {
                guard let documentId = restaurant.id else { return }
                let menu: RestaurantMenu = try await db.getDoc(path: .getPath(for: .menu(restaurantId: documentId)), documentId: documentId)
                showMenu(menu)
            } catch {
                print(error)
            }
        }
    }
    
    private func showMenu(_ menu: RestaurantMenu) {
        let menuView = MenuView(restaurant: restaurant, menu: menu)
        menuView.alpha = 0
        stackView.removeArrangedSubview(spinner)
        spinner.removeFromSuperview()
        stackView.addArrangedSubview(menuView)
        
        stackView.layoutIfNeeded()
    
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            menuView.alpha = 1
        }
    }
}
