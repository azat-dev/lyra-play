//
//  SubtitlesPresenterView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import Combine
import UIKit

public final class SubtitlesPresenterView: UIView, UICollectionViewDelegate {
    
    private var viewModelObserver: AnyCancellable?
    private var collectionView: UICollectionView!
    
    public var viewModel: SubtitlesPresenterViewModel? {
        
        didSet {
            bind(to: viewModel)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        setupViews()
        layout()
        style()
    }
    
    deinit {
        viewModelObserver?.cancel()
    }
}

// MARK: - Bind viewModel

extension SubtitlesPresenterView {
    
    private func update(position: SubtitlesTimeSlot?) {
        
        guard let newPosition = position else {
            return
        }
        
        collectionView.scrollToItem(
            at: .init(item: newPosition.index, section: 0),
            at: .centeredVertically,
            animated: true
        )
    }
    
    private func bind(to viewModel: SubtitlesPresenterViewModel?) {
        
        collectionView.reloadData()
        
        guard let viewModel = viewModel else {
            viewModelObserver = nil
            return
        }
        
        viewModelObserver = viewModel.position
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPosition in
                
                self?.update(position: newPosition)
            }
    }
}

extension SubtitlesPresenterView {
    
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(80)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }

        return layout
    }
    
    private func setupViews() {
        
        collectionView = UICollectionView(
            frame: frame,
            collectionViewLayout: createLayout()
        )
        
        collectionView.register(
            RowCell.self,
            forCellWithReuseIdentifier: RowCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
    }
}

// MARK: - Layout

extension SubtitlesPresenterView {
    
    private func layout() {
        
        Layout.apply(
            view: self,
            collectionView: collectionView
        )
    }
}

// MARK: - Style

extension SubtitlesPresenterView {
    
    private func style() {
        
        Styles.apply(collectionView: collectionView)
    }
}

// MARK: - Data Source

extension SubtitlesPresenterView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RowCell.reuseIdentifier,
            for: indexPath
        )
        
        guard
            let cell = cell as? RowCell
        else {
            fatalError("Can't dequee a cell")
        }
        
        cell.viewModel = viewModel?.getRowViewModel(at: indexPath.item)
        cell.viewModel?.delegateChanges = cell
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return viewModel?.numberOfRows ?? 0
    }
}
