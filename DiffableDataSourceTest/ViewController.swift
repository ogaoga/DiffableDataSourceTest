//
//  ViewController.swift
//  DiffableDataSourceTest
//
//  Created by ogaoga on 2021/01/10.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private let viewModel = ViewModel()
    
    private var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureDataSource()

        // Subscribe rows
        viewModel.$rows
            .receive(on: RunLoop.main)
            .sink { rows in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self.viewModel.rows)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cancellables.forEach { $0.cancel() }
        super.viewWillDisappear(animated)
    }
    
    private func deleteRows(_ rows: [Row]) {
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems(rows)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadRows(_ rows: [Row]) {
        var snapshot = self.dataSource.snapshot()
        snapshot.reloadItems(rows)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController {
    private func createLayout() -> UICollectionViewLayout {
        let actionDeley = 0.6
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        // Swipe Actions
        config.leadingSwipeActionsConfigurationProvider = { indexPath in
            let incrementAction = UIContextualAction(style: .normal, title: "Increment") { (action, view, completion) in
                if let row = self.dataSource.itemIdentifier(for: indexPath) {
                    // increment data
                    DispatchQueue.main.asyncAfter(deadline: .now() + actionDeley) {
                        self.viewModel.increment(row: row)                        
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            }
            incrementAction.image = UIImage(systemName: "plus")
            return UISwipeActionsConfiguration(actions: [incrementAction])
        }
        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                if let row = self.dataSource.itemIdentifier(for: indexPath) {
                    // delete from data
                    self.viewModel.delete(row: row)
                    completion(true)
                } else {
                    completion(false)
                }
            }
            deleteAction.image = UIImage(systemName: "trash")
            let swipeActionsConfig = UISwipeActionsConfiguration(actions: [deleteAction])
            swipeActionsConfig.performsFirstActionWithFullSwipe = false
            return swipeActionsConfig
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row> { (cell, indexPath, row) in
            // Content
            let row = self.viewModel.rows[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = row.name
            content.secondaryText = "\(row.count)"
            cell.contentConfiguration = content
            // Accessaries
            cell.accessories = [.disclosureIndicator(displayed: .whenNotEditing)]
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Row) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
