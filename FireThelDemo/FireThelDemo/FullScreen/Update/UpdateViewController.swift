//
//  JEEE.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/14/23.
//

import UIKit
import Combine
import FireThelFirestore
import FirebaseFirestore

final class UpdateViewController: UIViewController {
    
    // MARK: - Private components
    private lazy var restaurantNameField = TextField(placeholder: "Enter your restaurant name...")
    private lazy var restaurantTypeField = TextField(placeholder: "Select you restaurant type...")
   
    private lazy var toolbarPickerView = ToolbarPickerView()
    
    private lazy var updateBtn = Button(title: "Update")
    
    private lazy var components = [
        restaurantNameField, restaurantTypeField, updateBtn
    ]
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Private properties
    private var restaurant: Restaurant
    private let viewModel = EditViewModel()
    private var stateSubscription: AnyCancellable?
    
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
        listen()
    }
    
    // MARK: - Listener
    private func listen() {
        stateSubscription = viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.updateBtn.startLoading()
                case .success:
                    self?.updateBtn.stopLoading(isSuccess: true)
                case .error(let err):
                    self?.updateBtn.stopLoading(isSuccess: false)
                    self?.alert(message: err.localizedDescription, title: "Error")
                }
            }
    }
    
    // MARK: - setup
    private func setup() {
        title = "Edit your restaurant!"
        view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        updateBtn.addTarget(self, action: #selector(updateBtnTapped), for: .touchUpInside)
        
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        
        restaurantTypeField.textField.inputView = toolbarPickerView
        restaurantTypeField.textField.inputAccessoryView = toolbarPickerView.pickerToolbar
        
        restaurantNameField.textField.text = restaurant.name
        restaurantTypeField.textField.text = restaurant.type
        
        let row = RestaurantType.allCases.firstIndex(where: { $0 == RestaurantType(rawValue: restaurant.type)})
        toolbarPickerView.selectRow(row ?? 0, inComponent: 0, animated: false)
        
        view.addSubview(vStack)
        for component in components {
            vStack.addArrangedSubview(component)
        }
        
        vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        vStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        vStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
    }
    
    // MARK: - Private actions
    @objc private func didTapView() {
        view.endEditing(true)
    }
    
    @objc private func updateBtnTapped() {
        guard let documentId = restaurant.id else { return }
        Task {
            await viewModel.updateDocument(
                name: restaurantNameField.textField.text ?? "",
                restaurantType: restaurantTypeField.textField.text ?? "",
                documentId: documentId
            )
        }
    }
}

// MARK: - TextFieldDelegate
extension UpdateViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: TextField) -> Bool {
        if textField == restaurantNameField {
            restaurantTypeField.textField.becomeFirstResponder()
        } else {
            updateBtnTapped()
        }
        return true
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension UpdateViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RestaurantType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RestaurantType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        restaurantTypeField.textField.text = RestaurantType.allCases[row].rawValue
    }
}

// MARK: - RestaurantTypeViewDelegate
extension UpdateViewController: ToolbarDelegate {
    func nextPressed() {
        restaurantTypeField.textField.resignFirstResponder()
        updateBtnTapped()
    }
}

