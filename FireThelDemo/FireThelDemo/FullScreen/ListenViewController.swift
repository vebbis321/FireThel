//
//  ListenViewController.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import UIKit
import Combine
import FireThelFirestore
import FirebaseFirestore

final class ListenViewController: UIViewController, RestaurantsViewDelegate {
    
    // MARK: - Private components
    private lazy var restaurantsView = RestaurantsView()
    private lazy var nextButton = Button(title: "Next")
    
    // MARK: - Privtae properties
    private let db = Firestore.firestore()
    private var listenerSubscription: AnyCancellable?
   
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        listen()
    }
    
    // MARK: - setup
    private func setup() {
        navigationItem.title = "Listen to realtime restaurant updates!"
        view.backgroundColor = .white
        restaurantsView.delegate = self
        nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        
        view.addSubview(restaurantsView)
        view.addSubview(nextButton)
        
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        restaurantsView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10).isActive = true
        restaurantsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        restaurantsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        restaurantsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
    }
    
    // MARK: - listen
    private func listen() {
        listenerSubscription = db.observeCollection(path: .getPath(for: .restaurant))
            .receive(on: DispatchQueue.main)
            .sink { completiom in
                switch completiom {
                case .finished:
                    print("Finished")
                case .failure(let err):
                    print("Listener err: \(err)")
                }
            } receiveValue: { [weak self] output in
                self?.restaurantsView.restaurants = output
            }
    }
    
    // MARK: - Private action
    @objc private func nextBtnTapped() {
        let vc = ListenWithChangesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

