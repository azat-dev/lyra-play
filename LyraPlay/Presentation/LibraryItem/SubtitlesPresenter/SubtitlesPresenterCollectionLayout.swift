//
//  SubtitlesPresenterCollectionLayout.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation
import UIKit

final class SubtitlesPresenterCollectionLayout: UICollectionViewLayout {
    
    public static let sectionBackgroundDecoration = "sectionBackground"
    
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
    
    private static func mapItemAttributes(_ attributes: ItemAttributes) -> UICollectionViewLayoutAttributes {
        
        let result = UICollectionViewLayoutAttributes(forCellWith: attributes.path)
        result.frame = attributes.frame
        
        return result
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = viewModel.getAttributes(section: indexPath.section, item: indexPath.item)
        
        return Self.mapItemAttributes(attributes)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let itemsAttributes = viewModel.getAttributesOfItems(at: rect)
        
        guard !itemsAttributes.isEmpty else {
            return nil
        }
        
        var result = [UICollectionViewLayoutAttributes]()
        result.reserveCapacity(itemsAttributes.count)
        
        for itemsAttribute in itemsAttributes {
            
            let itemPath = itemsAttribute.path
            
            result.append(Self.mapItemAttributes(itemsAttribute))
            
            guard
                itemPath.item == 0,
                let sectionAttributes = viewModel.getSectionAttributes(section: itemPath.section)
            else {
                continue
            }
            result.append(Self.mapSectionAttributes(sectionAttributes))
        }
        
        return result
    }
    
    
    private static func mapSectionAttributes(_ attributes: ItemAttributes) -> UICollectionViewLayoutAttributes {
        
        let result = UICollectionViewLayoutAttributes(forDecorationViewOfKind: sectionBackgroundDecoration, with: attributes.path)
        result.frame = attributes.frame
        
        return result
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        guard elementKind == Self.sectionBackgroundDecoration else {
            return nil
        }
        
        guard indexPath.item == 0 else {
            return nil
        }

        let attributes = viewModel.getSectionAttributes(section: indexPath.section)
        guard let attributes = attributes else {
            return nil
        }

        return Self.mapSectionAttributes(attributes)
    }
}
