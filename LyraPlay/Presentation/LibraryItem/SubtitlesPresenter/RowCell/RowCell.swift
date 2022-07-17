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
    public var viewModel: RowCellViewModel? {

        didSet {
            guard let viewModel = viewModel else {
                return
            }

            configure(with: viewModel)
        }
    }

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
    
    private func configure(with viewModel: RowCellViewModel) {
        
        textView.text = viewModel.text
        style(with: viewModel)
    }
}

// MARK: - Setup Views

extension RowCell {
    
    private func didTap(range: UITextRange) {

        guard let viewModel = viewModel else {
            return
        }
        
        let nsRange = range.toNSRange(textView: textView)
        guard let range = Range(nsRange, in: viewModel.text) else {
            return
        }
        
        viewModel.toggleWord(viewModel.id, range)
    }

    @objc
    private func didTap(gesture: UITapGestureRecognizer) {
        
        let point = gesture.location(in: textView)
        
        textView.layoutManager.enumerateLineFragments(forGlyphRange: textView.textRange) {
            [weak self] (rect, usedRect, textContainer, glyphRange, stop) in
        
            guard let self = self else {
                return
            }
            
            let placedInLine = usedRect.contains(point)
            guard placedInLine else {
                
                stop.pointee = true
                return
            }

            
            let tapRange = self.textView.characterRange(at: point)
            
            guard let tapRange = tapRange else {
                return
            }
            
            self.didTap(range: tapRange)
        }
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
