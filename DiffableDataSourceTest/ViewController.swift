//
//  ViewController.swift
//  DiffableDataSourceTest
//
//  Created by ogaoga on 2021/01/10.
//

import UIKit
import Combine

class ViewController: UIViewController {

    typealias Section = Type
    typealias Row = Icon
    
    private let model = Model()
    private var collectionView: UICollectionView! = nil
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    private var cancellables: Set<AnyCancellable> = []

    private static let headerHeight: CGFloat = 44.0
    private static let sectionHeaderElementKind = "section-header-element-kind"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurations
        configureHierarchy()
        configureDataSource()

        // Subscribe data
        model.$data
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
                snapshot.appendSections(Type.allCases)
                data.forEach {
                    snapshot.appendItems([$0], toSection: $0.type)
                }
                self.diffableDataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Collection View

extension ViewController {
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            // List
            let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let section = NSCollectionLayoutSection.list(
                using: configuration, layoutEnvironment: layoutEnvironment
            )
            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(ViewController.headerHeight)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: ViewController.sectionHeaderElementKind,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
    }

    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    private func configureDataSource() {
        
        // Cell
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row> {
            (cell, indexPath, row) in
            // Content
            var config = UIListContentConfiguration.valueCell()
            config.text = row.name
            config.image = row.image
            config.secondaryText = "\(row.value)"
            cell.contentConfiguration = config
        }
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Row>(
            collectionView: collectionView
        ) {
            (collectionView: UICollectionView, indexPath: IndexPath, row: Row)
                -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: row
            )
        }
        
        // Header
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: ViewController.sectionHeaderElementKind
        ) { (supplementaryView, string, indexPath) in
            var config = UIListContentConfiguration.plainHeader()
            config.text = Type.allCases[indexPath.section].rawValue
            supplementaryView.contentConfiguration = config
        }
    
        diffableDataSource.supplementaryViewProvider = { (view, kind, index) in
            switch kind {
            case ViewController.sectionHeaderElementKind:
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration,
                    for: index
                )
            default:
                return nil
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // selected
        if let selected = diffableDataSource.itemIdentifier(for: indexPath) {
            model.increment(id: selected.id)
        }
    }
}
