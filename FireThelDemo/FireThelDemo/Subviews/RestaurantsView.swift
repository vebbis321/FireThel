//
//  ListView.swift
//  FireEaseDemo
//
//  Created by Vebjørn Daniloff on 8/11/23.
//

import UIKit
import FireThelFirestore
import FirebaseFirestore

protocol RestaurantsViewDelegate: UIViewController {
    func didSelectRestaurant(_ restaurant: Restaurant)
    func didSelectEditRestaurant(_ restaurant: Restaurant, completion: @escaping ()->())
}

extension RestaurantsViewDelegate {
    func didSelectRestaurant(_ restaurant: Restaurant) {
        let vc = PopUpViewController(restaurant: restaurant)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func didSelectEditRestaurant(_ restaurant: Restaurant, completion: @escaping ()->()) {
        let vc = UINavigationController(rootViewController: UpdateViewController(restaurant: restaurant))
        present(vc, animated: true, completion: completion)
    }
}

final class RestaurantsView: UIView {
    
    weak var delegate: RestaurantsViewDelegate?
    
    // MARK: - Private Components
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var listConfiguration: UICollectionLayoutListConfiguration = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            // get the model for the given index
            guard let self = self, let model = self.dataSource.itemIdentifier(for: indexPath) else { fatalError() }
            
            let editHandler: UIContextualAction.Handler = { [weak self] action, view, completion in
                self?.delegate?.didSelectEditRestaurant(model, completion: {
                    
                })
                completion(true)
            }
            let editAction = UIContextualAction(style: .normal, title: nil, handler: editHandler)
            editAction.image = .init(systemName: "ellipsis.circle.fill")
            editAction.backgroundColor = .blue
            
            let deleteHandler: UIContextualAction.Handler = { [weak self] action, view, completion in
                self?.delete(restaurant: model)
                completion(true)
            }
            let deleteAction = UIContextualAction(style: .normal, title: nil, handler: deleteHandler)
            deleteAction.image = .init(systemName: "trash.fill")
            deleteAction.backgroundColor = .red
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }
        return configuration
    }()
    
    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Restaurant>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Restaurant>
    
    // MARK: - Private properties
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    private let db = Firestore.firestore()
    
    // MARK: - Internal properties
    var restaurants = [Restaurant]() {
        didSet {
            updateSnapshot()
        }
    }
    
    // MARK: - LifeCycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        createDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    private func setup() {
        addSubview(collectionView)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Private methods
    private func delete(restaurant: Restaurant) {
        var snapshot = Snapshot()
        snapshot.deleteItems([restaurant])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        Task {
            guard let documentId = restaurant.id else { return }
            async let restaurant: () = db.deleteDoc(path: .getPath(for: .restaurant), documentId: documentId)
            async let menu: () = db.deleteDoc(path: .getPath(for: .menu(restaurantId: documentId)), documentId: documentId)
            _ = try await (menu, restaurant)
        }
    }
    
    // MARK: - CollectionView layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout() { [weak self] sectionIndex, layoutEnv in
            guard let self = self else { fatalError() }
            return NSCollectionLayoutSection.list(using: self.listConfiguration, layoutEnvironment: layoutEnv)
        }
        return layout
    }
    
    // MARK: - CollectionView dataSource
    private func createDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Restaurant> { cell, indexPath, model in
            var config = cell.defaultContentConfiguration()
            config.text = model.name
            config.secondaryText = model.type
            cell.contentConfiguration = config
        }
        
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    // lets be consistent
    @MainActor
    private func updateSnapshot(animated: Bool = true) {
        snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(restaurants, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UICollectionViewDelegate
extension RestaurantsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let restaurant = restaurants[indexPath.row]
        delegate?.didSelectRestaurant(restaurant)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

