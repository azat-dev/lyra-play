//
//  SubtitlesPresenterCollectionLayout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation
import UIKit

final class SubtitlesPresenterCollectionLayout: UICollectionViewLayout {
    
    private var collectionViewSize: CGSize!
    private let viewModel: WordsFlowLayoutViewModel
    
    init(viewModel: WordsFlowLayoutViewModel) {
        
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {

        collectionViewSize = collectionView?.bounds.size ?? .zero
        viewModel.prepare(containerSize: collectionViewSize)
    }
    
    override var collectionViewContentSize: CGSize {
        viewModel.contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        guard let collectionView = collectionView else {
            return false
        }
        
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    private static func map(_ attributes: ItemAttributes) -> UICollectionViewLayoutAttributes {
        
        let result = UICollectionViewLayoutAttributes(forCellWith: attributes.path)
        result.frame = attributes.frame
        
        return result
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = viewModel.getAttributes(section: indexPath.section, item: indexPath.item)
        
        return Self.map(attributes)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = viewModel.getAttributesOfItems(at: rect)
        return attributes.map(Self.map)
    }
}
