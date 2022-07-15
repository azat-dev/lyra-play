//
//  SubtitlesPresenterView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

public protocol WordCellsDataSource {
    
    func getItem(at: IndexPath) -> WordCellViewModel?
    
    func getItemSize(at: IndexPath) -> CGSize?
}

public final class SubtitlesPresenterView: UIView {
    
    private var collectionView: UICollectionView!
    
    public var viewModel: SubtitlesPresenterViewModel? {
        
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            bind(to: viewModel)
        }
    }
    
    private var prevPosition: SubtitlesPosition?
    
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
    }
}

// MARK: - Bind viewModel

extension SubtitlesPresenterView {
    
    
    private func bind(to viewModel: SubtitlesPresenterViewModel) {

        viewModel.sentences.observe(on: self, queue: .main) { [weak self] sentences in
            self?.collectionView.reloadData()
        }
        
        viewModel.currentPosition.observe(on: self, queue: .main) { [weak self] position in
            
            guard let self = self else {
                return
            }
            
            guard let sentencePosition = position?.sentence else {
                return
            }
            
            let indexPath = IndexPath(row: position?.word ?? 0, section: sentencePosition)
            
            self.collectionView.reloadItems(at: [indexPath])
            
            self.collectionView.scrollToItem(
                at: indexPath,
                at: .top,
                animated: true
            )
        }
    }
}

// MARK: - Setup Views

extension SubtitlesPresenterView: ItemsSizesProvider {
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        
        let config = WordsFlowLayoutViewModel.Config(
            sectionsInsets: .init(
                top: 30,
                left: 5,
                bottom: 30,
                right: 5
            )
        )
        
        let layoutViewModel = WordsFlowLayoutViewModel(
            sizesProvider: self,
            config: config
        )
    
        return SubtitlesPresenterCollectionLayout(viewModel: layoutViewModel)
    }
    
    private func setupViews() {

        let collectionViewLayout = createCollectionViewLayout()
        collectionViewLayout.register(
            SectionBackgroundView.self,
            forDecorationViewOfKind: SubtitlesPresenterCollectionLayout.sectionBackgroundDecoration
        )
        
        collectionView = UICollectionView(
            frame: self.frame,
            collectionViewLayout: collectionViewLayout
        )
        
        collectionView.register(
            WordCell.self,
            forCellWithReuseIdentifier: WordCell.reuseIdentifier
        )

        collectionView.dataSource = self
        
        addSubview(collectionView)
    }
    
    public func getItemSize(section: Int, item: Int) -> CGSize {
        
        return getItemSize(at: IndexPath(item: item, section: section))!
    }
    
    public func numberOfItems(section: Int) -> Int {
        return viewModel?.sentences.value?[section].items.count ?? 0
    }
    
    public var numberOfSections: Int {
        return viewModel?.sentences.value?.count ??  0
    }
}

// MARK: - Word Cells Data Source

extension SubtitlesPresenterView: WordCellsDataSource {
    
    public func getItem(at indexPath: IndexPath) -> WordCellViewModel? {
        
        let sectionIndex = indexPath.section
        let wordIndex = indexPath.item
        
        guard
            let sentences = viewModel?.sentences.value,
            sectionIndex < sentences.count
        else {
            fatalError("Inconsistent state")
        }
        
        let sentence = sentences[sectionIndex]
        
        guard wordIndex < sentence.items.count else {
            fatalError("Inconsistent state")
        }

        let item = sentence.items[wordIndex]
        
        return WordCellViewModel(
            isActive: false,
            text: item.getText()
        )
    }
    
    public func getItemSize(at indexPath: IndexPath) -> CGSize? {
        
        guard let item = getItem(at: indexPath) else {
            return nil
        }

        return WordCell.getSize(text: item.text)
    }
}

// MARK: - Data Source

extension SubtitlesPresenterView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sentences.value?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sentences = viewModel?.sentences.value else {
            return 0
        }
        
        return sentences[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WordCell.reuseIdentifier,
            for: indexPath
        )
        
        guard
            let cell = cell as? WordCell,
            let cellViewModel = getItem(at: indexPath)
        else {
            fatalError("Can't dequee a cell")
        }
        
        cell.configure(with: cellViewModel)
        
        return cell
    }
}

// MARK: - Layout

extension SubtitlesPresenterView {
    
    private func layout() {
        
        collectionView.constraintTo(view: self)
    }
}
