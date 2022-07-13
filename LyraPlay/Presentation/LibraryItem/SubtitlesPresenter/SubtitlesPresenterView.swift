//
//  SubtitlesPresenterView.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

final class SubtitlesPresenterView: UIView {
    
    private var collectionView: UICollectionView!
    private var viewModel: SubtitlesPresenterViewModel!
    private var prevPosition: SubtitlesPosition?
    
}

// MARK: - Bind viewModel

extension SubtitlesPresenterView {
    
    
    private func bind(to viewModel: SubtitlesPresenterViewModel) {

        viewModel.sentences.observe(on: self) { [weak self] sentences in
            self?.collectionView.reloadData()
        }
        
        viewModel.currentPosition.observe(on: self) { [weak self] position in
            
            guard let self = self else {
                return
            }
            
            guard let sentencePosition = position?.sentence else {
                return
            }
            
            
            self.collectionView.scrollToItem(
                at: IndexPath(row: sentencePosition, section: 0),
                at: .top,
                animated: true
            )
        }
    }
}

// MARK: - Setup Views

extension SubtitlesPresenterView {
    
    private func setupViews() {
        
        collectionView = UICollectionView(
            frame: self.frame,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        collectionView.register(
            WordCell.self,
            forCellWithReuseIdentifier: WordCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        
        addSubview(collectionView)
    }
}

// MARK: - Data Source
extension SubtitlesPresenterView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sentences.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sentences = viewModel.sentences.value else {
            return 0
        }
        
        return sentences[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WordCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let cell = cell as? WordCell else {
            fatalError("Can't dequee a cell")
        }
        
        let sectionIndex = indexPath.section
        let wordIndex = indexPath.item
        
        guard
            let sentences = viewModel.sentences.value,
            sectionIndex < sentences.count
        else {
            fatalError("Inconsistent state")
        }
        
        let sentence = sentences[sectionIndex]
        
        guard wordIndex < sentence.items.count else {
            fatalError("Inconsistent state")
        }

        let item = sentence.items[wordIndex]
        
        let cellViewModel = WordCellViewModel(isActive: false, text: item.getText())
        
        cell.configure(with: cellViewModel)
        
        return cell
    }    
}

// MARK: - Layout

extension SubtitlesPresenterView {
    
    private func layout() {
        
        
    }
}
