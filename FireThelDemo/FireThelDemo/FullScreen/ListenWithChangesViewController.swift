//
//  ListenWithChangesViewController.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/13/23.
//

import UIKit
import Combine
import FireThelFirestore
import FirebaseFirestore

final class ListenWithChangesViewController: UIViewController, RestaurantsViewDelegate {
    
    // MARK: - Components
    private lazy var restaurantsView = RestaurantsView()
    private lazy var backToRootBtn = Button(title: "Go back to root")
    
    // MARK: - Private properties
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
        backToRootBtn.addTarget(self, action: #selector(backToRootBtnTapped), for: .touchUpInside)
        
        view.addSubview(restaurantsView)
        view.addSubview(backToRootBtn)
        
        backToRootBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
        backToRootBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        backToRootBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        restaurantsView.bottomAnchor.constraint(equalTo: backToRootBtn.topAnchor, constant: -10).isActive = true
        restaurantsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        restaurantsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        restaurantsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
    }
    
    // MARK: - listen
    private func listen() {
        listenerSubscription = db.observeCollectionAndChanges(path: .getPath(for: .restaurant))
            .receive(on: DispatchQueue.main)
            .sink { completiom in
                switch completiom {
                case .finished:
                    print("Finished")
                case .failure(let err):
                    print("Listener err: \(err)")
                }
            } receiveValue: { [weak self] output in
                // Output need to match listener output.
                // With a function it very clear what the generic type will be, and the compiler will then compile
                self?.handleOutput(output)
            }
    }
    
    // MARK: - Private method
    private func handleOutput(_ listenerOutputs: [ListenerOuput<Restaurant>]) {
        for output in listenerOutputs {
            switch output.changeType {
            case .added:
                print("New doc added")
                restaurantsView.restaurants.append(output.data)
            case .modified:
                print("Doc changed")
                if let idx = restaurantsView.restaurants.firstIndex(where: { $0.id == output.data.id }) {
                    restaurantsView.restaurants[idx] = output.data
                }
            case .removed:
                print("Doc removed")
                if let idx = restaurantsView.restaurants.firstIndex(where: { $0.id == output.data.id }) {
                    restaurantsView.restaurants.remove(at: idx)
                }
            }
        }
    }
    
    // MARK: - Private action
    @objc private func backToRootBtnTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

