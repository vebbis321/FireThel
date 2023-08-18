//
//  CreateViewController.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import UIKit
import Combine

class CreateViewController: UIViewController {

    // MARK: - Private components
    private lazy var restaurantNameField = TextField(placeholder: "Enter your restaurant name...")
    private lazy var restaurantTypeField = TextField(placeholder: "Select you restaurant type...")
   
    private lazy var toolbarPickerView = ToolbarPickerView()
    
    private lazy var menuSpecialDishField = TextField(placeholder: "Enter the name of your special dish...")
    private lazy var menuDesertField = TextField(placeholder: "Enter the name of your desert...")
    
    private lazy var createButton = Button(title: "Create documents!")
    private lazy var nexteButton = Button(title: "Next")
    
    private lazy var components = [
        restaurantNameField, restaurantTypeField, menuSpecialDishField, menuDesertField, createButton, nexteButton
    ]
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Private properties
    private let viewModel = CreateViewModel()
    private var stateSubscription: AnyCancellable?

    // MARK: - LifeCycle
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
                    self?.createButton.startLoading()
                case .success:
                    self?.createButton.stopLoading(isSuccess: true)
                    self?.clear()
                case .error(let err):
                    self?.createButton.stopLoading(isSuccess: false)
                    self?.alert(message: err.localizedDescription, title: "Error")
                }
            }
    }
    
    // MARK: - Private actions / methods
    @objc private func didTapView() {
        view.endEditing(true)
    }
    
    @objc private func createBtnTapped() {
        Task {
            await viewModel.createDocuments(
                name: restaurantNameField.textField.text ?? "",
                restaurantType: restaurantTypeField.textField.text ?? "",
                specialDish: menuSpecialDishField.textField.text ?? "",
                desert: menuDesertField.textField.text ?? ""
            )
        }
    }
    
    @objc private func nextBtnTapped() {
        let getVC = GetViewController()
        navigationController?.pushViewController(getVC, animated: true)
    }
    
    private func clear() {
        restaurantNameField.textField.text = nil
        restaurantTypeField.textField.text = nil
        menuSpecialDishField.textField.text = nil
        menuDesertField.textField.text = nil
    }

    // MARK: - setup
    private func setup() {
        view.backgroundColor = .white
        navigationItem.title = "Create your restaurant!"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tap)
        
        restaurantNameField.delegate = self
        restaurantTypeField.delegate = self
        
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        
        menuSpecialDishField.delegate = self
        menuDesertField.delegate = self
        
        restaurantTypeField.textField.inputView = toolbarPickerView
        restaurantTypeField.textField.inputAccessoryView = toolbarPickerView.pickerToolbar
        
        createButton.addTarget(self, action: #selector(createBtnTapped), for: .touchUpInside)
        nexteButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        
        view.addSubview(vStack)
        
        for component in components {
            vStack.addArrangedSubview(component)
        }
        
        vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        vStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        vStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
    }
}

// MARK: - TextFieldDelegate
extension CreateViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: TextField) -> Bool {
        if textField == restaurantNameField {
            restaurantTypeField.textField.becomeFirstResponder()
        } else if textField == menuSpecialDishField {
            menuDesertField.textField.becomeFirstResponder()
        } else {
            createBtnTapped()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: TextField) {
        if textField == restaurantTypeField && textField.textField.text?.isEmpty ?? true {
            restaurantTypeField.textField.text = RestaurantType.allCases.first?.rawValue
        }
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension CreateViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
extension CreateViewController: ToolbarDelegate {
    func nextPressed() {
        restaurantTypeField.textField.resignFirstResponder()
        menuSpecialDishField.textField.becomeFirstResponder()
    }
}



