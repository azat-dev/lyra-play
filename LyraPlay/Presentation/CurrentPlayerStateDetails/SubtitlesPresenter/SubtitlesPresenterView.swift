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
            guard let viewModel = viewModel else {
                return
            }
            
            bind(to: viewModel)
        }
    }
    
    private var prevState: SubtitlesPresentationState? = nil
    
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
    
    private func bind(to viewModel: SubtitlesPresenterViewModel) {
        
        viewModelObserver = viewModel.state
            .receive(on: RunLoop.main)
            .sink { [weak self] newState in
                
                guard let self = self else {
                    return
                }
                
                if let activeSentenceIndex = newState.activeSentenceIndex {
                    
                    guard self.collectionView.numberOfItems(inSection: 0) > activeSentenceIndex else {
                        return
                    }
                    
                    let indexPath = IndexPath(row: activeSentenceIndex, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                }
            }
    }
}

extension SubtitlesPresenterView {
    
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let self = self else {
                return nil
            }

//            let insets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(50)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .estimated(20)
//            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )
            
//            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
//            section.contentInsets = insets
            
//            section.interGroupSpacing = verticalSpacing
            
            
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
        
        guard let rows = viewModel?.state.value.rows else {
            fatalError("Can't find row at: \(indexPath.item)")
        }
        
        cell.viewModel = rows[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return viewModel?.state.value.rows.count ?? 0
    }
}
