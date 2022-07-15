//
//  WordCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

final class WordCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "WordCell"
    
    private var label = UILabel()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        setupViews()
        layout()
    }
    
    public func configure(with viewModel: WordCellViewModel) {
        
        label.text = viewModel.text
        style(with: viewModel)
    }
    
    public static func getSize(text: String) -> CGSize {
        
        let label = UILabel()
        label.text = text
        label.layoutSubviews()
        
        Styles.apply(label: label)
        
        return label.intrinsicContentSize
    }
}

// MARK: - Setup Views

extension WordCell {
    
    private func setupViews() {

        contentView.addSubview(label)
    }
}

// MARK: - Styles

extension WordCell {
    
    private func style(with viewModel: WordCellViewModel) {
    
        if viewModel.isActive {
            backgroundColor = .red
            Styles.apply(activeLabel: label)
        } else {
            backgroundColor = .black
            Styles.apply(label: label)
        }
    }
}

// MARK: - Layout

extension WordCell {
    
    private func layout() {

        label.constraintTo(view: contentView)
    }
}
