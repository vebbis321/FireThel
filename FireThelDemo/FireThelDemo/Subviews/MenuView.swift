//
//  MenuView.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/13/23.
//

import UIKit

final class MenuView: UIStackView {
    private lazy var restaurantLabel: UILabel = .createLabel(
        text: restaurant.name,
        color: .black,
        font: .systemFont(ofSize: 22, weight: .semibold),
        alignment: .center,
        numberOfLines: 0
    )
    
    private lazy var dishLabel: UILabel = .createLabel(
        text: "Todays special: \(menu.specialDish)",
        color: .black,
        font: .preferredFont(forTextStyle: .callout),
        alignment: .center,
        numberOfLines: 0
    )
    
    private lazy var desertLabel: UILabel = .createLabel(
        text: "Todays desert: \(menu.desert)",
        color: .black,
        font: .preferredFont(forTextStyle: .callout),
        alignment: .center,
        numberOfLines: 0
    )
    
    var restaurant: Restaurant
    var menu: RestaurantMenu
    
    init(restaurant: Restaurant, menu: RestaurantMenu) {
        self.restaurant = restaurant
        self.menu = menu
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .center
        spacing = 5
        addArrangedSubview(restaurantLabel)
        addArrangedSubview(dishLabel)
        addArrangedSubview(desertLabel)
    }
}
