//
//  WordCell.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import UIKit

final class RowCell: UITableViewCell, NSLayoutManagerDelegate {
    
    public static let reuseIdentifier = "RowCell"
    
    private var textView: UITextView!
    private var textLayoutManager = HighlightWordsLayoutManager()
    
    public var viewModel: SentenceViewModel! {

        didSet {
            bind(to: viewModel)
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
}

// MARK: - Bind to ViewModel

extension RowCell {
    
    private func updateActive(_ isActive: Bool) {
        
        if isActive {
            Styles.apply(activeTextView: self.textView)
        } else {
            
            Styles.apply(textView: self.textView)
        }
    }
    
    func bind(to viewModel: SentenceViewModel) {
        
        let wordHighlightId = "wordHighlight"
        
        textView.text = viewModel.text
        
        viewModel.isActive.observe(on: self, queue: .main) { [weak self] isActive in

            self?.updateActive(isActive)
        }
        
        viewModel.selectedWordRange.observe(on: self, queue: .main) { [weak self] activeRange in
            
            guard let self = self else {
                return
            }
            
            guard let activeRange = activeRange else {
                self.textLayoutManager.removeHighlight(id: wordHighlightId)
                return
            }

            
            self.textLayoutManager.putHighlight(
                highlight: .init(
                    id: wordHighlightId,
                    range: NSRange(activeRange, in: viewModel.text),
                    color: .red
                )
            )
        }
    }
}

// MARK: - Setup Views

extension RowCell {
    
    private func didTapOutside() {

        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.toggleWord(viewModel.id, nil)
    }
    
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
        var isPlacedInLine = false
        
        textView.layoutManager.enumerateLineFragments(forGlyphRange: textView.textRange) {
            [weak self] (rect, usedRect, textContainer, glyphRange, stop) in
            
            guard let self = self else {
                return
            }

            let textContainerInset = self.textView.textContainerInset
            
            let usedRectWithInsets = usedRect.offsetBy(
                dx: textContainerInset.left,
                dy: textContainerInset.top
            ).inset(
                by: .init(
                    top: 0,
                    left: 0,
                    bottom: -2,
                    right: 0
                )
            )
            
            let placedInLine = usedRectWithInsets.contains(point)
            guard placedInLine else {
                return
            }

            let tapRange = self.textView.characterRange(at: point)
            guard let tapRange = tapRange else {
                return
            }
            
            stop.pointee = true
            isPlacedInLine = true
            self.didTap(range: tapRange)
        }
        
        if !isPlacedInLine {
            didTapOutside()
        }
    }
    
    private func setupViews() {

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didTap(gesture:)))
        
        let textStorage = NSTextStorage()
        let textContainer = NSTextContainer(size: .zero)
        
        textStorage.addLayoutManager(self.textLayoutManager)
        
        textLayoutManager.addTextContainer(textContainer)
        textLayoutManager.delegate = self
        
        textView = UITextView(frame: contentView.frame, textContainer: textContainer)
        textView.addGestureRecognizer(tapGestureRecognizer)
        
        contentView.addSubview(textView)
    }
}

// MARK: - Layout

extension RowCell {
    
    private func layout() {

        textView.constraintTo(view: contentView)
    }
}
