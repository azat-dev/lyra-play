//
//  WordCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

final class RowCell: UITableViewCell {
    
    public static let reuseIdentifier = "RowCell"
    
    private var textView = UITextView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        setupViews()
        layout()
    }
    
    public func configure(with viewModel: RowCellViewModel) {
        
        textView.text = viewModel.text
        style(with: viewModel)
    }
}

// MARK: - Setup Views

extension RowCell {

    @objc
    private func didTap(gesture: UITapGestureRecognizer) {
        
        let point = gesture.location(in: textView)
        let range = textView.characterRange(at: point)
        
        print(range)
    }
    
    private func setupViews() {

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didTap(gesture:)))
        
        textView.addGestureRecognizer(tapGestureRecognizer)
        contentView.addSubview(textView)
    }
}

// MARK: - Styles

extension RowCell {
    
    private func style(with viewModel: RowCellViewModel) {
    
        if viewModel.isActive {
    
            Styles.apply(activeTextView: textView)
        } else {
            
            Styles.apply(textView: textView)
        }
    }
}

// MARK: - Layout

extension RowCell {
    
    private func layout() {

        textView.constraintTo(view: contentView)
    }
}
