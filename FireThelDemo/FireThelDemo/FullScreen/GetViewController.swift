//
//  GetViewController.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import UIKit
import FireThelFirestore
import FirebaseFirestore

final class GetViewController: UIViewController, RestaurantsViewDelegate {

    // MARK: - Private Components
    private lazy var restaurantsView = RestaurantsView()
    private lazy var getButton = Button(title: "Get documents!")
    private lazy var nextButton = Button(title: "Next")
    
    // MARK: - Private properties
    private let db = Firestore.firestore()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - setup
    private func setup() {
        navigationItem.title = "Get your restaurants!"
        view.backgroundColor = .white
        restaurantsView.delegate = self
        
        getButton.addTarget(self, action: #selector(getBtnTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        
        view.addSubview(restaurantsView)
        view.addSubview(getButton)
        view.addSubview(nextButton)
        
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        getButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10).isActive = true
        getButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        getButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        restaurantsView.bottomAnchor.constraint(equalTo: getButton.topAnchor, constant: -10).isActive = true
        restaurantsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        restaurantsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        restaurantsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
    }
    
    // MARK: - Private actions
    @objc private func getBtnTapped() {
        Task {
            try await restaurantsView.restaurants = db.getDocs(path: .getPath(for: .restaurant), predicates: [.limit(to: 5)])
        }
    }
    
    @objc private func nextBtnTapped() {
        let listenerVC = ListenViewController()
        navigationController?.pushViewController(listenerVC, animated: true)
    }
}

